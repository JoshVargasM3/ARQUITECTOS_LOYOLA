import '../core/constants.dart';

class Project {
  final String id;
  final String clientId;
  final String projectName;
  final String description;
  final ProjectStatus status;
  final double progressPercent;
  final double budgetTotal;
  final double budgetUsed;
  final bool isActive;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.clientId,
    required this.projectName,
    required this.description,
    required this.status,
    required this.progressPercent,
    required this.budgetTotal,
    required this.budgetUsed,
    required this.isActive,
    required this.updatedAt,
  });

  double get budgetRemaining => budgetTotal - budgetUsed;

  factory Project.fromMap(String id, Map<String, dynamic> data) {
    ProjectStatus status = ProjectStatus.active;
    final statusString = data['status'] as String?;
    if (statusString == 'on_hold') {
      status = ProjectStatus.onHold;
    } else if (statusString == 'finished') {
      status = ProjectStatus.finished;
    }

    return Project(
      id: id,
      clientId: data['clientId'] ?? '',
      projectName: data['projectName'] ?? '',
      description: data['description'] ?? '',
      status: status,
      progressPercent: (data['progressPercent'] ?? 0).toDouble(),
      budgetTotal: (data['budgetTotal'] ?? 0).toDouble(),
      budgetUsed: (data['budgetUsed'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      updatedAt: (data['updatedAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'projectName': projectName,
      'description': description,
      'status': switch (status) {
        ProjectStatus.onHold => 'on_hold',
        ProjectStatus.finished => 'finished',
        _ => 'active',
      },
      'progressPercent': progressPercent,
      'budgetTotal': budgetTotal,
      'budgetUsed': budgetUsed,
      'isActive': isActive,
      'updatedAt': updatedAt,
    };
  }
}
