import 'package:flutter/material.dart';
import 'package:projeto_cm_grupo13_pl1/models/playlist_model.dart';
import 'package:projeto_cm_grupo13_pl1/models/user_model.dart';
import 'package:projeto_cm_grupo13_pl1/services/database_service.dart';
import 'package:projeto_cm_grupo13_pl1/models/music.dart';
import 'package:projeto_cm_grupo13_pl1/services/lastFM_service.dart';


class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();

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
          style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8282), 
        onPressed: () {
          showSearch(
            context: context,
            delegate: PesquisaMusicaPlaylistDelegate(
              playlistId: widget.playlist.playlistId,
              databaseService: _databaseService,
            ),
          );
        },
        child: const Icon(Icons.add, color: Color(0xFFF3E3B6)),
      ),
    );
  }

  Widget _buildSongCard({required String title, required String artist, required String imageUrl}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF263D4A), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFF1E3746),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white)),
                  )
                : const Icon(Icons.music_note, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(artist, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
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

  // Estilizar a barra de pesquisa para condizer com o vosso design escuro
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
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Pesquisar música...';

  // Botão de limpar (X)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  // Botão de voltar (Seta)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // Mostra resultados quando submetes a pesquisa
  @override
  Widget buildResults(BuildContext context) => _construirResultados(context);

  // Mostra sugestões enquanto escreves
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Container(
        color: const Color(0xFF1E3746),
        child: const Center(
          child: Text('Escreve o nome de uma música', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return _construirResultados(context);
  }

  // Lógica da pesquisa e da lista de músicas
  Widget _construirResultados(BuildContext context) {
    return Container(
      color: const Color(0xFF1E3746),
      child: FutureBuilder<List<Music>>(
        future: _lastFmService.searchTracks(query), // Usa a mesma pesquisa da vossa homepage
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8282)));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum resultado.', style: TextStyle(color: Colors.white)));
          }

          final results = snapshot.data!;
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final music = results[index];
              return ListTile(
                leading: music.imageUrl.isNotEmpty
                    ? Image.network(music.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.music_note, color: Colors.white, size: 50),
                title: Text(music.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(music.artist, style: const TextStyle(color: Colors.grey)),
                onTap: () => _mostrarDialogoConfirmacao(context, music), // Abre o alerta!
              );
            },
          );
        },
      ),
    );
  }

  // O Pop-up mágico de "Adicionar ou Cancelar"
  void _mostrarDialogoConfirmacao(BuildContext context, Music music) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF263D4A),
        title: const Text('Adicionar à Playlist', style: TextStyle(color: Colors.white)),
        content: Text(
          'Queres adicionar "${music.name}" de ${music.artist} a esta lista?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Fecha só o pop-up (Cancelar)
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8282)),
            onPressed: () async {
              // Prepara os dados para o Firestore
              final musicaData = {
                'id': music.id,
                'name': music.name,
                'artist': music.artist,
                'album': music.album,
                'imageUrl': music.imageUrl,
              };

              // Guarda na base de dados
              await databaseService.adicionarMusicaAPlaylist(playlistId, musicaData);

              // Tira os ecrãs da frente de forma elegante
              if (ctx.mounted) Navigator.pop(ctx); 
              if (context.mounted) close(context, null); 
            },
            child: const Text('Adicionar', style: TextStyle(color: Color(0xFFF3E3B6))),
          ),
        ],
      ),
    );
  }
}