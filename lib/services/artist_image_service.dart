import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lastFM_service.dart';

/// Resolves real artist photos via MusicBrainz/Wikidata, with Last.fm album art fallback.
class ArtistImageService {
  static const _musicBrainzBase = 'https://musicbrainz.org/ws/2';
  static const _userAgent = 'DecibelApp/1.0 (projeto_cm_grupo13_pl1)';

  final LastFmService _lastFmService;
  final Map<String, String> _cache = {};
  static DateTime? _lastMusicBrainzRequest;

  ArtistImageService({LastFmService? lastFmService})
      : _lastFmService = lastFmService ?? LastFmService();

  Future<void> _respectMusicBrainzRateLimit() async {
    if (_lastMusicBrainzRequest != null) {
      final elapsed = DateTime.now().difference(_lastMusicBrainzRequest!);
      const minGap = Duration(milliseconds: 1100);
      if (elapsed < minGap) {
        await Future.delayed(minGap - elapsed);
      }
    }
    _lastMusicBrainzRequest = DateTime.now();
  }

  Future<String> resolveArtistImage({
    required String artistName,
    String? mbid,
  }) async {
    if (artistName.isEmpty) return '';

    final cacheKey = (mbid != null && mbid.isNotEmpty) ? mbid : artistName.toLowerCase();
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    String image = '';

    final resolvedMbid = (mbid != null && mbid.isNotEmpty)
        ? mbid
        : await _searchMusicBrainzMbid(artistName);

    if (resolvedMbid != null && resolvedMbid.isNotEmpty) {
      image = await _getWikidataImage(resolvedMbid);
    }

    if (image.isEmpty) {
      image = await _getTopAlbumCover(artistName);
    }

    _cache[cacheKey] = image;
    return image;
  }

  Future<String?> _searchMusicBrainzMbid(String artistName) async {
    try {
      await _respectMusicBrainzRateLimit();
      final uri = Uri.parse(
        '$_musicBrainzBase/artist?query=${Uri.encodeQueryComponent('artist:"$artistName"')}&fmt=json&limit=1',
      );
      final response = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final artists = data['artists'] as List?;
      if (artists == null || artists.isEmpty) return null;

      return artists.first['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<String> _getWikidataImage(String mbid) async {
    try {
      await _respectMusicBrainzRateLimit();
      final uri = Uri.parse('$_musicBrainzBase/artist/$mbid?inc=url-rels&fmt=json');
      final response = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (response.statusCode != 200) return '';

      final data = jsonDecode(response.body);
      final relations = data['relations'] as List?;
      if (relations == null) return '';

      String? wikidataId;
      for (final rel in relations) {
        final type = rel['type']?.toString().toLowerCase() ?? '';
        final url = rel['url']?['resource']?.toString() ?? '';
        if (type == 'wikidata' || url.contains('wikidata.org/wiki/Q')) {
          final match = RegExp(r'Q\d+').firstMatch(url);
          if (match != null) {
            wikidataId = match.group(0);
            break;
          }
        }
      }

      if (wikidataId == null) return '';

      final wikidataUri = Uri.parse(
        'https://www.wikidata.org/w/api.php?action=wbgetentities&ids=$wikidataId&props=claims&format=json',
      );
      final wikidataResponse = await http.get(wikidataUri);
      if (wikidataResponse.statusCode != 200) return '';

      final wikidataData = jsonDecode(wikidataResponse.body);
      final entity = wikidataData['entities']?[wikidataId];
      final claims = entity?['claims']?['P18'] as List?;
      if (claims == null || claims.isEmpty) return '';

      final filename = claims.first['mainsnak']?['datavalue']?['value']?.toString();
      if (filename == null || filename.isEmpty) return '';

      return 'https://commons.wikimedia.org/wiki/Special:FilePath/${Uri.encodeComponent(filename)}?width=300';
    } catch (_) {
      return '';
    }
  }

  Future<String> _getTopAlbumCover(String artistName) async {
    try {
      final albums = await _lastFmService.getArtistTopAlbums(artistName);
      for (final album in albums) {
        final image = album['image'] ?? '';
        if (_lastFmService.isValidLastFmImage(image)) return image;
      }
    } catch (_) {}
    return '';
  }

  /// Runs [task] on each item with at most [concurrency] tasks in flight.
  static Future<void> mapConcurrent<T>(
    List<T> items,
    Future<void> Function(T item, int index) task, {
    int concurrency = 1,
  }) async {
    if (items.isEmpty) return;
    var nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final index = nextIndex;
        nextIndex++;
        if (index >= items.length) return;
        await task(items[index], index);
      }
    }

    final workers = List.generate(
      concurrency.clamp(1, items.length),
      (_) => worker(),
    );
    await Future.wait(workers);
  }
}
