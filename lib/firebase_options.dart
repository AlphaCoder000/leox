
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNVp_4-eg-QNAlAWY612osmTcOLVrcGXU',
    appId: '1:340682426505:android:922212c20eff9fb0135e58',
    messagingSenderId: '340682426505',
    projectId: 'studio-7488920972-4ef9c',
    storageBucket: 'studio-7488920972-4ef9c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAPPRBy4FNZSVA0C5n0e5f64AtuyRWeVW0',
    appId: '1:340682426505:ios:2f6d16aaa3d67028135e58',
    messagingSenderId: '340682426505',
    projectId: 'studio-7488920972-4ef9c',
    storageBucket: 'studio-7488920972-4ef9c.firebasestorage.app',
    iosBundleId: 'com.shinnovation.leox',
  );
}
