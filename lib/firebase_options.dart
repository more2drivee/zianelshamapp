

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure by running flutterfire configure again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // 🌐 Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCXQVE_J-WUwgqTRrK-l2TOrtya8bq666w",
    appId: "1:317607212441:web:7b5a70e6e7c2d91b318f08",
    messagingSenderId: "317607212441",
    projectId: "zain-elsham-51fbb",
    storageBucket: "zain-elsham-51fbb.appspot.com",
  );

  // 🤖 Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCXQVE_J-WUwgqTRrK-l2TOrtya8bq666w",
    appId: "1:317607212441:android:c4fb77f8ae6aa1e9318f08",
    messagingSenderId: "317607212441",
    projectId: "zain-elsham-51fbb",
    storageBucket: "zain-elsham-51fbb.appspot.com",
  );

  // 🍏 iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCXQVE_J-WUwgqTRrK-l2TOrtya8bq666w",
    appId: "1:317607212441:ios:bf7dc1a5f8e3e82c318f08",
    messagingSenderId: "317607212441",
    projectId: "zain-elsham-51fbb",
    storageBucket: "zain-elsham-51fbb.appspot.com",
    iosBundleId: "com.zainelsham.app",
  );
}
