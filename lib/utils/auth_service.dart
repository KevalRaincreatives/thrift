import 'package:firebase_auth/firebase_auth.dart';
import 'package:thrift/model/userss.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // create user object based on FirebaseUser
  Userss? _userFromFirebaseUser(User? user) {
    return (user != null) ? Userss(uid: user.uid) : null;
  }


  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential? result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword2(String email, String password) async {
    try {
      UserCredential? result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return e.toString();
    }
  }


  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential? result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return e.toString();
    }
  }

  //sign out
  Future signOut() async {
    try {
      // await HelperFunctions.saveUserLoggedInSharedPreference(false);
      // await HelperFunctions.saveUserEmailSharedPreference('');
      // await HelperFunctions.saveUserNameSharedPreference('');

      return await _auth.signOut().whenComplete(() async {
        print("Logged out");
        // await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
        //   print("Logged in: $value");
        // });
        // await HelperFunctions.getUserEmailSharedPreference().then((value) {
        //   print("Email: $value");
        // });
        // await HelperFunctions.getUserNameSharedPreference().then((value) {
        //   print("Full Name: $value");
        // });
      });
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}