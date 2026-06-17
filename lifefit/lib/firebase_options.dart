import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase config for lifefit-c452f (Android + Web).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for $defaultTargetPlatform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAqdGMHhIU7_XebfIo4DFJ_DRhXX5PSeBI',
    appId: '1:370880291653:web:e56364dbfdb4018f85142c',
    messagingSenderId: '370880291653',
    projectId: 'lifefit-c452f',
    authDomain: 'lifefit-c452f.firebaseapp.com',
    storageBucket: 'lifefit-c452f.firebasestorage.app',
    measurementId: 'G-99QJFPJ50R',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDnhM8-IEmpufAtV_ibF5apu0ljUv065vE',
    appId: '1:370880291653:android:29c89906edc26b2185142c',
    messagingSenderId: '370880291653',
    projectId: 'lifefit-c452f',
    storageBucket: 'lifefit-c452f.firebasestorage.app',
  );
}
