import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/comment.dart';
import '../models/inventory_item.dart';
import '../models/plan_document.dart';
import '../models/project.dart';
import '../models/project_photo.dart';
import '../models/user_profile.dart';
import '../models/video.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return (value as Timestamp?)?.toDate();
  }

  Future<UserProfile?> fetchUserProfile(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserProfile.fromMap(doc.id, {
      ...data,
      'createdAt': _toDate(data['createdAt']),
    });
  }

  Future<List<UserProfile>> fetchClients() async {
    final snapshot = await _db
        .collection(FirestoreCollections.users)
        .where('role', isEqualTo: 'client')
        .orderBy('name')
        .get();
    return snapshot.docs
        .map((doc) => UserProfile.fromMap(doc.id, {
              ...doc.data(),
              'createdAt': _toDate(doc.data()['createdAt']),
            }))
        .toList();
  }

  Stream<Project?> listenActiveProjectForClient(String uid) {
    return _db
        .collection(FirestoreCollections.projects)
        .where('clientId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.isNotEmpty ? _projectFromDoc(snapshot.docs.first) : null);
  }

  Stream<Project?> listenProject(String projectId) {
    return _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .snapshots()
        .map((doc) => doc.exists ? _projectFromDoc(doc) : null);
  }

  Stream<List<Project>> listenProjectsForClient(String uid) {
    return _db
        .collection(FirestoreCollections.projects)
        .where('clientId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_projectFromDoc).toList());
  }

  Stream<List<Project>> listenActiveProjects() {
    return _db
        .collection(FirestoreCollections.projects)
        .where('status', isEqualTo: 'active')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_projectFromDoc).toList());
  }

  Stream<List<Project>> listenAllProjects() {
    return _db
        .collection(FirestoreCollections.projects)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_projectFromDoc).toList());
  }

  Future<void> createProject({
    required String projectName,
    required String description,
    required String clientId,
    required String address,
    required double budgetTotal,
    required int estimatedDurationWeeks,
    required DateTime? startDate,
    required DateTime? estimatedEndDate,
  }) async {
    await _db.collection(FirestoreCollections.projects).add({
      'projectName': projectName,
      'description': description,
      'clientId': clientId,
      'address': address,
      'budgetTotal': budgetTotal,
      'estimatedDurationWeeks': estimatedDurationWeeks,
      'startDate': startDate,
      'estimatedEndDate': estimatedEndDate,
      'status': 'active',
      'progressPercent': 0,
      'budgetUsed': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProjectProgress({
    required String projectId,
    required double progressPercent,
  }) async {
    await _db.collection(FirestoreCollections.projects).doc(projectId).update({
          'progressPercent': progressPercent,
          'updatedAt': FieldValue.serverTimestamp(),
        });
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
                'createdAt': _toDate(data['createdAt']),
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
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return InventoryItem.fromMap(doc.id, data);
            }).toList());
  }

  Future<void> addInventoryItem({
    required String projectId,
    required InventoryItem item,
  }) async {
    await _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .collection(FirestoreCollections.inventory)
        .add({
      ...item.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateInventoryItem({
    required String projectId,
    required InventoryItem item,
  }) async {
    await _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .collection(FirestoreCollections.inventory)
        .doc(item.id)
        .update({
      ...item.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteInventoryItem({
    required String projectId,
    required String itemId,
  }) async {
    await _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .collection(FirestoreCollections.inventory)
        .doc(itemId)
        .delete();
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
                'createdAt': _toDate(data['createdAt']),
              });
            }).toList());
  }

  Stream<List<PlanDocument>> listenPlans(String projectId) {
    return _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .collection(FirestoreCollections.plans)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PlanDocument.fromMap(doc.id, doc.data())).toList());
  }

  Stream<List<ProjectPhoto>> listenPhotos(String projectId) {
    return _db
        .collection(FirestoreCollections.projects)
        .doc(projectId)
        .collection(FirestoreCollections.photos)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProjectPhoto.fromMap(doc.id, doc.data())).toList());
  }

  Project _projectFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Project.fromMap(doc.id, {
      ...data,
      'updatedAt': _toDate(data['updatedAt']),
      'createdAt': _toDate(data['createdAt']),
      'startDate': _toDate(data['startDate']),
      'estimatedEndDate': _toDate(data['estimatedEndDate']),
    });
  }
}
