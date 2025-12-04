class ProjectPhoto {
  final String id;
  final String section;
  final String title;
  final String imageUrl;
  final int order;

  ProjectPhoto({
    required this.id,
    required this.section,
    required this.title,
    required this.imageUrl,
    required this.order,
  });

  factory ProjectPhoto.fromMap(String id, Map<String, dynamic> data) {
    return ProjectPhoto(
      id: id,
      section: data['section'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      order: (data['order'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'section': section,
      'title': title,
      'imageUrl': imageUrl,
      'order': order,
    };
  }
}
