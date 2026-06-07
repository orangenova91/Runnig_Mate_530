import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadUserImage({
    required String uid,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref().child('users/$uid/$fileName');
    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=3600',
      ),
    );
    return ref.getDownloadURL();
  }

  Future<Uint8List?> downloadImage({required String storagePath}) async {
    return _storage.ref(storagePath).getData(10 * 1024 * 1024);
  }
}
