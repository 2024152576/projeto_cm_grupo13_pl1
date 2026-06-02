import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModel {
  final String playlistId;
  final String userId;
  final String name;
  final DateTime timestamp;
  final List<dynamic> songs; // Lista que guardará os mapas ou IDs das músicas

  PlaylistModel({
    required this.playlistId,
    required this.userId,
    required this.name,
    required this.timestamp,
    this.songs = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'playlistId': playlistId,
      'userId': userId,
      'name': name,
      'timestamp': Timestamp.fromDate(timestamp),
      'songs': songs,
    };
  }

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