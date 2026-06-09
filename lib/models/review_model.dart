import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String userId;
  final String userName;
  final String songId;
  final int rating;
  final String fullReviewText;
  final DateTime timestamp;
  final int likes;

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.userName,
    required this.songId,
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
      'songId': songId,
      'rating': rating,
      'fullReviewText': fullReviewText,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
    };
  }

  // Criar a partir do Firestore
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['reviewId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Utilizador',
      songId: map['songId'] ?? '', // Corrigido aqui
      rating: map['rating'] ?? 0,
      fullReviewText: map['fullReviewText'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
    );
  }
}