import 'dart:async';

import 'package:flutter/material.dart';
import 'user_profile_screen.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/lastfm_service.dart';
import '../widgets/review_like_button.dart';
import 'music_page.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String reviewId;
  final String userId;
  final String userName;
  final String date;
  final String profileImagePath;
  final String songTitle;
  final String artist;
  final String year;
  final int rating;
  final int likesCount;
  final String albumImagePath;
  final String fullReviewText;

  const ReviewDetailScreen({
    super.key,
    required this.reviewId,
    required this.userId,
    required this.userName,
    required this.date,
    required this.profileImagePath,
    required this.songTitle,
    required this.artist,
    required this.year,
    required this.rating,
    required this.likesCount,
    required this.albumImagePath,
    required this.fullReviewText,
  });

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  late int _likes;
  UserModel? _currentUser;
  StreamSubscription<UserModel?>? _userSub;

  @override
  void initState() {
    super.initState();
    _likes = widget.likesCount;
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    _userSub = _databaseService.streamUtilizador(uid).listen((user) {
      if (mounted) setState(() => _currentUser = user);
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  bool get _isLiked => _currentUser?.likedReviews.contains(widget.reviewId) ?? false;

  bool get _isOwnReview =>
      _authService.currentUser?.uid != null &&
      _authService.currentUser!.uid == widget.userId;

  Future<void> _confirmDeleteReview() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null || !_isOwnReview) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF263D4A),
        title: const Text('Apagar review', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tens a certeza que queres apagar esta review?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar', style: TextStyle(color: Color(0xFFFF8282))),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _databaseService.apagarReview(userId, widget.reviewId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review apagada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao apagar review: $e')),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sessão para gostares de reviews')),
      );
      return;
    }

    final wasLiked = _isLiked;
    setState(() {
      _likes += wasLiked ? -1 : 1;
    });

    try {
      await _databaseService.alternarGostoReview(userId, widget.reviewId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _likes += wasLiked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gostar da review: $e')),
        );
      }
    }
  }

  ImageProvider _imageFromPath(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.isNotEmpty) return AssetImage(path);
    return const AssetImage('assets/Covers/cdp.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3746),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3746),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Decibel',
          style: TextStyle(
            color: Color(0xFFF3E3B6),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isOwnReview)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF8282)),
              onPressed: _confirmDeleteReview,
              tooltip: 'Apagar review',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Review'),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            userId: widget.userId,
                            userName: widget.userName,
                            profileImagePath: widget.profileImagePath,
                          ),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        widget.profileImagePath.isNotEmpty
                            ? CircleAvatar(
                                radius: 25,
                                backgroundImage: _imageFromPath(widget.profileImagePath),
                              )
                            : CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFFFF8282),
                                child: Text(
                                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                color: Color(0xFFF3E3B6),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.date,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      final music = await LastFmService().fetchTrack(
                                        artist: widget.artist,
                                        track: widget.songTitle,
                                      );

                                      if (!context.mounted) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MusicPage(music: music),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erro: $e')),
                                      );
                                    }
                                  },
                                  child: Text(
                                    widget.songTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.year,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.artist,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < widget.rating ? Icons.star : Icons.star_border,
                                  color: const Color(0xFFFF8282),
                                  size: 24,
                                );
                              }),
                            ),
                            const SizedBox(height: 15),
                            ReviewLikeButton(
                              likes: _likes,
                              isLiked: _isLiked,
                              onTap: _toggleLike,
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: () async {
                          try {
                            final music = await LastFmService().fetchTrack(
                              artist: widget.artist,
                              track: widget.songTitle,
                            );

                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MusicPage(music: music),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro: $e')),
                            );
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: _imageFromPath(widget.albumImagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildSectionHeader('Review'),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                widget.fullReviewText,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF263D4A),
        border: Border(
          top: BorderSide(color: Colors.blueGrey, width: 2),
          bottom: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
