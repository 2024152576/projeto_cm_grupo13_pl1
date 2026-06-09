import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

/// Camada de Serviço encarregue de gerir o fluxo de autenticação e contas da aplicação.
/// 
/// Abstrai a API externa do **Firebase Authentication** e correlaciona a criação do
/// utilizador com a persistência do seu perfil estendido no **Cloud Firestore**.
class AuthService {
  /// Instância interna para operações do Firebase Authentication.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Instância interna para operações na base de dados remota Cloud Firestore.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retorna o objeto [User] atualmente logado no dispositivo se existir, caso contrário retorna `null`.
  User? get currentUser => _auth.currentUser;

  /// Efetua o registo assíncrono de um novo utilizador no Firebase.
  /// 
  /// O processo divide-se em:
  /// 1. Criação das credenciais básicas com [email] e [password] no Firebase Auth.
  /// 2. Instanciação de um [UserModel] com o UID obtido.
  /// 3. Gravação definitiva do perfil do utilizador na coleção NoSQL `users` do Firestore.
  /// 
  /// Dispara excepções do tipo [FirebaseAuthException] em caso de email duplicado ou fraqueza de password.
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

  /// Realiza o login de utilizadores com base no par [email] e [password].
  /// 
  /// Retorna o objeto [User] validado ou lança erros caso as credenciais estejam erradas.
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

  /// Encerra a sessão ativa do utilizador atual no dispositivo local.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Verifica se o dispositivo possui alguma sessão ativa.
  /// 
  /// Utilizado pela Splash Screen para determinar reencaminhamento condicional rápido.
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}