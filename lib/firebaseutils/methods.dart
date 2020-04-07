import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopcorona/models/shopdetailsmodel.dart';

class FirebaseMethods {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;

  Future<bool> isLogged() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print(user != null);
    return user != null;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }

  Future<FirebaseUser> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken);

    AuthResult result = await _auth.signInWithCredential(credential);
    FirebaseUser user = result.user;
    return user;
  }

  void saveCustomerData(FirebaseUser user) async {
    _firestore.collection('customer').document(user.uid).setData({
      "name": user.displayName,
      "uid": user.uid,
      "email": user.email,
      "profile": user.photoUrl
    }, merge: true);
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('isCustomer', "true");
  }

  void saveShopkeeperData(ShopDetailsModel details, FirebaseUser user) async {
    Firestore.instance.collection('shopkeeper').document(user.uid).setData({
      "name": user.displayName,
      "mobile": details.mobile,
      "shopName": details.shopName,
      "email": user.email,
      "uid": user.uid,
      "profile": user.photoUrl
    }, merge: true).then((data) {
      print("Saved done");
    }).catchError((error) {
      print("Error Got");
      print(error);
    });
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('isCustomer', "false");
    _prefs.setString('shop', details.shopName);
    _prefs.setString('uid', user.uid);
  }

  Future<void> signOutApp() async {
    return await _auth.signOut();
  }
}
