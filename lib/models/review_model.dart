import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String userId;
  final String userName;
  final String songTitle;
  final String artist;
  final String albumImagePath;
  final int rating;
  final String fullReviewText;
  final DateTime timestamp;
  final int likes;

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.userName,
    required this.songTitle,
    required this.artist,
    required this.albumImagePath,
    required this.rating,
    required this.fullReviewText,
    required this.timestamp,
    this.likes = 0,
  });

  // Converter para Enviar ao Firestore
  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'userName': userName,
      'songTitle': songTitle,
      'artist': artist,
      'albumImagePath': albumImagePath,
      'rating': rating,
      'fullReviewText': fullReviewText,
      'timestamp': Timestamp.fromDate(timestamp), // O Firestore usa Timestamp
      'likes': likes,
    };
  }

  // Criar a partir do Firestore (útil para o feed mais tarde)
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['reviewId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Utilizador',
      songTitle: map['songTitle'] ?? '',
      artist: map['artist'] ?? '',
      albumImagePath: map['albumImagePath'] ?? '',
      rating: map['rating'] ?? 0,
      fullReviewText: map['fullReviewText'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
    );
  }
}