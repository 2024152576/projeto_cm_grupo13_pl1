import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/music.dart';
import '../models/user_model.dart';
import '../services/lastFM_service.dart';
import '../services/database_service.dart';
import 'music_page.dart';
import 'album_page.dart';

class ArtistPage extends StatefulWidget {
  final String artistName;

  const ArtistPage({super.key, required this.artistName});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final LastFmService _lastFmService = LastFmService();
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, String>> _albums = [];
  List<Music> _topTracks = [];
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtistData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _databaseService.streamUtilizador(user.uid).listen((userData) {
        if (mounted) setState(() => _currentUser = userData);
      });
    }
  }

  Future<void> _fetchArtistData() async {
    try {
      final albums = await _lastFmService.getArtistTopAlbums(widget.artistName);
      final tracks = await _lastFmService.getArtistTopTracks(widget.artistName);
      if (mounted) {
        setState(() {
          _albums = albums;
          _topTracks = tracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados do artista: $e')),
        );
      }
    }
  }

  void _toggleFavorite() async {
    if (_currentUser == null) return;
    
    // Obter imagem do artista para guardar nos favoritos
    String artistImage = '';
    if (_albums.isNotEmpty) {
      artistImage = _albums.first['image'] ?? '';
    } else if (_topTracks.isNotEmpty) {
      artistImage = _topTracks.first.imageUrl;
    }

    try {
      await _databaseService.alternarFavoritoArtista(_currentUser!.userId, {
        'name': widget.artistName,
        'image': artistImage,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF18384B);
    const yellowColor = Color(0xFFF5D98E);
    const pinkColor = Color(0xFFFF7D7D);

    bool isFavorite = _currentUser?.favoriteArtists.any((a) => a['name'] == widget.artistName) ?? false;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.artistName,
          style: const TextStyle(
            color: yellowColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? pinkColor : yellowColor,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: pinkColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Top Álbuns",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _albums.length,
                      itemBuilder: (context, index) {
                        final album = _albums[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlbumPage(
                                  albumName: album['name']!,
                                  artistName: widget.artistName,
                                  albumImage: album['image']!,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: album['image']!.isNotEmpty
                                      ? Image.network(
                                          album['image']!,
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 140,
                                          height: 140,
                                          color: Colors.white10,
                                          child: const Icon(Icons.album, color: Colors.white, size: 50),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  album['name']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Top Músicas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _topTracks.length,
                    itemBuilder: (context, index) {
                      final track = _topTracks[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: track.imageUrl.isNotEmpty
                              ? Image.network(
                                  track.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.white10,
                                  child: const Icon(Icons.music_note, color: Colors.white),
                                ),
                        ),
                        title: Text(
                          track.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        subtitle: Text(
                          "${track.listeners} ouvintes",
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MusicPage(music: track),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}