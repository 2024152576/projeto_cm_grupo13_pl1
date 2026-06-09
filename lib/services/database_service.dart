import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../models/playlist_model.dart';

/// Camada de Serviço responsável pela persistência NoSQL (CRUD) no Cloud Firestore.
/// 
/// Abstrai chamadas, queries parametrizadas e controlo atómico de dados para as
/// coleções de críticas musicais e listas de reprodução.
class DatabaseService {
  /// Instância interna configurada para comunicação direta com o Cloud Firestore.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Submete de forma assíncrona uma nova crítica musical ou atualiza uma existente.
  /// 
  /// Executa uma transação lógica simulada através de verificações pontuais:
  /// Se a review for totalmente nova, recorre ao método atómico [FieldValue.increment]
  /// para atualizar o contador `reviewsCount` presente no perfil do utilizador,
  /// evitando condições de corrida (Race Conditions).
  Future<void> enviarReview(ReviewModel review) async {
    try {
      final docRef = _db.collection('reviews').doc(review.reviewId);
      final docSnap = await docRef.get();

      await docRef.set(review.toMap());

      // Incremento reativo apenas se o documento for inteiramente inédito
      if (!docSnap.exists) {
        await _db.collection('users').doc(review.userId).update({
          'reviewsCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Efetua uma query estruturada na coleção 'reviews' para obter a crítica de um utilizador específico.
  /// 
  /// Filtra os documentos com base em chaves compostas ([userId] e [songId]). Limitado a 1 resultado.
  Future<ReviewModel?> obterReviewUtilizadorMusica(String userId, String songId) async {
    try {
      final querySnapshot = await _db
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .where('songId', isEqualTo: songId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ReviewModel.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Disponibiliza um fluxo contínuo de dados ([Stream]) com todas as críticas de uma música específica.
  /// 
  /// Sempre que houver uma alteração na coleção das reviews do Firestore, a interface irá sofrer 
  /// uma reconstrução automática em tempo real através deste canal, ideal para utilizar com um `StreamBuilder`.
  Stream<List<ReviewModel>> obterReviewsMusica(String songId) {
    return _db
        .collection('reviews')
        .where('songId', isEqualTo: songId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Grava uma nova playlist criada pelo utilizador no Firestore.
  Future<void> criarPlaylist(PlaylistModel playlist) async {
    try {
      await _db.collection('playlists').doc(playlist.playlistId).set(playlist.toMap());
    } catch (e) {
      rethrow;
    }
  }
}