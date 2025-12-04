import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String address;
  final int estimatedDurationWeeks;
  final DateTime? startDate;
  final DateTime? estimatedEndDate;
  final DateTime updatedAt;
  final DateTime? createdAt;

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
    required this.address,
    required this.estimatedDurationWeeks,
    required this.startDate,
    required this.estimatedEndDate,
    required this.updatedAt,
    required this.createdAt,
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

    DateTime? _toDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return (value as Timestamp?)?.toDate();
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
      address: data['address'] ?? '',
      estimatedDurationWeeks: (data['estimatedDurationWeeks'] ?? 0).toInt(),
      startDate: _toDate(data['startDate']),
      estimatedEndDate: _toDate(data['estimatedEndDate']),
      updatedAt: _toDate(data['updatedAt']) ?? DateTime.now(),
      createdAt: _toDate(data['createdAt']),
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
      'address': address,
      'estimatedDurationWeeks': estimatedDurationWeeks,
      'startDate': startDate,
      'estimatedEndDate': estimatedEndDate,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
    };
  }
}
