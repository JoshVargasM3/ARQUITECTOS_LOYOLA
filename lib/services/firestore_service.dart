import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/comment.dart';
import '../models/inventory_item.dart';
import '../models/project.dart';
import '../models/user_profile.dart';
import '../models/video.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserProfile?> fetchUserProfile(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserProfile.fromMap(doc.id, {
      ...data,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
    });
  }

  Stream<List<Project>> listenProjectsForClient(String uid) {
    return _db
        .collection(FirestoreCollections.projects)
        .where('clientId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_projectFromDoc).toList());
  }

  Stream<List<Project>> listenAllProjects() {
    return _db
        .collection(FirestoreCollections.projects)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_projectFromDoc).toList());
  }

  Stream<List<ProjectComment>> listenComments(String projectId) {
    return _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .collection(FirestoreCollections.comments)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return ProjectComment.fromMap(doc.id, {
                ...data,
                'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
              });
            }).toList());
  }

  Future<void> addComment({
    required String projectId,
    required String userId,
    required String fromRole,
    required String message,
  }) async {
    await _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .collection(FirestoreCollections.comments)
        .add({
      'userId': userId,
      'fromRole': fromRole,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<InventoryItem>> listenInventory(String projectId) {
    return _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .collection(FirestoreCollections.inventory)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return InventoryItem.fromMap(doc.id, {
                ...data,
                'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
              });
            }).toList());
  }

  Stream<List<ProjectVideo>> listenVideos(String projectId) {
    return _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .collection(FirestoreCollections.videos)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return ProjectVideo.fromMap(doc.id, {
                ...data,
                'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
              });
            }).toList());
  }

  Project _projectFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Project.fromMap(doc.id, {
      ...data,
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
    });
  }
}
