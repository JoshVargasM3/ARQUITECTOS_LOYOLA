class FirestoreCollections {
  static const users = 'users';
  static const projects = 'projects';
  static const photos = 'photos';
  static const videos = 'videos';
  static const plans = 'plans';
  static const comments = 'comments';
  static const inventory = 'inventory';
  static const operationalCosts = 'operationalCosts';
}

enum UserRole { client, architect }

enum ProjectStatus { active, onHold, finished }

String projectStatusLabel(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.active:
      return 'Activo';
    case ProjectStatus.onHold:
      return 'En espera';
    case ProjectStatus.finished:
      return 'Finalizado';
  }
}
