import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obter o utilizador atual logado
  User? get currentUser => _auth.currentUser;

  // FUNÇÃO 1: Criar Conta (Registo)
  Future<User?> registrarComEmailEPalavraPasse({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    try {
      // 1. Cria o utilizador no Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // 2. Cria o modelo mapeando o uid do Firebase Auth para o teu 'userId'
        UserModel novoUtilizador = UserModel(
          userId: user.uid, // O Firebase Auth continua a usar .uid, mas guardamos como userId no teu modelo
          firstName: firstName,
          lastName: lastName,
          username: username,
          email: email,
        );

        // 3. Guarda os dados na coleção 'users' do Firestore usando o UID como ID do documento
        await _db.collection('users').doc(user.uid).set(novoUtilizador.toMap());
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // FUNÇÃO 2: Fazer Login
  Future<User?> loginComEmailEPalavraPasse(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // FUNÇÃO 3: Terminar Sessão (Logout)
  Future<void> logout() async {
    await _auth.signOut();
  }
}