import 'package:flutter/material.dart';
import 'Screens/login.dart';

void main() {
  runApp(const MinhaApp());
}

class MinhaApp extends StatelessWidget {
  const MinhaApp({super.key});


  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplicação Flutter',

      home: const LoginScreen(),
    );
  }
}