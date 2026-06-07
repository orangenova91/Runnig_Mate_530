import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/profile_constants.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    required this.avgPace,
    required this.weeklyKm,
    required this.courseName,
    required this.courseLatLng,
    required this.preferredTime,
    required this.runStyle,
    required this.paceTemp,
    required this.paceVerified,
    required this.status,
    required this.inputMethod,
    this.photoUrl = '',
    this.paceVerifyPhotoUrl = '',
  });

  final String uid;
  final String name;
  final int age;
  final String avgPace;
  final int weeklyKm;
  final String courseName;
  final GeoPoint courseLatLng;
  final List<String> preferredTime;
  final String runStyle;
  final double paceTemp;
  final bool paceVerified;
  final String status;
  final String inputMethod;
  final String photoUrl;
  final String paceVerifyPhotoUrl;

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      avgPace: data['avgPace'] as String? ?? '',
      weeklyKm: (data['weeklyKm'] as num?)?.toInt() ?? 0,
      courseName: data['courseName'] as String? ?? '',
      courseLatLng: data['courseLatLng'] as GeoPoint? ?? const GeoPoint(0, 0),
      preferredTime: List<String>.from(data['preferredTime'] ?? []),
      runStyle: data['runStyle'] as String? ?? '',
      paceTemp: (data['paceTemp'] as num?)?.toDouble() ??
          ProfileConstants.activePaceTempDefault,
      paceVerified: data['paceVerified'] as bool? ?? false,
      status: data['status'] as String? ?? 'active',
      inputMethod: data['inputMethod'] as String? ?? 'manual',
      photoUrl: data['photoUrl'] as String? ?? '',
      paceVerifyPhotoUrl: data['paceVerifyPhotoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'avgPace': avgPace,
      'weeklyKm': weeklyKm,
      'courseName': courseName,
      'courseLatLng': courseLatLng,
      'preferredTime': preferredTime,
      'runStyle': runStyle,
      'paceTemp': paceTemp,
      'paceVerified': paceVerified,
      'status': status,
      'inputMethod': inputMethod,
      'photoUrl': photoUrl,
      'paceVerifyPhotoUrl': paceVerifyPhotoUrl,
    };
  }

  static Map<String, dynamic> onboardingDefaults({
    required String name,
    required int age,
    required String avgPace,
    required List<String> preferredTime,
    required String runStyle,
    required String photoUrl,
    String paceVerifyPhotoUrl = '',
  }) {
    return {
      'name': name,
      'age': age,
      'avgPace': avgPace,
      'weeklyKm': 0,
      'courseName': '',
      'courseLatLng': const GeoPoint(37.512, 126.994),
      'preferredTime': preferredTime,
      'runStyle': runStyle,
      'paceTemp': ProfileConstants.activePaceTempDefault,
      'paceVerified': false,
      'status': 'active',
      'inputMethod': 'manual',
      'photoUrl': photoUrl,
      'paceVerifyPhotoUrl': paceVerifyPhotoUrl,
    };
  }
}
