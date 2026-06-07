import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import '../utils/profile_constants.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<bool> profileExists(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists;
  }

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<void> createProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).set(data);
    await _db.collection('likes').doc(uid).set({
      'liked': <String>[],
      'passed': <String>[],
    });
  }

  Stream<UserProfile?> watchMyProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  Future<void> updateProfile(
    String uid, {
    required String name,
    required int age,
    required String avgPace,
    required List<String> preferredTime,
    required String runStyle,
    required String photoUrl,
    String? paceVerifyPhotoUrl,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'age': age,
      'avgPace': avgPace,
      'preferredTime': preferredTime,
      'runStyle': runStyle,
      'photoUrl': photoUrl,
    };
    if (paceVerifyPhotoUrl != null) {
      data['paceVerifyPhotoUrl'] = paceVerifyPhotoUrl;
    }
    await _users.doc(uid).update(data);
  }

  Stream<List<UserProfile>> watchDiscoverableUsers(String currentUid) {
    return _users
        .where('status', isEqualTo: 'active')
        .where('paceTemp', isGreaterThan: ProfileConstants.paceTempDiscoveryMin)
        .snapshots()
        .map((snap) => snap.docs
            .where((d) => d.id != currentUid)
            .map(UserProfile.fromFirestore)
            .toList());
  }
}
