class PlanDocument {
  final String id;
  final String name;
  final String section;
  final String description;
  final String fileUrl;
  final int order;

  PlanDocument({
    required this.id,
    required this.name,
    required this.section,
    required this.description,
    required this.fileUrl,
    required this.order,
  });

  factory PlanDocument.fromMap(String id, Map<String, dynamic> data) {
    return PlanDocument(
      id: id,
      name: data['name'] ?? '',
      section: data['section'] ?? '',
      description: data['description'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      order: (data['order'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'section': section,
      'description': description,
      'fileUrl': fileUrl,
      'order': order,
    };
  }
}
