import 'package:flutter/material.dart';
import 'artist_page.dart';
import 'music_page.dart';
import '../models/music.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String profileImagePath;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.profileImagePath,
  });

  ImageProvider _imageFromPath(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.isNotEmpty) return AssetImage(path);
    return const AssetImage('assets/Covers/cdp.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return StreamBuilder<UserModel?>(
      stream: databaseService.streamUtilizador(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final displayName = user?.fullName ?? userName;
        final username = user?.username ?? '';
        final reviewsCount = user?.reviewsCount ?? 0;
        final followersCount = user?.followersCount ?? 0;
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
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Color(0xFFF3E3B6), size: 30),
                onPressed: () {},
              ),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting && user == null
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8282)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          profileImagePath.isNotEmpty
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage: _imageFromPath(profileImagePath),
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundColor: const Color(0xFFFF8282),
                                  child: Text(
                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                          Text(
                            username,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
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
                            const Text(
                              'Artistas Favoritos',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 15),
                            if (favoriteArtists.isEmpty)
                              const Text(
                                'Sem artistas favoritos.',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              )
                            else
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: favoriteArtists.map((artist) {
                                    final name = artist['name'] ?? '';
                                    final image = artist['image'] ?? '';
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 20.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ArtistPage(artistName: name),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 40,
                                              backgroundImage: _imageFromPath(image),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color(0xFFF3E3B6),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  decoration: TextDecoration.underline,
                                                ),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Músicas Favoritas',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 15),
                            if (favoriteSongs.isEmpty)
                              const Text(
                                'Sem músicas favoritas.',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              )
                            else
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: favoriteSongs.map((song) {
                                    final id = song['id'] ?? '';
                                    final name = song['name'] ?? '';
                                    final artist = song['artist'] ?? '';
                                    final image = song['image'] ?? '';
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 15.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MusicPage(
                                                music: Music(
                                                  id: id,
                                                  name: name,
                                                  artist: artist,
                                                  album: '',
                                                  listeners: '0',
                                                  imageUrl: image,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildFavoriteSong(name, image),
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
      },
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
            image: DecorationImage(image: _imageFromPath(imagePath), fit: BoxFit.cover),
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
