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

  Future<UserModel?> obterUtilizador(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
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

  Stream<List<ReviewModel>> streamTodasReviews() {
    return _db
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<ReviewModel>> streamReviewsDoUtilizador(String userId) {
    return _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
      reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return reviews;
    });
  }

  // Favoritar Artista
  Future<void> alternarFavoritoArtista(String userId, Map<String, String> artistData) async {
    final userDoc = _db.collection('users').doc(userId);
    final doc = await userDoc.get();
    if (!doc.exists) return;

    final user = UserModel.fromMap(doc.data()!);
    List<Map<String, String>> favorites = List.from(user.favoriteArtists);

    final index = favorites.indexWhere((a) => a['name'] == artistData['name']);

    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      if (favorites.length >= 3) {
        throw Exception('Só podes ter 3 artistas favoritos.');
      }
      favorites.add(artistData);
    }

    await userDoc.update({'favoriteArtists': favorites});
  }

  // Favoritar Música
  Future<void> alternarFavoritoMusica(String userId, Map<String, String> songData) async {
    final userDoc = _db.collection('users').doc(userId);
    final doc = await userDoc.get();
    if (!doc.exists) return;

    final user = UserModel.fromMap(doc.data()!);
    List<Map<String, String>> favorites = List.from(user.favoriteSongs);

    final index = favorites.indexWhere((s) => s['id'] == songData['id']);

    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      if (favorites.length >= 3) {
        throw Exception('Só podes ter 3 músicas favoritas.');
      }
      favorites.add(songData);
    }

    await userDoc.update({'favoriteSongs': favorites});
  }

  // Seguir Utilizador
  Future<void> alternarSeguirUtilizador(String currentUserId, String targetUserId) async {
    final currentUserDoc = _db.collection('users').doc(currentUserId);
    final targetUserDoc = _db.collection('users').doc(targetUserId);

    await _db.runTransaction((transaction) async {
      final currentSnap = await transaction.get(currentUserDoc);
      final targetSnap = await transaction.get(targetUserDoc);

      if (!currentSnap.exists || !targetSnap.exists) return;

      final currentUser = UserModel.fromMap(currentSnap.data()!);
      List<String> following = List.from(currentUser.following);

      if (following.contains(targetUserId)) {
        following.remove(targetUserId);
        transaction.update(currentUserDoc, {
          'following': following,
          'followingCount': FieldValue.increment(-1)
        });
        transaction.update(targetUserDoc, {'followersCount': FieldValue.increment(-1)});
      } else {
        following.add(targetUserId);
        transaction.update(currentUserDoc, {
          'following': following,
          'followingCount': FieldValue.increment(1)
        });
        transaction.update(targetUserDoc, {'followersCount': FieldValue.increment(1)});
      }
    });
  }

  Future<void> alternarGostoReview(String userId, String reviewId) async {
    final userDoc = _db.collection('users').doc(userId);
    final reviewDoc = _db.collection('reviews').doc(reviewId);

    await _db.runTransaction((transaction) async {
      final userSnap = await transaction.get(userDoc);
      final reviewSnap = await transaction.get(reviewDoc);

      if (!userSnap.exists || !reviewSnap.exists) return;

      final user = UserModel.fromMap(userSnap.data()!);
      final likedReviews = List<String>.from(user.likedReviews);

      if (likedReviews.contains(reviewId)) {
        likedReviews.remove(reviewId);
        transaction.update(userDoc, {'likedReviews': likedReviews});
        transaction.update(reviewDoc, {'likes': FieldValue.increment(-1)});
      } else {
        likedReviews.add(reviewId);
        transaction.update(userDoc, {'likedReviews': likedReviews});
        transaction.update(reviewDoc, {'likes': FieldValue.increment(1)});
      }
    });
  }

  Future<List<UserModel>> obterSeguidos(List<String> followingIds) async {
    if (followingIds.isEmpty) return [];
    
    // Firestore 'whereIn' supports up to 10 items. For simplicity here, or we can fetch individually
    List<UserModel> users = [];
    for (String id in followingIds) {
      final user = await obterUtilizador(id);
      if (user != null) users.add(user);
    }
    return users;
  }

  // 2. Gravar uma Nova Lista (Playlist) no Firestore
  Future<void> criarPlaylist(PlaylistModel playlist) async {
    try {
      await _db.collection('playlists').doc(playlist.playlistId).set(playlist.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // 3. Obter todas as playlists de um utilizador em tempo real
  Stream<List<PlaylistModel>> streamPlaylistsDoUtilizador(String userId) {
    return _db
        .collection('playlists')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PlaylistModel.fromMap(doc.data()))
            .toList());
  }

  // 4. Adicionar uma música a uma playlist existente
  Future<void> adicionarMusicaAPlaylist(String playlistId, Map<String, dynamic> musicaData) async {
    try {
      await _db.collection('playlists').doc(playlistId).update({
        'songs': FieldValue.arrayUnion([musicaData])
      });
    } catch (e) {
      rethrow;
    }
  }

  // 5. Obter uma playlist específica em tempo real (para ver as músicas a atualizar)
  Stream<PlaylistModel?> streamPlaylist(String playlistId) {
    return _db.collection('playlists').doc(playlistId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return PlaylistModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // 6. Remover uma música de uma playlist existente
  Future<void> removerMusicaDaPlaylist(String playlistId, Map<String, dynamic> musicaData) async {
    try {
      await _db.collection('playlists').doc(playlistId).update({
        'songs': FieldValue.arrayRemove([musicaData])
      });
    } catch (e) {
      rethrow;
    }
  }

  // --- PESQUISA DE UTILIZADORES ---
  Future<List<UserModel>> pesquisarUtilizadores(String query) async {
    try {
      final snapshot = await _db.collection('users').get();
      final users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

      final queryLower = query.toLowerCase().replaceAll('@', '').trim();

      return users.where((u) {
        return u.username.toLowerCase().contains(queryLower) ||
               u.firstName.toLowerCase().contains(queryLower) ||
               u.lastName.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      print('Erro a pesquisar utilizadores: $e');
      return [];
    }
  }
}
