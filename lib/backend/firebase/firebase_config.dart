import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDQyx0GQTex1zAVpWFsxBV9GgC8wfKwEpE",
            authDomain: "shop-lendr3-yy2xvd.firebaseapp.com",
            projectId: "shop-lendr3-yy2xvd",
            storageBucket: "shop-lendr3-yy2xvd.firebasestorage.app",
            messagingSenderId: "1002858924332",
            appId: "1:1002858924332:web:064510fb238bb130084489"));
    
    // Enable local persistence for web to keep users logged in
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } else {
    await Firebase.initializeApp();
  }
}
