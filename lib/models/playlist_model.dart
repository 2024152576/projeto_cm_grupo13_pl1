import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe que modela uma lista de reprodução (Playlist) personalizada criada pelo utilizador.
class PlaylistModel {
  /// ID único gerado para identificar a lista de reprodução.
  final String playlistId;
  
  /// Referência ao criador da playlist ([userId]).
  final String userId;
  
  /// Título atribuído à playlist pelo utilizador.
  final String name;
  
  /// Data de criação da playlist.
  final DateTime timestamp;
  
  /// Lista dinâmica contendo os identificadores das músicas que pertencem a esta playlist.
  final List<dynamic> songs;

  /// Construtor padrão da classe [PlaylistModel].
  PlaylistModel({
    required this.playlistId,
    required this.userId,
    required this.name,
    required this.timestamp,
    this.songs = const [],
  });

  /// Transforma as propriedades do objeto num mapa chave-valor para persistência.
  Map<String, dynamic> toMap() {
    return {
      'playlistId': playlistId,
      'userId': userId,
      'name': name,
      'timestamp': Timestamp.fromDate(timestamp),
      'songs': songs,
    };
  }

  /// Reconstrói uma playlist a partir de estruturas [Map] extraídas da base de dados remota.
  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      playlistId: map['playlistId'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      songs: map['songs'] ?? [],
    );
  }
}