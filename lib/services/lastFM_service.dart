import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/artist.dart';

class LastFmService {
  static const String _apiKey = 'SUA_API_KEY';
  static const String _baseUrl =
      'https://ws.audioscrobbler.com/2.0/';

  Future<Artist> fetchArtist(String artistName) async {
    final uri = Uri.parse(
      '$_baseUrl?method=artist.getinfo'
          '&artist=${Uri.encodeComponent(artistName)}'
          '&api_key=$_apiKey'
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
      throw Exception(
        data['message'] ?? 'Erro desconhecido',
      );
    }

    return Artist.fromJson(data['artist']);
  }
}