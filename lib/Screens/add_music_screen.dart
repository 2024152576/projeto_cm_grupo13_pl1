import 'package:flutter/material.dart';
import 'write_review.dart';

class AddMusicScreen extends StatelessWidget {
  const AddMusicScreen({super.key});

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
        title: const TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
            hintText: 'Nome da música',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
            border: InputBorder.none,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF263D4A),
              border: Border(
                top: BorderSide(color: Colors.blueGrey, width: 1),
                bottom: BorderSide(color: Colors.blueGrey, width: 1),
              ),
            ),
            child: const Text(
              'Pesquisas Recentes',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text('Stronger', style: TextStyle(color: Colors.white70, fontSize: 18)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WriteReviewScreen(
                    songTitle: 'Stronger',
                    artist: 'Kanye West',
                    albumImagePath: 'assets/Covers/grad.jpg',
                  ),
                ),
              );
            },
          ),
          const Divider(color: Colors.blueGrey, height: 1),
        ],
      ),
    );
  }
}