// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDI0ajcWE8JGcE-9sCh0xQjbDEWCOrMfiA',
    appId: '1:1025826258995:web:0d0a8b6afd74da86dc2346',
    messagingSenderId: '1025826258995',
    projectId: 'flutter-mobile-apps-cc909',
    authDomain: 'flutter-mobile-apps-cc909.firebaseapp.com',
    storageBucket: 'flutter-mobile-apps-cc909.firebasestorage.app',
    measurementId: 'G-ERQPRRQ7HF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWCrk1vXIaeUEWjWFhO_X1P8RRV7TPC7g',
    appId: '1:1025826258995:android:c7c05f9c620bb486dc2346',
    messagingSenderId: '1025826258995',
    projectId: 'flutter-mobile-apps-cc909',
    storageBucket: 'flutter-mobile-apps-cc909.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAr9aJ0zHgV6egZU7AO01ezHznps1l1sgI',
    appId: '1:1025826258995:ios:91696aa889d51fc7dc2346',
    messagingSenderId: '1025826258995',
    projectId: 'flutter-mobile-apps-cc909',
    storageBucket: 'flutter-mobile-apps-cc909.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplicationFinalProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAr9aJ0zHgV6egZU7AO01ezHznps1l1sgI',
    appId: '1:1025826258995:ios:91696aa889d51fc7dc2346',
    messagingSenderId: '1025826258995',
    projectId: 'flutter-mobile-apps-cc909',
    storageBucket: 'flutter-mobile-apps-cc909.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplicationFinalProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDI0ajcWE8JGcE-9sCh0xQjbDEWCOrMfiA',
    appId: '1:1025826258995:web:c32ab68fdf99b023dc2346',
    messagingSenderId: '1025826258995',
    projectId: 'flutter-mobile-apps-cc909',
    authDomain: 'flutter-mobile-apps-cc909.firebaseapp.com',
    storageBucket: 'flutter-mobile-apps-cc909.firebasestorage.app',
    measurementId: 'G-7QW1XLRWTK',
  );
}
