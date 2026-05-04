import 'package:flutter/material.dart';

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
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(image: AssetImage(widget.albumImagePath), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(widget.songTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(widget.artist, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
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
              maxLines: 6,
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
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8282),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Enviar Review', style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}