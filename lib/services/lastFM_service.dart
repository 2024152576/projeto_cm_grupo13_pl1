import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/music.dart';

class LastFmService {
  static const String _apiKey = '62d2310a77a7b00387f2dd7ebe4353ab';
  static const String _baseUrl =
      'https://ws.audioscrobbler.com/2.0/';

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
      throw Exception(
        'Erro HTTP ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    if (data['error'] != null) {
      throw Exception(data['message']);
    }

    return Music.fromJson(data['track']);
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

    final tracks =
    data['results']['trackmatches']['track'] as List;

    final musics = await Future.wait(
      tracks.map((track) async {
        final imageUrl = await getTrackImage(
          track: track['name'] ?? '',
          artist: track['artist'] ?? '',
        );

        return Music(
          name: track['name'] ?? '',
          artist: track['artist'] ?? '',
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

      final albumImages =
      data['track']?['album']?['image'];

      if (albumImages != null &&
          albumImages is List &&
          albumImages.isNotEmpty) {
        final image =
        albumImages.last['#text'];

        if (image != null &&
            image.toString().isNotEmpty) {
          return image;
        }
      }
    } catch (_) {}

    try {
      final uri = Uri.parse(
        '$_baseUrl?method=artist.getInfo'
            '&artist=${Uri.encodeComponent(artist)}'
            '&api_key=$_apiKey'
            '&format=json',
      );

      final response = await http.get(uri);

      final data = jsonDecode(response.body);

      final artistImages =
      data['artist']?['image'];

      if (artistImages != null &&
          artistImages is List &&
          artistImages.isNotEmpty) {
        return artistImages.last['#text'] ?? '';
      }
    } catch (_) {}

    return '';
  }
}

