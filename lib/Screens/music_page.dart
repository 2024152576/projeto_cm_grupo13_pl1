import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/music.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/lastFM_service.dart';
import 'write_review.dart';
import 'artist_page.dart';
import 'album_page.dart';
import '../widgets/review_like_button.dart';

class MusicPage extends StatefulWidget {
  final Music music;

  const MusicPage({
    super.key,
    required this.music,
  });

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final DatabaseService _databaseService = DatabaseService();
  final LastFmService _lastFmService = LastFmService();
  ReviewModel? _userReview;
  Music? _fullMusic;
  UserModel? _currentUser;
  bool _isLoadingReview = true;
  bool _isLoadingMusic = false;
  String _ordemAtual = 'Recentes';

  @override
  void initState() {
    super.initState();
    _fullMusic = widget.music;
    _checkExistingReview();
    _loadUserData();
    if (_fullMusic!.album.isEmpty) {
      _fetchFullTrackInfo();
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _databaseService.streamUtilizador(user.uid).listen((userData) {
        if (mounted) setState(() => _currentUser = userData);
      });
    }
  }

  Future<void> _fetchFullTrackInfo() async {
    setState(() => _isLoadingMusic = true);
    try {
      final musicInfo = await _lastFmService.fetchTrack(
        track: widget.music.name,
        artist: widget.music.artist,
      );
      if (mounted) {
        setState(() {
          _fullMusic = musicInfo;
          _isLoadingMusic = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMusic = false);
    }
  }

  Future<void> _checkExistingReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final review = await _databaseService.obterReviewUtilizadorMusica(
        user.uid,
        widget.music.id,
      );
      if (mounted) {
        setState(() {
          _userReview = review;
          _isLoadingReview = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingReview = false);
    }
  }

  void _toggleFavorite() async {
    if (_currentUser == null) return;
    try {
      await _databaseService.alternarFavoritoMusica(_currentUser!.userId, {
        'id': _fullMusic!.id,
        'name': _fullMusic!.name,
        'artist': _fullMusic!.artist,
        'image': _fullMusic!.imageUrl,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _navigateToWriteReview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteReviewScreen(
          songId: _fullMusic!.id,
          songTitle: _fullMusic!.name,
          artist: _fullMusic!.artist,
          albumImagePath: _fullMusic!.imageUrl.isNotEmpty
              ? _fullMusic!.imageUrl
              : 'assets/Covers/default.jpg',
          reviewExistente: _userReview,
        ),
      ),
    );

    if (result == true) {
      _checkExistingReview();
    }
  }

  List<ReviewModel> _ordenarReviews(List<ReviewModel> reviews) {
    final listaOrdenada = List<ReviewModel>.from(reviews);
    switch (_ordemAtual) {
      case 'Recentes':
        listaOrdenada.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'Antigas':
        listaOrdenada.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'Melhor Avaliação':
        listaOrdenada.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Pior Avaliação':
        listaOrdenada.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    return listaOrdenada;
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF18384B);
    const yellowColor = Color(0xFFF5D98E);
    const pinkColor = Color(0xFFFF7D7D);

    bool isFavorite = _currentUser?.favoriteSongs.any((s) => s['id'] == _fullMusic!.id) ?? false;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text("Decibel", style: TextStyle(color: yellowColor, fontSize: 26, fontWeight: FontWeight.bold))),
                    ),
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? pinkColor : yellowColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_fullMusic!.name, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArtistPage(artistName: _fullMusic!.artist),
                                ),
                              );
                            },
                            child: Text(
                              _fullMusic!.artist,
                              style: const TextStyle(
                                color: yellowColor,
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text("Álbum", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                          if (_isLoadingMusic)
                            const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: yellowColor))
                          else
                            GestureDetector(
                              onTap: _fullMusic!.album.isNotEmpty ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlbumPage(
                                      albumName: _fullMusic!.album,
                                      artistName: _fullMusic!.artist,
                                      albumImage: _fullMusic!.imageUrl,
                                    ),
                                  ),
                                );
                              } : null,
                              child: Text(
                                _fullMusic!.album.isEmpty ? "Desconhecido" : _fullMusic!.album,
                                style: TextStyle(
                                  color: _fullMusic!.album.isNotEmpty ? yellowColor : Colors.white70,
                                  fontSize: 16,
                                  decoration: _fullMusic!.album.isNotEmpty ? TextDecoration.underline : null,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text("Listeners", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                          Text(_fullMusic!.listeners, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _fullMusic!.imageUrl.isNotEmpty
                          ? Image.network(_fullMusic!.imageUrl, width: 130, height: 130, fit: BoxFit.cover)
                          : Container(width: 130, height: 130, color: Colors.black26, child: const Icon(Icons.music_note, color: Colors.white, size: 50)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const TabBar(
                indicatorColor: pinkColor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: [Tab(text: "Comunidade"), Tab(text: "Amigos")],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildCommunityTab(),
                    _buildFriendsTab(),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isLoadingReview ? null : _navigateToWriteReview,
                    child: _isLoadingReview
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_userReview != null ? "Editar Review" : "Adicionar Review",
                            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleReviewLike(String reviewId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sessão para gostares de reviews')),
      );
      return;
    }

    try {
      await _databaseService.alternarGostoReview(user.uid, reviewId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gostar da review: $e')),
        );
      }
    }
  }

  Widget _buildReviewListItem(ReviewModel r) {
    final isLiked = _currentUser?.likedReviews.contains(r.reviewId) ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.userName, style: const TextStyle(color: Color(0xFFF5D98E), fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, color: const Color(0xFFFF7D7D), size: 14)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(DateFormat('dd MMM yyyy').format(r.timestamp), style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 10),
          Text(r.fullReviewText, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 10),
          ReviewLikeButton(
            likes: r.likes,
            isLiked: isLiked,
            onTap: () => _toggleReviewLike(r.reviewId),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Reviews", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _ordemAtual,
                dropdownColor: const Color(0xFF263D4A),
                icon: const Icon(Icons.sort, color: Color(0xFFF5D98E)),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: ['Recentes', 'Antigas', 'Melhor Avaliação', 'Pior Avaliação']
                    .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() => _ordemAtual = newValue!);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ReviewModel>>(
            stream: _databaseService.obterReviewsMusica(widget.music.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Sem reviews ainda. Sê o primeiro!", style: TextStyle(color: Colors.white54)));
              }

              final reviews = _ordenarReviews(snapshot.data!);

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _buildReviewListItem(reviews[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsTab() {
    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Reviews de Amigos", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _ordemAtual,
                dropdownColor: const Color(0xFF263D4A),
                icon: const Icon(Icons.sort, color: Color(0xFFF5D98E)),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: ['Recentes', 'Antigas', 'Melhor Avaliação', 'Pior Avaliação']
                    .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() => _ordemAtual = newValue!);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ReviewModel>>(
            stream: _databaseService.obterReviewsMusica(widget.music.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allReviews = snapshot.data ?? [];
              final friendsReviews = allReviews.where((r) => _currentUser!.following.contains(r.userId)).toList();

              if (friendsReviews.isEmpty) {
                return const Center(child: Text("Nenhum amigo fez review desta música.", style: TextStyle(color: Colors.white54)));
              }

              final reviews = _ordenarReviews(friendsReviews);

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _buildReviewListItem(reviews[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
