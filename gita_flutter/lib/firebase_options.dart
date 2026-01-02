import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA7YK1QsC6HnYrzSuO9lZr71FlOIczsI00',
    appId: '1:130647293969:android:6915c0d6d82fe5e04cf1b0',
    messagingSenderId: '130647293969',
    projectId: 'gita-58861',
    storageBucket: 'gita-58861.firebasestorage.app',
  );

  // iOS config - placeholder, needs to be updated with real values from GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA7YK1QsC6HnYrzSuO9lZr71FlOIczsI00',
    appId: '1:130647293969:ios:PLACEHOLDER',
    messagingSenderId: '130647293969',
    projectId: 'gita-58861',
    storageBucket: 'gita-58861.firebasestorage.app',
    iosBundleId: 'com.schepor.gita',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA7YK1QsC6HnYrzSuO9lZr71FlOIczsI00',
    appId: '1:130647293969:ios:PLACEHOLDER',
    messagingSenderId: '130647293969',
    projectId: 'gita-58861',
    storageBucket: 'gita-58861.firebasestorage.app',
    iosBundleId: 'com.schepor.gita',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA7YK1QsC6HnYrzSuO9lZr71FlOIczsI00',
    appId: '1:130647293969:web:PLACEHOLDER',
    messagingSenderId: '130647293969',
    projectId: 'gita-58861',
    storageBucket: 'gita-58861.firebasestorage.app',
    authDomain: 'gita-58861.firebaseapp.com',
  );
}
