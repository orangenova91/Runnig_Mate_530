import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/likes_record.dart';
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

  Stream<LikesRecord> watchLikes(String uid) {
    return _db.collection('likes').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return LikesRecord.empty;
      return LikesRecord(
        liked: List<String>.from(data['liked'] ?? []),
        passed: List<String>.from(data['passed'] ?? []),
      );
    });
  }

  Future<void> likeUser(String currentUid, String targetUid) async {
    await _db.collection('likes').doc(currentUid).set({
      'liked': FieldValue.arrayUnion([targetUid]),
      'passed': FieldValue.arrayRemove([targetUid]),
    }, SetOptions(merge: true));
  }

  Future<void> passUser(String currentUid, String targetUid) async {
    await _db.collection('likes').doc(currentUid).set({
      'passed': FieldValue.arrayUnion([targetUid]),
      'liked': FieldValue.arrayRemove([targetUid]),
    }, SetOptions(merge: true));
  }

  Future<List<UserProfile>> getProfilesByIds(List<String> uids) async {
    final profiles = <UserProfile>[];
    for (final id in uids) {
      final profile = await getProfile(id);
      if (profile != null) profiles.add(profile);
    }
    return profiles;
  }

  Stream<List<UserProfile>> watchLikedProfiles(String uid) {
    return watchLikes(uid).asyncMap((likes) => getProfilesByIds(likes.liked));
  }

  Stream<List<UserProfile>> watchDiscoverableUsers(String currentUid) {
    return _users
        .where('status', isEqualTo: 'active')
        .where('paceTemp', isGreaterThan: ProfileConstants.paceTempDiscoveryMin)
        .snapshots()
        .asyncMap((snap) async {
      final likes = await _db.collection('likes').doc(currentUid).get();
      final liked = List<String>.from(likes.data()?['liked'] ?? []);
      final passed = List<String>.from(likes.data()?['passed'] ?? []);
      final excluded = {currentUid, ...liked, ...passed};

      return snap.docs
          .where((d) => !excluded.contains(d.id))
          .map(UserProfile.fromFirestore)
          .toList();
    });
  }
}
