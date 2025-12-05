// File generated for Firebase configuration
// Project: CookingApp (cookingapp-f5809)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAW9pnhW0G2wkivQ_h_p_AcUxoch5Y7PBg',
    appId: '1:118342110578:web:6aab9b58ac7895dc97e1eb',
    messagingSenderId: '118342110578',
    projectId: 'cookingapp-f5809',
    authDomain: 'cookingapp-f5809.firebaseapp.com',
    storageBucket: 'cookingapp-f5809.firebasestorage.app',
    measurementId: 'G-483PCN8VN5',
  );

  // Android config - will need google-services.json for full functionality
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAW9pnhW0G2wkivQ_h_p_AcUxoch5Y7PBg',
    appId: '1:118342110578:android:placeholder',
    messagingSenderId: '118342110578',
    projectId: 'cookingapp-f5809',
    storageBucket: 'cookingapp-f5809.firebasestorage.app',
  );

  // iOS config - will need GoogleService-Info.plist for full functionality
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAW9pnhW0G2wkivQ_h_p_AcUxoch5Y7PBg',
    appId: '1:118342110578:ios:placeholder',
    messagingSenderId: '118342110578',
    projectId: 'cookingapp-f5809',
    storageBucket: 'cookingapp-f5809.firebasestorage.app',
    iosBundleId: 'com.example.cookingapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAW9pnhW0G2wkivQ_h_p_AcUxoch5Y7PBg',
    appId: '1:118342110578:ios:placeholder',
    messagingSenderId: '118342110578',
    projectId: 'cookingapp-f5809',
    storageBucket: 'cookingapp-f5809.firebasestorage.app',
    iosBundleId: 'com.example.cookingapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAW9pnhW0G2wkivQ_h_p_AcUxoch5Y7PBg',
    appId: '1:118342110578:web:6aab9b58ac7895dc97e1eb',
    messagingSenderId: '118342110578',
    projectId: 'cookingapp-f5809',
    authDomain: 'cookingapp-f5809.firebaseapp.com',
    storageBucket: 'cookingapp-f5809.firebasestorage.app',
    measurementId: 'G-483PCN8VN5',
  );
}
