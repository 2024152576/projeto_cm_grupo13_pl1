class Music {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String listeners;
  final String imageUrl;

  Music({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.listeners,
    required this.imageUrl,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    String image = '';

    if (json['album'] != null &&
        json['album']['image'] != null &&
        (json['album']['image'] as List).isNotEmpty) {
      image = json['album']['image'].last['#text'] ?? '';
    }

    return Music(
      id: json['mbid'] ?? '${json['artist']?['name'] ?? json['artist']?.toString() ?? ''}_${json['name'] ?? ''}',
      name: json['name'] ?? '',
      artist: json['artist']?['name'] ??
          json['artist']?.toString() ??
          '',
      album: json['album']?['title'] ?? '',
      listeners: json['listeners'] ?? '0',
      imageUrl: image,
    );
  }
}