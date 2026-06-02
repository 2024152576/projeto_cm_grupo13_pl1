import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/playlist_model.dart';
import '../services/database_service.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _playlistNameController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isCreating = false;

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  void _gravarPlaylist() async {
    final nomeLista = _playlistNameController.text.trim();
    if (nomeLista.isEmpty) {
      _mostrarSnackBar('Insira um nome para a sua lista.');
      return;
    }

    setState(() => _isCreating = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilizador não autenticado.');

      final playlistId = FirebaseFirestore.instance.collection('playlists').id;

      final novaPlaylist = PlaylistModel(
        playlistId: playlistId,
        userId: user.uid,
        name: nomeLista,
        timestamp: DateTime.now(),
        songs: [], // Começa sem músicas como definido
      );

      await _databaseService.criarPlaylist(novaPlaylist);

      if (mounted) {
        _mostrarSnackBar('Lista criada com sucesso!', sucesso: true);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _mostrarSnackBar('Erro ao criar lista: $e');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _mostrarSnackBar(String msg, {bool sucesso = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: sucesso ? Colors.green : Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3746),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 220,
                height: 220,
                color: const Color(0xFFD9D9D9),
                child: const Icon(Icons.music_video, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _playlistNameController,
              enabled: !_isCreating,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nome da Lista',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF323232),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isCreating ? null : _gravarPlaylist,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8282),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isCreating
                  ? const CircularProgressIndicator(color: Color(0xFFF3E3B6))
                  : const Text(
                      'Criar Lista',
                      style: TextStyle(
                        color: Color(0xFFF3E3B6),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}