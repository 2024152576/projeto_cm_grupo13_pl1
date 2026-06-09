import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Screens/splash_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    initError = e.toString();
  }

  runApp(MinhaApp(initError: initError));

  if (initError == null && !kIsWeb) {
    unawaited(
      NotificationService.instance.initialize().catchError((_) {}),
    );
  }
}

class MinhaApp extends StatelessWidget {
  final String? initError;

  const MinhaApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Decibel',
      home: initError != null
          ? _StartupErrorScreen(error: initError!)
          : const SplashScreen(),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  final String error;

  const _StartupErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3746),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFFF8282), size: 64),
              const SizedBox(height: 24),
              const Text(
                'Erro ao iniciar a app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF3E3B6),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 24),
                const Text(
                  'Para correr no Chrome, adiciona uma app Web no Firebase Console '
                  '(Project Settings > Add app > Web) e depois corre:\n'
                  'flutterfire configure --platforms=web',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}