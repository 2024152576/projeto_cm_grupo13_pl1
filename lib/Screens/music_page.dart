import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/music.dart';
import '../models/review_model.dart';
import '../services/database_service.dart';
import 'write_review.dart';

class MusicPage extends StatefulWidget {
  final Music music;

  const MusicPage({
    super.key,
    required this.music,
  });

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final DatabaseService _databaseService = DatabaseService();
  ReviewModel? _userReview;
  bool _isLoadingReview = true;
  String _ordemAtual = 'Recentes'; // Opções: 'Recentes', 'Antigas', 'Melhor Avaliação', 'Pior Avaliação'

  @override
  void initState() {
    super.initState();
    _checkExistingReview();
  }

  Future<void> _checkExistingReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final review = await _databaseService.obterReviewUtilizadorMusica(
        user.uid,
        widget.music.id,
      );
      if (mounted) {
        setState(() {
          _userReview = review;
          _isLoadingReview = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingReview = false);
    }
  }

  void _navigateToWriteReview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteReviewScreen(
          songId: widget.music.id,
          songTitle: widget.music.name,
          artist: widget.music.artist,
          albumImagePath: widget.music.imageUrl.isNotEmpty
              ? widget.music.imageUrl
              : 'assets/Covers/default.jpg',
          reviewExistente: _userReview,
        ),
      ),
    );

    if (result == true) {
      _checkExistingReview();
    }
  }

  // Lógica de ordenação das reviews
  List<ReviewModel> _ordenarReviews(List<ReviewModel> reviews) {
    final listaOrdenada = List<ReviewModel>.from(reviews);
    switch (_ordemAtual) {
      case 'Recentes':
        listaOrdenada.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'Antigas':
        listaOrdenada.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'Melhor Avaliação':
        listaOrdenada.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Pior Avaliação':
        listaOrdenada.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    return listaOrdenada;
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF18384B);
    const yellowColor = Color(0xFFF5D98E);
    const pinkColor = Color(0xFFFF7D7D);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text("Decibel", style: TextStyle(color: yellowColor, fontSize: 26, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 48), // Espaçador para equilibrar o back button
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info da Música
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.music.name, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.music.artist, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                          const SizedBox(height: 20),
                          Text("Listeners", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                          Text(widget.music.listeners, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.music.imageUrl.isNotEmpty
                          ? Image.network(widget.music.imageUrl, width: 130, height: 130, fit: BoxFit.cover)
                          : Container(width: 130, height: 130, color: Colors.black26, child: const Icon(Icons.music_note, color: Colors.white, size: 50)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const TabBar(
                indicatorColor: pinkColor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: [Tab(text: "Comunidade"), Tab(text: "Amigos")],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildCommunityTab(),
                    const Center(child: Text("Atividade dos amigos em breve", style: TextStyle(color: Colors.white70))),
                  ],
                ),
              ),

              // Botão Inferior
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isLoadingReview ? null : _navigateToWriteReview,
                    child: _isLoadingReview
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_userReview != null ? "Editar Review" : "Adicionar Review",
                            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityTab() {
    return Column(
      children: [
        // Menu de Ordenação
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Reviews", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _ordemAtual,
                dropdownColor: const Color(0xFF263D4A),
                icon: const Icon(Icons.sort, color: Color(0xFFF5D98E)),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: ['Recentes', 'Antigas', 'Melhor Avaliação', 'Pior Avaliação']
                    .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() => _ordemAtual = newValue!);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ReviewModel>>(
            stream: _databaseService.obterReviewsMusica(widget.music.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Sem reviews ainda. Sê o primeiro!", style: TextStyle(color: Colors.white54)));
              }

              final reviews = _ordenarReviews(snapshot.data!);

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final r = reviews[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(r.userName, style: const TextStyle(color: Color(0xFFF5D98E), fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, color: const Color(0xFFFF7D7D), size: 14)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(DateFormat('dd MMM yyyy').format(r.timestamp), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 10),
                        Text(r.fullReviewText, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}