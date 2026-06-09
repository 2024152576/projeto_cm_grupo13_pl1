import 'package:flutter/material.dart';
import 'artist_page.dart';
import 'music_page.dart';
import '../models/music.dart';

class UserProfileScreen extends StatelessWidget {
  final String userName;
  final String profileImagePath;

  const UserProfileScreen({
    super.key,
    required this.userName,
    required this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    bool isSofia = userName == 'Sofia Oliveira';

    String userHandle = isSofia ? '@SofiaOli' : '@MendesStar';
    String reviewsCount = isSofia ? '12' : '1';
    String followersCount = isSofia ? '340' : '1';

    List<Map<String, String>> favSongs = isSofia
        ? [
      {'title': 'All Of The Lights', 'image': 'assets/Covers/mbdtf.jpg', 'artist': 'Kanye West'},
      {'title': 'Devil In A New Dress', 'image': 'assets/Covers/mbdtf.jpg', 'artist': 'Kanye West'},
      {'title': 'Flashing Lights', 'image': 'assets/Covers/grad.jpg', 'artist': 'Kanye West'},
    ]
        : [
      {'title': 'Jesus Walks', 'image': 'assets/Covers/cdp.jpg', 'artist': 'Kanye West'},
      {'title': 'I Wonder', 'image': 'assets/Covers/grad.jpg', 'artist': 'Kanye West'},
      {'title': 'Runaway', 'image': 'assets/Covers/mbdtf.jpg', 'artist': 'Kanye West'},
    ];

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
          userName,
          style: const TextStyle(
            color: Color(0xFFF3E3B6),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFFF3E3B6), size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(profileImagePath),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('A Seguir', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(height: 8),
                Text(userHandle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$reviewsCount ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Text('Reviews', style: TextStyle(color: Color(0xFFF3E3B6))),
                    const SizedBox(width: 30),
                    Text('$followersCount ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Text('Seguidores', style: TextStyle(color: Color(0xFFF3E3B6))),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.grey, height: 1),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Artistas Favoritos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ArtistPage(artistName: 'Kanye West')),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/Artists/ye.jpg'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                            'Kanye West',
                            style: TextStyle(color: Color(0xFFF3E3B6), fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Músicas Favoritas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: favSongs.map((song) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MusicPage(
                                    music: Music(
                                      id: '${song['artist']}_${song['title']}',
                                      name: song['title']!,
                                      artist: song['artist']!,
                                      album: '',
                                      listeners: '0',
                                      imageUrl: song['image']!,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: _buildFavoriteSong(song['title']!, song['image']!),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildMenuOption('Listas'),
            _buildMenuOption('Diário'),
            _buildMenuOption('Pessoas que segue'),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteSong(String title, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: const TextStyle(color: Color(0xFFF3E3B6), fontWeight: FontWeight.bold, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        color: Color(0xFF263D4A),
        border: Border(
          top: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
