import 'package:flutter/material.dart';
import 'login.dart';
import 'homepage.dart';
import '../services/auth_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {      
      // Chamar a função do  serviço para verificar se já existe conta iniciada
      final bool loggedIn = _authService.isUserLoggedIn();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => loggedIn 
                ? const MainFeedScreen()  
                : const LoginScreen(),    
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E3746),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.album,
              size: 120,
              color: Color(0xFFF3E3B6),
            ),
            SizedBox(height: 24),

            Text(
              'Decibel',
              style: TextStyle(
                color: Color(0xFFF3E3B6),
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}