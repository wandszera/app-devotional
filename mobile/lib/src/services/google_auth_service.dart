import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleAuthService {
  Future<String> signIn();
}

class FirebaseGoogleAuthService implements GoogleAuthService {
  FirebaseGoogleAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  FirebaseAuth? _firebaseAuth;

  FirebaseAuth get _auth => _firebaseAuth ??= FirebaseAuth.instance;

  @override
  Future<String> signIn() async {
    final UserCredential credential;
    if (kIsWeb) {
      credential = await _auth.signInWithPopup(GoogleAuthProvider());
    } else if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      credential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: googleAuth.idToken),
      );
    } else {
      throw UnsupportedError(
        'O login com Google está disponível no Android, iOS e web.',
      );
    }

    final user = credential.user;
    final idToken = await user?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Não foi possível obter a identidade da conta Google.');
    }
    return idToken;
  }
}
