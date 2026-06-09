import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/music.dart';

class LastFmService {
  static const String _apiKey = '62d2310a77a7b00387f2dd7ebe4353ab';
  static const String _baseUrl = 'https://ws.audioscrobbler.com/2.0/';

  bool isValidLastFmImage(String url) {
    if (url.isEmpty) return false;
    if (url.endsWith('/34s.png')) return false;
    // Last.fm default placeholders (not real artwork)
    if (url.contains('2a96bdc') || url.contains('2a96cbd')) return false;
    return true;
  }

  String _pickBestLastFmImage(dynamic images, {bool preferThumbnail = false}) {
    if (images is! List || images.isEmpty) return '';

    final sizeOrder = preferThumbnail ? [2, 1, 3, 0, 4] : [4, 3, 2, 1, 0];
    for (final sizeIndex in sizeOrder) {
      if (images.length <= sizeIndex) continue;
      final url = images[sizeIndex]['#text']?.toString() ?? '';
      if (isValidLastFmImage(url)) return url;
    }
    return '';
  }

  Future<Music> fetchTrack({
    required String track,
    required String artist,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?method=track.getInfo'
          '&api_key=$_apiKey'
          '&artist=${Uri.encodeComponent(artist)}'
          '&track=${Uri.encodeComponent(track)}'
          '&format=json',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['error'] != null) {
      throw Exception(data['message']);
    }

    return Music.fromJson(data['track']);
  }

  /// Fast artist search — names and listeners only; images resolved separately.
  Future<List<Map<String, String>>> searchArtists(String query) async {
    final uri = Uri.parse(
      '$_baseUrl?method=artist.search'
          '&artist=${Uri.encodeComponent(query)}'
          '&api_key=$_apiKey'
          '&format=json'
          '&limit=10',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final rawArtists = data['results']?['artistmatches']?['artist'];

    if (rawArtists == null) return [];

    final artists = rawArtists is List ? rawArtists : [rawArtists];

    return artists
        .map<Map<String, String>>((artist) {
          final name = artist['name']?.toString() ?? '';
          return {
            'name': name,
            'mbid': artist['mbid']?.toString() ?? '',
            'image': '',
            'listeners': artist['listeners']?.toString() ?? '0',
          };
        })
        .where((artist) => artist['name']!.isNotEmpty)
        .toList();
  }

  Future<List<Music>> searchTracks(String query) async {
    final uri = Uri.parse(
      '$_baseUrl?method=track.search'
          '&track=${Uri.encodeComponent(query)}'
          '&api_key=$_apiKey'
          '&format=json'
          '&limit=20',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    final tracks = data['results']['trackmatches']['track'] as List;

    final musics = await Future.wait(
      tracks.map((track) async {
        final String trackName = track['name'] ?? '';
        final String artistName = track['artist'] ?? '';
        final String mbid = track['mbid'] ?? '';

        final imageUrl = await getTrackImage(
          track: trackName,
          artist: artistName,
        );

        return Music(
          id: mbid.isNotEmpty ? mbid : '${artistName}_$trackName',
          name: trackName,
          artist: artistName,
          album: '',
          listeners: track['listeners'] ?? '0',
          imageUrl: imageUrl,
        );
      }),
    );

    return musics;
  }

  Future<String> getTrackImage({
    required String track,
    required String artist,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?method=track.getInfo'
            '&artist=${Uri.encodeComponent(artist)}'
            '&track=${Uri.encodeComponent(track)}'
            '&api_key=$_apiKey'
            '&format=json',
      );

      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      final albumImages = data['track']?['album']?['image'];
      if (albumImages != null && albumImages is List && albumImages.isNotEmpty) {
        final image = albumImages.last['#text'];
        if (image != null && image.toString().isNotEmpty) {
          return image;
        }
      }
    } catch (_) {}

    return await getArtistImage(artist);
  }

  Future<String> getArtistImage(String artist) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?method=artist.getInfo'
            '&artist=${Uri.encodeComponent(artist)}'
            '&api_key=$_apiKey'
            '&format=json',
      );

      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      return _pickBestLastFmImage(data['artist']?['image']);
    } catch (_) {}
    return '';
  }

  Future<List<Map<String, String>>> getArtistTopAlbums(String artist) async {
    final uri = Uri.parse(
      '$_baseUrl?method=artist.getTopAlbums'
          '&artist=${Uri.encodeComponent(artist)}'
          '&api_key=$_apiKey'
          '&format=json'
          '&limit=10',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final albums = data['topalbums']?['album'] as List?;
      if (albums != null) {
        return albums.map<Map<String, String>>((album) {
          final image = _pickBestLastFmImage(album['image'], preferThumbnail: true);
          return {
            'name': album['name'] ?? '',
            'image': image,
            'artist': artist,
          };
        }).toList();
      }
    }
    return [];
  }

  Future<List<Music>> getArtistTopTracks(String artist) async {
    final uri = Uri.parse(
      '$_baseUrl?method=artist.getTopTracks'
          '&artist=${Uri.encodeComponent(artist)}'
          '&api_key=$_apiKey'
          '&format=json'
          '&limit=10',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tracks = data['toptracks']?['track'] as List?;
      if (tracks != null) {
        final results = await Future.wait(tracks.map((track) async {
          final name = track['name'] ?? '';
          // Tenta obter a capa do álbum para a música, senão usa a do artista
          final imageUrl = await getTrackImage(track: name, artist: artist);
          return Music(
            id: track['mbid'] ?? '${artist}_$name',
            name: name,
            artist: artist,
            album: '',
            listeners: track['listeners'] ?? '0',
            imageUrl: imageUrl,
          );
        }));
        return results;
      }
    }
    return [];
  }

  Future<Map<String, dynamic>> getAlbumInfo(String artist, String albumName) async {
    final uri = Uri.parse(
      '$_baseUrl?method=album.getInfo'
          '&artist=${Uri.encodeComponent(artist)}'
          '&album=${Uri.encodeComponent(albumName)}'
          '&api_key=$_apiKey'
          '&format=json',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final album = data['album'];
      if (album != null) {
        String image = '';
        if (album['image'] != null && (album['image'] as List).isNotEmpty) {
          image = album['image'].last['#text'] ?? '';
        }

        final tracksData = album['tracks']?['track'];
        List<Music> tracks = [];
        if (tracksData != null) {
          if (tracksData is List) {
            tracks = tracksData.map<Music>((t) => Music(
              id: t['mbid'] ?? '${artist}_${t['name']}',
              name: t['name'] ?? '',
              artist: artist,
              album: albumName,
              listeners: '0',
              imageUrl: image,
            )).toList();
          } else if (tracksData is Map) {
            tracks = [Music(
              id: tracksData['mbid'] ?? '${artist}_${tracksData['name']}',
              name: tracksData['name'] ?? '',
              artist: artist,
              album: albumName,
              listeners: '0',
              imageUrl: image,
            )];
          }
        }

        return {
          'name': album['name'] ?? '',
          'artist': album['artist'] ?? '',
          'image': image,
          'tracks': tracks,
        };
      }
    }
    return {};
  }
}
