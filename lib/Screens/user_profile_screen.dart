import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'artist_page.dart';
import 'music_page.dart';
import 'review_detail_screen.dart';
import '../models/music.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../services/database_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String profileImagePath;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.profileImagePath,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  ImageProvider _imageFromPath(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.isNotEmpty) return AssetImage(path);
    return const AssetImage('assets/Covers/cdp.jpg');
  }

  void _toggleFollow() async {
    if (_currentUserId == null || _currentUserId == widget.userId) return;
    try {
      await _databaseService.alternarSeguirUtilizador(_currentUserId!, widget.userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _databaseService.streamUtilizador(widget.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final displayName = user?.fullName ?? widget.userName;
        final username = user?.username ?? '';
        final reviewsCount = user?.reviewsCount ?? 0;
        final followersCount = user?.followersCount ?? 0;
        final followingCount = user?.followingCount ?? 0;
        final favoriteArtists = user?.favoriteArtists ?? [];
        final favoriteSongs = user?.favoriteSongs ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFF1E3746),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E3746),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              displayName,
              style: const TextStyle(
                color: Color(0xFFF3E3B6),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: snapshot.connectionState == ConnectionState.waiting && user == null
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8282)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(user, displayName, username, reviewsCount, followersCount, followingCount),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.grey, height: 1),
                      _buildFavoritesSection('Artistas Favoritos', favoriteArtists, true),
                      _buildFavoritesSection('Músicas Favoritas', favoriteSongs, false),
                      const SizedBox(height: 20),
                      _buildReviewsSection(),
                      _buildFollowingSection(user),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel? user, String displayName, String username, int reviews, int followers, int following) {
    bool isMe = _currentUserId == widget.userId;
    bool isFollowing = false;

    return StreamBuilder<UserModel?>(
      stream: _currentUserId != null ? _databaseService.streamUtilizador(_currentUserId!) : Stream.value(null),
      builder: (context, snap) {
        if (snap.hasData) {
          isFollowing = snap.data!.following.contains(widget.userId);
        }

        return Column(
          children: [
            widget.profileImagePath.isNotEmpty
                ? CircleAvatar(radius: 50, backgroundImage: _imageFromPath(widget.profileImagePath))
                : CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFFF8282),
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
            const SizedBox(height: 15),
            if (!isMe)
              GestureDetector(
                onTap: _toggleFollow,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFollowing ? Colors.transparent : const Color(0xFFFF8282),
                    border: Border.all(color: const Color(0xFFFF8282)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFollowing ? 'A Seguir' : 'Seguir',
                    style: TextStyle(color: isFollowing ? const Color(0xFFFF8282) : Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatColumn(reviews, 'Reviews'),
                const SizedBox(width: 30),
                _buildStatColumn(followers, 'Seguidores'),
                const SizedBox(width: 30),
                _buildStatColumn(following, 'A seguir'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Color(0xFFF3E3B6), fontSize: 12)),
      ],
    );
  }

  Widget _buildFavoritesSection(String title, List<Map<String, String>> items, bool isArtist) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          if (items.isEmpty)
            Text('Sem ${title.toLowerCase()}.', style: const TextStyle(color: Colors.grey, fontSize: 13))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: items.map((item) {
                  final name = item['name'] ?? '';
                  final image = item['image'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: GestureDetector(
                      onTap: () {
                        if (isArtist) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ArtistPage(artistName: name)));
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MusicPage(
                                music: Music(
                                  id: item['id'] ?? '',
                                  name: name,
                                  artist: item['artist'] ?? '',
                                  album: '',
                                  listeners: '0',
                                  imageUrl: image,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          isArtist
                              ? CircleAvatar(radius: 40, backgroundImage: _imageFromPath(image))
                              : Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(image: _imageFromPath(image), fit: BoxFit.cover),
                                  ),
                                ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFFF3E3B6), fontWeight: FontWeight.bold, fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return ExpansionTile(
      title: const Text('Reviews', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      iconColor: const Color(0xFFFF8282),
      collapsedIconColor: Colors.white,
      children: [
        StreamBuilder<List<ReviewModel>>(
          stream: _databaseService.streamReviewsDoUtilizador(widget.userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final reviews = snapshot.data!;
            if (reviews.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('Ainda não há reviews.', style: TextStyle(color: Colors.grey)));
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(review.albumImageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white)),
                  ),
                  title: Text(review.songTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(review.artist, style: const TextStyle(color: Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF8282), size: 16),
                      Text(' ${review.rating}', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewDetailScreen(
                        reviewId: review.reviewId,
                        userId: review.userId,
                        userName: review.userName,
                        date: '${review.timestamp.day}/${review.timestamp.month}/${review.timestamp.year}',
                        profileImagePath: '',
                        songTitle: review.songTitle,
                        artist: review.artist,
                        year: review.timestamp.year.toString(),
                        rating: review.rating,
                        likesCount: review.likes,
                        albumImagePath: review.albumImageUrl,
                        fullReviewText: review.fullReviewText,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFollowingSection(UserModel? user) {
    if (user == null || user.following.isEmpty) {
      return const ListTile(title: Text('A seguir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), subtitle: Text('Não segue ninguém.', style: TextStyle(color: Colors.grey)));
    }

    return ExpansionTile(
      title: const Text('A seguir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      iconColor: const Color(0xFFFF8282),
      collapsedIconColor: Colors.white,
      children: [
        FutureBuilder<List<UserModel>>(
          future: _databaseService.obterSeguidos(user.following),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final following = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: following.length,
              itemBuilder: (context, index) {
                final f = following[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFF8282),
                    child: Text(f.firstName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(f.fullName, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(f.username, style: const TextStyle(color: Color(0xFFFF8282))),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(userId: f.userId, userName: f.fullName, profileImagePath: ''))),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
