import 'package:flutter/material.dart';
import 'user_profile_screen.dart';
import '../services/lastfm_service.dart';
import 'music_page.dart';

class ReviewDetailScreen extends StatelessWidget {
  final String userName;
  final String date;
  final String profileImagePath;
  final String songTitle;
  final String artist;
  final String year;
  final int rating;
  final String likes;
  final String albumImagePath;
  final String fullReviewText;

  const ReviewDetailScreen({
    super.key,
    required this.userName,
    required this.date,
    required this.profileImagePath,
    required this.songTitle,
    required this.artist,
    required this.year,
    required this.rating,
    required this.likes,
    required this.albumImagePath,
    required this.fullReviewText,
  });

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
                            userName: userName,
                            profileImagePath: profileImagePath,
                          ),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(profileImagePath),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                  color: Color(0xFFF3E3B6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),
                            ),
                            Text(
                              date,
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
                                        artist: artist,
                                        track: songTitle,
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MusicPage(
                                            music: music,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Erro: $e'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    songTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  year,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              artist,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < rating ? Icons.star : Icons.star_border,
                                  color: const Color(0xFFFF8282),
                                  size: 24,
                                );
                              }),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  likes,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: () async {
                          try {
                            final music = await LastFmService().fetchTrack(
                              artist: artist,
                              track: songTitle,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MusicPage(
                                  music: music,
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro: $e'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(albumImagePath),
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
                fullReviewText,
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