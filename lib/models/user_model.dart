class UserModel {
  final String userId; 
  final String firstName;
  final String lastName;
  final String username;
  final String email;

  UserModel({
    required this.userId, 
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
  });

  // Converte os dados do utilizador para um Mapa (JSON) para enviar para o Firestore
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

  // Cria um UserModel a partir de um documento do Firestore
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