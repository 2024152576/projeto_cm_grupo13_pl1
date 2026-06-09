import 'package:flutter/material.dart';
import 'package:projeto_cm_grupo13_pl1/models/playlist_model.dart';
import 'package:projeto_cm_grupo13_pl1/models/user_model.dart';
import 'package:projeto_cm_grupo13_pl1/services/database_service.dart';
import 'package:projeto_cm_grupo13_pl1/models/music.dart';
import 'package:projeto_cm_grupo13_pl1/services/lastFM_service.dart';
import 'package:projeto_cm_grupo13_pl1/Screens/music_page.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final LastFmService _lastFmService = LastFmService();

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
      body: StreamBuilder<PlaylistModel?>(
        stream: _databaseService.streamPlaylist(widget.playlist.playlistId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8282)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Erro ao carregar playlist.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final playlistAtualizada = snapshot.data!;
          final musicas = playlistAtualizada.songs;

          if (musicas.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(playlistAtualizada.name),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Esta playlist ainda não tem músicas.\nClica no + para adicionar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: musicas.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader(playlistAtualizada.name);
              }

              final musicaData = musicas[index - 1];
              final songTitle = musicaData['name'] ?? 'Sem título';
              final artist = musicaData['artist'] ?? 'Artista desconhecido';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSongCard(
                  title: songTitle,
                  artist: artist,
                  imageUrl: musicaData['imageUrl'] ?? '',

                  onDelete: () async {
                    await _databaseService.removerMusicaDaPlaylist(
                      playlistAtualizada.playlistId,
                      musicaData,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"$songTitle" removida!'),
                        ), // SnackBar
                      ); // showSnackBar
                    }
                  },

                  onTap: () async {
                    try {
                      final music = await _lastFmService.fetchTrack(
                        artist: artist,
                        track: songTitle,
                      );

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MusicPage(music: music), // MusicPage
                          ), // MaterialPageRoute
                        ); // push
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao abrir música: $e'),
                          ), // SnackBar
                        ); // showSnackBar
                      }
                    }
                  },
                ), // _buildSongCard
              ); // Padding
            }, // itemBuilder
          ); // ListView.builder
        }, // builder
      ), // StreamBuilder

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8282),
        onPressed: () {
          showSearch(
            context: context,
            delegate: PesquisaMusicaPlaylistDelegate(
              playlistId: widget.playlist.playlistId,
              databaseService: _databaseService,
            ), // PesquisaMusicaPlaylistDelegate
          ); // showSearch
        },
        child: const Icon(Icons.add, color: Color(0xFFF3E3B6)),
      ), // FloatingActionButton
    ); // Scaffold
  }

  Widget _buildHeader(String playlistName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        playlistName,
        style: const TextStyle(
          color: Color(0xFFF3E3B6),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ), // TextStyle
      ), // Text
    ); // Padding
  }

  Widget _buildSongCard({
    required String title,
    required String artist,
    required String imageUrl,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF263D4A),
          borderRadius: BorderRadius.circular(10),
        ), // BoxDecoration
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFF1E3746),
              ), // BoxDecoration
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.music_note, color: Colors.white),
                      ), // Image.network
                    ) // ClipRRect
                  : const Icon(Icons.music_note, color: Colors.white),
            ), // Container
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ), // TextStyle
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ), // Text
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ), // Text
                ],
              ), // Column
            ), // Expanded
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF8282)),
              onPressed: onDelete,
            ), // IconButton
          ],
        ), // Row
      ), // Container
    ); // InkWell
  }
}

class PesquisaMusicaPlaylistDelegate extends SearchDelegate<void> {
  final String playlistId;
  final DatabaseService databaseService;
  final LastFmService _lastFmService = LastFmService();

  PesquisaMusicaPlaylistDelegate({
    required this.playlistId,
    required this.databaseService,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E3746),
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
      ),
      textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.white)),
    );
  }

  @override
  String get searchFieldLabel => 'Pesquisar música...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _construirResultados(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Container(
        color: const Color(0xFF1E3746),
        child: const Center(
          child: Text(
            'Escreve o nome de uma música',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return _construirResultados(context);
  }

  Widget _construirResultados(BuildContext context) {
    return Container(
      color: const Color(0xFF1E3746),
      child: FutureBuilder<List<Music>>(
        future: _lastFmService.searchTracks(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8282)),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum resultado.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final results = snapshot.data!;
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final music = results[index];
              return ListTile(
                leading: music.imageUrl.isNotEmpty
                    ? Image.network(
                        music.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 50,
                      ),
                title: Text(
                  music.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  music.artist,
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () => _mostrarDialogoConfirmacao(context, music),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDialogoConfirmacao(BuildContext context, Music music) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF263D4A),
        title: const Text(
          'Adicionar à Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Queres adicionar "${music.name}" de ${music.artist} a esta lista?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8282),
            ),
            onPressed: () async {
              final musicaData = {
                'id': music.id,
                'name': music.name,
                'artist': music.artist,
                'album': music.album,
                'imageUrl': music.imageUrl,
              };

              await databaseService.adicionarMusicaAPlaylist(
                playlistId,
                musicaData,
              );

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) close(context, null);
            },
            child: const Text(
              'Adicionar',
              style: TextStyle(color: Color(0xFFF3E3B6)),
            ),
          ),
        ],
      ),
    );
  }
}
