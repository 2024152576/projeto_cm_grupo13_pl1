import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'homepage.dart'; // Import da tua página principal

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // 1. Controladores para ler o que o utilizador escreve
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false; // Para mostrar um loading no botão

  @override
  void dispose() {
    // Limpar controladores da memória ao sair do ecrã
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submeterRegisto() async {
    // Validações básicas antes de enviar ao Firebase
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _mostrarErro('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _mostrarErro('As palavras-passe não coincidem.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      var user = await _authService.registrarComEmailEPalavraPasse(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (user != null && mounted) {
        // Registo com sucesso! Vai para a HomePage e limpa a pilha de ecrãs
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainFeedScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) _mostrarErro(e.toString().replaceAll(RegExp(r'\[.*\]'), '')); // Limpa o formato de erro do Firebase
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3746),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF3E3B6)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Criar Conta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF3E3B6),
              ),
            ),
            const SizedBox(height: 40),

            _campoTexto('Primeiro Nome', _firstNameController),
            const SizedBox(height: 20),
            _campoTexto('Último Nome', _lastNameController),
            const SizedBox(height: 20),
            _campoTexto('Nome de utilizador', _usernameController),
            const SizedBox(height: 20),
            _campoTexto('Email', _emailController),
            const SizedBox(height: 20),
            _campoTexto('Palavra-passe', _passwordController, obscure: true),
            const SizedBox(height: 20),
            _campoTexto('Confirmar Palavra-passe', _confirmPasswordController, obscure: true),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _isLoading ? null : _submeterRegisto,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8282),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFF3E3B6))
                  : const Text(
                      'Criar Conta',
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

  // Atualizámos a função para receber o respetivo controlador
  Widget _campoTexto(String hint, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF323232),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}