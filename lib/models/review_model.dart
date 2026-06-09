import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe que modela uma crítica musical (Review) submetida por um utilizador.
/// 
/// Contém informações sobre o autor, a classificação atribuída, o texto descritivo
/// e metadados temporais.
class ReviewModel {
  /// Identificador único gerado automaticamente para a Review.
  final String reviewId;
  
  /// ID do utilizador autor da crítica. Estabelece ligação com a coleção 'users'.
  final String userId;
  
  /// Cópia síncrona do username do autor para otimizar leituras na interface.
  final String userName;
  
  /// Identificador único da faixa musical proveniente da API Externa de música.
  final String songId;

  /// Título da faixa musical (cópia para exibição no feed).
  final String songTitle;

  /// Nome do artista (cópia para exibição no feed).
  final String artist;

  /// URL ou caminho local da capa do álbum.
  final String albumImageUrl;
  
  /// Classificação quantitativa de 1 a 5 estrelas atribuída à faixa.
  final int rating;
  
  /// Conteúdo textual completo da crítica musical realizada.
  final String fullReviewText;
  
  /// Data e hora exatas da submissão da crítica.
  final DateTime timestamp;
  
  /// Contador acumulado de gostos recebidos por outros utilizadores.
  final int likes;

  /// Construtor padrão da classe [ReviewModel].
  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.userName,
    required this.songId,
    this.songTitle = '',
    this.artist = '',
    this.albumImageUrl = '',
    required this.rating,
    required this.fullReviewText,
    required this.timestamp,
    this.likes = 0,
  });

  /// Converte os campos da [ReviewModel] num formato compatível com o Firestore.
  /// 
  /// Converte nativamente o objeto [DateTime] para um [Timestamp] do Firebase.
  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'userName': userName,
      'songId': songId,
      'songTitle': songTitle,
      'artist': artist,
      'albumImageUrl': albumImageUrl,
      'rating': rating,
      'fullReviewText': fullReviewText,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
    };
  }

  /// Instancia uma [ReviewModel] através dos dados recuperados do Cloud Firestore.
  /// 
  /// Realiza o cast explícito de [Timestamp] do Firebase de volta para o tipo nativo [DateTime] do Dart.
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['reviewId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Utilizador',
      songId: map['songId'] ?? '',
      songTitle: map['songTitle'] ?? '',
      artist: map['artist'] ?? '',
      albumImageUrl: map['albumImageUrl'] ?? '',
      rating: map['rating'] ?? 0,
      fullReviewText: map['fullReviewText'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
    );
  }
}