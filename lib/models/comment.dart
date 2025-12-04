class ProjectComment {
  final String id;
  final String userId;
  final String message;
  final String fromRole;
  final DateTime createdAt;

  const ProjectComment({
    required this.id,
    required this.userId,
    required this.message,
    required this.fromRole,
    required this.createdAt,
  });

  factory ProjectComment.fromMap(String id, Map<String, dynamic> data) {
    return ProjectComment(
      id: id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      fromRole: data['fromRole'] ?? 'client',
      createdAt: (data['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'message': message,
      'fromRole': fromRole,
      'createdAt': createdAt,
    };
  }
}
