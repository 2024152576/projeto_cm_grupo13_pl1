import 'package:flutter/material.dart';
import '../models/music.dart';
import '../services/lastFM_service.dart';
import 'music_page.dart';

class AlbumPage extends StatefulWidget {
  final String albumName;
  final String artistName;
  final String albumImage;

  const AlbumPage({
    super.key,
    required this.albumName,
    required this.artistName,
    required this.albumImage,
  });

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  final LastFmService _lastFmService = LastFmService();
  List<Music> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlbumTracks();
  }

  Future<void> _fetchAlbumTracks() async {
    try {
      final albumData = await _lastFmService.getAlbumInfo(widget.artistName, widget.albumName);
      if (mounted) {
        setState(() {
          _tracks = albumData['tracks'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar faixas do álbum: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF18384B);
    const yellowColor = Color(0xFFF5D98E);
    const pinkColor = Color(0xFFFF7D7D);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Álbum",
          style: TextStyle(color: yellowColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: pinkColor))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Album Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.albumImage.isNotEmpty
                              ? Image.network(
                                  widget.albumImage,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.white10,
                                  child: const Icon(Icons.album, color: Colors.white, size: 80),
                                ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.albumName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.artistName,
                          style: const TextStyle(
                            color: yellowColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Colors.white10),
                  // Tracks List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _tracks.length,
                    itemBuilder: (context, index) {
                      final track = _tracks[index];
                      return ListTile(
                        leading: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                        title: Text(
                          track.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        trailing: const Icon(Icons.more_vert, color: Colors.white54),
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
