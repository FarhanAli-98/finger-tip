
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//me
import 'package:ball_on_a_budget_planner/services/base_service.dart';

class AuthService extends BaseAuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FacebookLogin facebookLogin = new FacebookLogin();

   // Create storage
  final _storage = new FlutterSecureStorage();
  
  @override
  void dispose() {}

  @override
  Future<User> getCurrentUser() async{
    return firebaseAuth.currentUser;
  }

  @override
  Future<User> signInWithGoogle() async{
    final GoogleSignInAccount account = await googleSignIn.signIn();
    final GoogleSignInAuthentication authentication =
        await account.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
      accessToken: authentication.accessToken,
    );
    await firebaseAuth.signInWithCredential(authCredential);
     User user = firebaseAuth.currentUser;
     print(user.uid);
     await this._saveUserId( user.uid );
        DocumentSnapshot snapshot =
        await db.collection('Users').doc(user.uid).get();

      if (snapshot.exists) {
        if (snapshot.data()['isBlocked']) {
          await googleSignIn.signOut();
          await firebaseAuth.signOut();
          await facebookLogin.logOut();
          
          print( 'Your account has been blocked');
        }
      } 
    
    return firebaseAuth.currentUser;
  }

   @override
  Future<User> signInWitFacebook() async{
    final FacebookLoginResult facebookLoginResult = await facebookLogin.logIn(['email', 'public_profile']);
      if(facebookLoginResult.status == FacebookLoginStatus.cancelledByUser){
        print( 'cancel by user');
        return null;
      } else if(facebookLoginResult.status == FacebookLoginStatus.error){
        print( 'error');
        return null;
      }else {
        try {
          if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
            FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
            final AuthCredential credential = FacebookAuthProvider.credential(facebookAccessToken.token);
            await firebaseAuth.signInWithCredential(credential);
            print('here');
            User user = firebaseAuth.currentUser;
            DocumentSnapshot snapshot =
            await db.collection('Users').doc(user.uid).get();
            if (snapshot.exists) {
              if (snapshot.data()['isBlocked']) {
                await googleSignIn.signOut();
                await firebaseAuth.signOut();
                print( 'Your account has been blocked');
              }
            } 
          await this._saveUserId( user.uid );
          return user;
            
          }
        } catch (e) {
          print(e);
          return null;
        }

      } 
      return null;
  }

  @override
  Future<User> signInWithApple() {
  
    throw UnimplementedError();
  }

  @override
  Future<bool> checkIfSignedIn() async{
    final user = firebaseAuth.currentUser;
    
    print(user.email);
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> signOutUser()async {
    try {
      Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
        this.logOut()
      ]);

      return true;
    } catch (e) {
      return false;
    }
  }


  @override
  Future signInWithEmail(String email, String password) async{
     try {
      UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      if (authResult.user != null) {
       await this._saveUserId( authResult.user.uid );
        return authResult.user;
      } 
    } catch (e) {
      print(e);
      return e.code;
    }
  }

  @override
  Future signUpWithEmail(String userName, String email, String password )async {
    String photoUrl = "https://res.cloudinary.com/manidevs/image/upload/v1583175320/img_user_template_smqb3m.jpg";
    try {
      UserCredential authResult = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: email, password: password);
      User user;
      await this._saveUserId( authResult.user.uid );
      if (authResult.user != null)  {
        user = authResult.user;
        await user.updateProfile(
          displayName: userName,
          photoURL: photoUrl
        );
        authResult.user.uid;
        return user;
      }   
    } catch (e) {
      print(e);
      return e.code;
    }
  }
  
  @override
  Future<bool> resetEmail(String email) async{
     try {
       await firebaseAuth
          .sendPasswordResetEmail(email: email)
          .then((result) {
          return true;
      }).catchError((e) {
        print(e);
         return false;
      });
    } catch (e) {
       print(e);
         return false;
    }
    return false;
    
  }

  Future _saveUserId( String userId ) async {

    // Write value 
    await _storage.write(key: 'userId', value: userId);
    return;

  }

  Future logOut() async {
    // Delete value 
    await _storage.delete(key: 'userId');

  }

  //static getters U
  static Future<String> getUserId() async {
    final _storage = new FlutterSecureStorage();
    final userId = await _storage.read(key: 'userId');
    return userId;
  }

}