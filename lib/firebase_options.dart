// Firebase 설정 파일 — 아래 명령으로 자동 생성하세요:
//
//   dart pub global activate flutterfire_cli
//   cd "/Users/joohyueun.park/Documents/Cursor/Runnig Date"
//   flutterfire configure --project=running-date-2ee0d
//
// 생성 전까지는 앱이 Firebase 초기화에서 실패합니다.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform. '
          'Run: flutterfire configure --project=running-date-2ee0d',
        );
    }
  }

  // flutterfire configure 실행 후 이 파일이 자동으로 덮어씌워집니다.

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBP3he1BfMziuJ6obCkTB-3ox3M5pkEfMc',
    appId: '1:338782901754:web:301365997ccd6289000043',
    messagingSenderId: '338782901754',
    projectId: 'running-date-2ee0d',
    authDomain: 'running-date-2ee0d.firebaseapp.com',
    storageBucket: 'running-date-2ee0d.firebasestorage.app',
    measurementId: 'G-HJTPQRJWE7',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'running-date-2ee0d',
    storageBucket: 'running-date-2ee0d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'running-date-2ee0d',
    storageBucket: 'running-date-2ee0d.firebasestorage.app',
    iosBundleId: 'com.runningdate.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'running-date-2ee0d',
    storageBucket: 'running-date-2ee0d.firebasestorage.app',
    iosBundleId: 'com.runningdate.app',
  );
}
