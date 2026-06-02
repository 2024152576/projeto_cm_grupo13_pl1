import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../services/database_service.dart';

class WriteReviewScreen extends StatefulWidget {
  final String songTitle;
  final String artist;
  final String albumImagePath;

  const WriteReviewScreen({
    super.key,
    required this.songTitle,
    required this.artist,
    required this.albumImagePath,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final _reviewTextController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  void _submeterReview() async {
    if (_rating == 0) {
      _mostrarMensagem('Por favor, atribua uma classificação em estrelas.');
      return;
    }
    if (_reviewTextController.text.trim().isEmpty) {
      _mostrarMensagem('Por favor, escreva a sua opinião.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Obter o utilizador atual autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilizador não autenticado.');

      // 2. Procurar o nome do utilizador no Firestore para associar à Review
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final firstName = userDoc.data()?['firstName'] ?? 'Utilizador';

      // 3. Gerar um ID único para a review
      final reviewId = FirebaseFirestore.instance.collection('reviews').doc().id;

      // 4. Construir o Modelo
      final novaReview = ReviewModel(
        reviewId: reviewId,
        userId: user.uid,
        userName: firstName,
        songTitle: widget.songTitle,
        artist: widget.artist,
        albumImagePath: widget.albumImagePath,
        rating: _rating,
        fullReviewText: _reviewTextController.text.trim(),
        timestamp: DateTime.now(),
      );

      // 5. Enviar para o DatabaseService
      await _databaseService.enviarReview(novaReview);

      if (mounted) {
        _mostrarMensagem('Review publicada com sucesso!', sucesso: true);
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) _mostrarMensagem('Erro ao enviar review: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _mostrarMensagem(String msg, {bool sucesso = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: sucesso ? Colors.green : Colors.redAccent),
    );
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
        title: const Text('Decibel', style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 26, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(widget.albumImagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.songTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.artist,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: _isSubmitting ? null : () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFF8282),
                    size: 44,
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _reviewTextController,
              maxLines: 6,
              enabled: !_isSubmitting,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escreve a tua review...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF263D4A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submeterReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8282),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Color(0xFFF3E3B6))
                    : const Text('Enviar Review', style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}