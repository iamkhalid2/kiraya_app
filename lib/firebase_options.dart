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
    apiKey: 'AIzaSyCUFAeAEtvtOIEfS90y9BCMIP0-rfhNBfI',
    appId: '1:190795649881:web:a71cce6ce8fb93c807f248',
    messagingSenderId: '190795649881',
    projectId: 'kiraya-8948a',
    authDomain: 'kiraya-8948a.firebaseapp.com',
    storageBucket: 'kiraya-8948a.firebasestorage.app',
    measurementId: 'G-V14HMRSGYB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVsXtXNk-nW-7ls7cOXFZhvSO-G2JC-Bk',
    appId: '1:190795649881:android:4b8f3a84b239237207f248',
    messagingSenderId: '190795649881',
    projectId: 'kiraya-8948a',
    storageBucket: 'kiraya-8948a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAw4GctyK2uK-6nGwiaxsOGGxTl-EamzM',
    appId: '1:190795649881:ios:1037759e7cfe969f07f248',
    messagingSenderId: '190795649881',
    projectId: 'kiraya-8948a',
    storageBucket: 'kiraya-8948a.firebasestorage.app',
    androidClientId: '190795649881-g8886kerods1aq8lq1igum8p695sv4fc.apps.googleusercontent.com',
    iosClientId: '190795649881-klannq885jh62ej2j3pljqh18pk2vqdd.apps.googleusercontent.com',
    iosBundleId: 'com.example.kiraya',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBAw4GctyK2uK-6nGwiaxsOGGxTl-EamzM',
    appId: '1:190795649881:ios:1037759e7cfe969f07f248',
    messagingSenderId: '190795649881',
    projectId: 'kiraya-8948a',
    storageBucket: 'kiraya-8948a.firebasestorage.app',
    androidClientId: '190795649881-g8886kerods1aq8lq1igum8p695sv4fc.apps.googleusercontent.com',
    iosClientId: '190795649881-klannq885jh62ej2j3pljqh18pk2vqdd.apps.googleusercontent.com',
    iosBundleId: 'com.example.kiraya',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCUFAeAEtvtOIEfS90y9BCMIP0-rfhNBfI',
    appId: '1:190795649881:web:c4830853ab16a1fb07f248',
    messagingSenderId: '190795649881',
    projectId: 'kiraya-8948a',
    authDomain: 'kiraya-8948a.firebaseapp.com',
    storageBucket: 'kiraya-8948a.firebasestorage.app',
    measurementId: 'G-SCP6V1106E',
  );
}
