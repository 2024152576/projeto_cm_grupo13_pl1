/// Classe que representa o modelo de dados de um utilizador no sistema.
/// 
/// Mapeia as propriedades da entidade utilizador e fornece métodos de conversão
/// para persistência e leitura na base de dados NoSQL do Cloud Firestore.
class UserModel {
  /// Identificador único do utilizador gerado pelo Firebase Authentication ([uid]).
  final String userId; 

  /// Primeiro nome do utilizador.
  final String firstName;

  /// Apelido / Último nome do utilizador.
  final String lastName;

  /// Nome de utilizador único da rede social (ex: @rodrigo).
  final String username;

  /// Endereço de correio eletrónico associado à conta.
  final String email;

  /// Construtor padrão da classe [UserModel].
  UserModel({
    required this.userId, 
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
  });

  /// Converte a instância atual de [UserModel] para um mapa [Map<String, dynamic>].
  /// 
  /// Garante o formato chave-valor (JSON-like) necessário para submeter ao Firestore.
  /// Inclui a formatação automática do prefixo '@' no [username] e inicializa
  /// as métricas dinâmicas de contagem a zero.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'username': username.startsWith('@') ? username : '@$username',
      'email': email,
      'followersCount': 0,
      'reviewsCount': 0,
    };
  }

  /// Constrói uma nova instância de [UserModel] a partir de um mapa de dados originário do Firestore.
  /// 
  /// Utiliza operadores de coalescência nula (`??`) para prevenir erros em tempo de execução
  /// caso algum campo na base de dados se encontre nulo.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '', 
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
    );
  }
}