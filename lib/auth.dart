import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final AuthService authService = AuthService();

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<FirebaseUser> get currentUser async {
    return await _auth.currentUser();
  }

  Stream<String> get onAuthStateChanged {
    return _auth.onAuthStateChanged.map((u) => u?.uid);
  }

  Future<void> signOut() async {
    _auth.signOut();
  }

  Future<AuthCredential> getGoogleCredential() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleUser.authentication;

    return GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
  }

  Future<FirebaseUser> googleSignIn() async {
    AuthCredential credential = await getGoogleCredential();
    return (await _auth.signInWithCredential(credential)).user;
  }
}
