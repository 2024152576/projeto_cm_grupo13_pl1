class Artist {
  final String name;
  final String bio;
  final String imageUrl;
  final String listeners;

  Artist({
    required this.name,
    required this.bio,
    required this.imageUrl,
    required this.listeners,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'] ?? '',
      bio: json['bio']?['summary'] ?? '',
      listeners: json['stats']?['listeners'] ?? '0',
      imageUrl: json['image'] != null &&
          (json['image'] as List).isNotEmpty
          ? json['image'].last['#text'] ?? ''
          : '',
    );
  }
}