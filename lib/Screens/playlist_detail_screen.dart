import 'package:flutter/material.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key});

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
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF263D4A),
                  border: Border(
                    top: BorderSide(color: Colors.blue, width: 2),
                    bottom: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                child: const Text(
                  'Lista',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/Users/ambrosio.jpg'),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Ambrosio Milfonte',
                          style: TextStyle(
                            color: Color(0xFFF3E3B6),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Favoritos',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'As minhas músicas favoritas',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 25),

                    // Músicas da Playlist
                    _buildSongCard('Jesus Walks', 'Kanye West', 'assets/Covers/cdp.jpg'),
                    const SizedBox(height: 15),
                    _buildSongCard('All Of The Lights', 'Kanye West', 'assets/Covers/mbdtf.jpg'),
                    const SizedBox(height: 15),
                    _buildSongCard('Stronger', 'Kanye West', 'assets/Covers/grad.jpg'),
                    const SizedBox(height: 15),
                    _buildSongCard('All Falls Down', 'Kanye West', 'assets/Covers/cdp.jpg'),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8282),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Adicionar Música',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongCard(String title, String artist, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF263D4A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                artist,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}