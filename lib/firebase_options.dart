// File generated for Firebase project hub-do-pj---consulta-empresas.
// Android: google-services.json | iOS: GoogleService-Info.plist
// Refresh: ./scripts/configure_firebase.sh
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDke-XEh0s2oSx-4DSMv9mwl7Tll6tG6JM',
    appId: '1:187808051701:android:b5cde34b695ffb6b4b30bc',
    messagingSenderId: '187808051701',
    projectId: 'hub-do-pj---consulta-empresas',
    storageBucket: 'hub-do-pj---consulta-empresas.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjqvvb27SlAziM5YqSTMvdsdRtdgUSkSM',
    appId: '1:187808051701:ios:4b6b0f30866ffaaf4b30bc',
    messagingSenderId: '187808051701',
    projectId: 'hub-do-pj---consulta-empresas',
    storageBucket: 'hub-do-pj---consulta-empresas.firebasestorage.app',
    iosBundleId: 'com.hubdopj.consultaempresas',
  );
}
