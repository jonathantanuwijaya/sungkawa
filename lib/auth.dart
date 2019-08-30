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

  void signOut() async {
    _auth.signOut();
  }

  Future<AuthCredential> _signInWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleUser.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    return credential;
  }

  Future googleSignIn() async {
    AuthCredential credential = await _signInWithGoogle();
    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    return user;
  }
}
