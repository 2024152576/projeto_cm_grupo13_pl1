import 'package:flutter/material.dart';
import '../models/music.dart';
import '../services/lastFM_service.dart';
import 'music_page.dart';

class AddMusicScreen extends StatefulWidget {
  const AddMusicScreen({super.key});

  @override
  State<AddMusicScreen> createState() => _AddMusicScreenState();
}

class _AddMusicScreenState extends State<AddMusicScreen> {
  final LastFmService _lastFmService = LastFmService();
  final TextEditingController _searchController = TextEditingController();
  List<Music> _searchResults = [];
  bool _isLoading = false;

  void _onSearchSubmitted(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _lastFmService.searchTracks(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao pesquisar músicas: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onSubmitted: _onSearchSubmitted,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          decoration: const InputDecoration(
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
            child: Text(
              _searchController.text.isEmpty ? 'Pesquisas Recentes' : 'Resultados',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFFF8282))))
          else
            Expanded(
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.blueGrey, height: 1),
                itemBuilder: (context, index) {
                  final music = _searchResults[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: music.imageUrl.isNotEmpty
                          ? Image.network(
                              music.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.music_note, color: Colors.white, size: 50),
                            )
                          : const Icon(Icons.music_note, color: Colors.white, size: 50),
                    ),
                    title: Text(music.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    subtitle: Text(music.artist, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicPage(music: music),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}