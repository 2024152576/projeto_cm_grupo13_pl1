import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../models/playlist_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Gravar ou Atualizar uma Review no Firestore
  Future<void> enviarReview(ReviewModel review) async {
    try {
      final docRef = _db.collection('reviews').doc(review.reviewId);
      final docSnap = await docRef.get();

      await docRef.set(review.toMap());

      // Se o documento não existia, incrementa o reviewsCount do utilizador
      if (!docSnap.exists) {
        await _db.collection('users').doc(review.userId).update({
          'reviewsCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obter a review de um utilizador específico para uma música específica
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

  // Obter todas as reviews de uma música
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

  Stream<UserModel?> streamUtilizador(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromMap(snap.data()!);
    });
  }

  Stream<List<ReviewModel>> streamReviewsDeOutros(String currentUserId) {
    return _db
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .where((review) => review.userId != currentUserId)
          .toList();
    });
  }

  // 2. Gravar uma Nova Lista (Playlist) no Firestore
  Future<void> criarPlaylist(PlaylistModel playlist) async {
    try {
      await _db.collection('playlists').doc(playlist.playlistId).set(playlist.toMap());
    } catch (e) {
      rethrow;
    }
  }
}