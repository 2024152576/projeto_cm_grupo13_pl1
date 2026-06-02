import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../models/playlist_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Gravar uma Review no Firestore
  Future<void> enviarReview(ReviewModel review) async {
    try {
      // Cria um documento na coleção global 'reviews' com um ID automático/único
      await _db.collection('reviews').doc(review.reviewId).set(review.toMap());

      // Incrementa o número de reviews do utilizador de forma atómica
      await _db.collection('users').doc(review.userId).update({
        'reviewsCount': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
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