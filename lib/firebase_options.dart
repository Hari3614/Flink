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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDZEKoGrLYzZETJFBGc4WN-AgFTRQ7U7OY',
    appId: '1:1019583087472:web:c2433fe1bee14a395985b5',
    messagingSenderId: '1019583087472',
    projectId: 'flink-71c7b',
    authDomain: 'flink-71c7b.firebaseapp.com',
    storageBucket: 'flink-71c7b.appspot.com',
    measurementId: 'G-1KSTC9KXHB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQfFgh4HvKvcHOJ2jVZgrVPQLfd2-97I0',
    appId: '1:1019583087472:android:b7a269f1994e18d95985b5',
    messagingSenderId: '1019583087472',
    projectId: 'flink-71c7b',
    storageBucket: 'flink-71c7b.appspot.com',
  );
}
