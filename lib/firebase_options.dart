// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7Tyje8b_mKeyukRJKIukUiNVcglnCsZo',
    appId: '1:800241865184:web:3840a49b80e3d0669d9b85',
    messagingSenderId: '800241865184',
    projectId: 'location-app-cda39',
    authDomain: 'location-app-cda39.firebaseapp.com',
    storageBucket: 'location-app-cda39.firebasestorage.app',
    measurementId: 'G-2NLT23Z598',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBgpE_zGePPmAKlSbZyDtJspc3glRqrhI',
    appId: '1:800241865184:android:e55fc0a3de9a3e279d9b85',
    messagingSenderId: '800241865184',
    projectId: 'location-app-cda39',
    storageBucket: 'location-app-cda39.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrASd-t3exNhSmiorn3VzxVw2vwcpb8-I',
    appId: '1:800241865184:ios:d932c0d0756180109d9b85',
    messagingSenderId: '800241865184',
    projectId: 'location-app-cda39',
    storageBucket: 'location-app-cda39.firebasestorage.app',
    iosBundleId: 'com.example.contactApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDrASd-t3exNhSmiorn3VzxVw2vwcpb8-I',
    appId: '1:800241865184:ios:d932c0d0756180109d9b85',
    messagingSenderId: '800241865184',
    projectId: 'location-app-cda39',
    storageBucket: 'location-app-cda39.firebasestorage.app',
    iosBundleId: 'com.example.contactApp',
  );
}