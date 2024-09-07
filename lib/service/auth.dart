import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  // Register
  Future<void> createUser({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //Sign out
  Future<void> signOut({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signOut();
  }

 // Google Sign-In
Future<void> signInWithGoogle() async {
  try {
    // Kullanıcının Google hesabıyla oturum açmasını sağlayın
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // Kullanıcı giriş işlemini iptal ettiğinde buraya düşer
      return;
    }

    // Google kimlik doğrulama bilgilerini alın
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Google ile elde edilen kimlik doğrulama bilgilerini kullanarak Firebase kimlik doğrulaması yapın
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase'e Google kimlik bilgileri ile giriş yapın
    await _firebaseAuth.signInWithCredential(credential);

  } on FirebaseAuthException catch (e) {
    // FirebaseAuthException oluşturulurken hem 'code' hem 'message' parametrelerini ekleyin
    throw FirebaseAuthException(
      code: e.code, // Zorunlu code parametresi
      message: e.message, // Hatanın mesajı
    );
  } catch (e) {
    // Diğer hatalar için genel bir hata mesajı atabilirsiniz
    throw Exception("Google sign-in failed: $e");
  }
}

}

