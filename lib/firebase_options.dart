// File generated for Firebase project consulta-cnpj-1196c.
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
    apiKey: 'AIzaSyBBfqtCtitG5vjRVjlZyZXXKAOiD-sReko',
    appId: '1:894074953486:android:c5f731d097e0c0e777c15f',
    messagingSenderId: '894074953486',
    projectId: 'consulta-cnpj-1196c',
    storageBucket: 'consulta-cnpj-1196c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsKJgq3rFE4r-1mCIn5WBoOdg73fv537A',
    appId: '1:894074953486:ios:1e568cda28db338677c15f',
    messagingSenderId: '894074953486',
    projectId: 'consulta-cnpj-1196c',
    storageBucket: 'consulta-cnpj-1196c.firebasestorage.app',
    iosBundleId: 'br.com.cgy.consultaCnpjEmpresas',
  );
}
