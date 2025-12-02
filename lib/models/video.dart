class ProjectVideo {
  final String id;
  final String youtubeUrl;
  final String title;
  final String description;
  final DateTime createdAt;

  const ProjectVideo({
    required this.id,
    required this.youtubeUrl,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory ProjectVideo.fromMap(String id, Map<String, dynamic> data) {
    return ProjectVideo(
      id: id,
      youtubeUrl: data['youtubeUrl'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }
}
