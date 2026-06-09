class UserModel {
  final String userId; 
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final int reviewsCount;
  final int followersCount;
  final List<Map<String, String>> favoriteArtists;
  final List<Map<String, String>> favoriteSongs;

  UserModel({
    required this.userId, 
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.reviewsCount = 0,
    this.followersCount = 0,
    this.favoriteArtists = const [],
    this.favoriteSongs = const [],
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Utilizador';
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'username': username.startsWith('@') ? username : '@$username',
      'email': email,
      'followersCount': followersCount,
      'reviewsCount': reviewsCount,
      'favoriteArtists': favoriteArtists,
      'favoriteSongs': favoriteSongs,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '', 
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      reviewsCount: map['reviewsCount'] ?? 0,
      followersCount: map['followersCount'] ?? 0,
      favoriteArtists: List<Map<String, dynamic>>.from(map['favoriteArtists'] ?? [])
          .map((e) => e.map((key, value) => MapEntry(key, value.toString())))
          .toList(),
      favoriteSongs: List<Map<String, dynamic>>.from(map['favoriteSongs'] ?? [])
          .map((e) => e.map((key, value) => MapEntry(key, value.toString())))
          .toList(),
    );
  }
}