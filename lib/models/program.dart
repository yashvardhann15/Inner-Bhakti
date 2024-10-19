class Program {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<Episode> episodes;

  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.episodes,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      episodes: (json['episodes'] as List)
          .map((episode) => Episode.fromJson(episode))
          .toList(),
    );
  }
}

class Episode {
  final String title;
  final String duration;
  final String audioUrl;

  Episode({required this.title, required this.duration, required this.audioUrl});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: json['title'],
      duration: json['duration'],
      audioUrl: json['audioUrl'],
    );
  }
}