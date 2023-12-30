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
    apiKey: 'AIzaSyDimvKDSxskVOB7--ydIY1CfhecOb6KTZU',
    appId: '1:21299527249:web:cdcc0492f9be5931050270',
    messagingSenderId: '21299527249',
    projectId: 'rogers-dictionary',
    authDomain: 'rogers-dictionary.firebaseapp.com',
    storageBucket: 'rogers-dictionary.appspot.com',
    measurementId: 'G-K952Z8ZF1B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARaKsLsyO8P5gBnD-lqrYlg01IYX2_NI4',
    appId: '1:21299527249:android:7329620e08c608ce050270',
    messagingSenderId: '21299527249',
    projectId: 'rogers-dictionary',
    storageBucket: 'rogers-dictionary.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrMe3H5z6mx9ufe932XHEHRhHU7MgU9ko',
    appId: '1:21299527249:ios:bc375a58d761da74050270',
    messagingSenderId: '21299527249',
    projectId: 'rogers-dictionary',
    storageBucket: 'rogers-dictionary.appspot.com',
    iosClientId: '21299527249-vqchmvc22cbq4sgembvk1v1u39re5oe5.apps.googleusercontent.com',
    iosBundleId: 'com.rogers.dictionary',
  );
}
