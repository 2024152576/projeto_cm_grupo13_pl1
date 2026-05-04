import 'package:flutter/material.dart';
import 'Screens/splash_screen.dart';
import 'Screens/write_review.dart';

void main() {
  runApp(const MinhaApp());
}

class MinhaApp extends StatelessWidget {
  const MinhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Decibel',
      home: const SplashScreen(),
    );
  }
}