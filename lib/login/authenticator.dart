// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_results.dart';
import 'constants/constants.dart';
import 'user_id.dart';

class Authenticator {
  Authenticator();
  FirebaseAuth auth = FirebaseAuth.instance;
  UserId? get userId => auth.currentUser?.uid; //permet de récuperer l'id
  //de l'utilisateur courant
  String? get phoneNumber => auth.currentUser?.phoneNumber;

  ///(pour avoir le numéro de téléphone de l'utilisateur courrant)

  bool get isAlreadyLoggedIn => userId != null;
  String get displayName => auth.currentUser?.displayName ?? 'Entrer votre nom';
  String? get email => auth.currentUser?.email;

// login with phone number  attribute
  String userNumber = '';
  var receivedID = '';
  var otpFieldVisibility = false;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
//end login with phone number  attribute
  Future<void> logOut() async {
    await auth.signOut();
    await GoogleSignIn().signOut();
  }

  Future<AuthResult> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [Constants.emailScope],
    );
    final signInAccount = await googleSignIn.signIn();
    if (signInAccount == null) {
      return AuthResult.failure;
    }

    final googleAuth = await signInAccount.authentication;
    final oauthCredentials = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    try {
      await auth.signInWithCredential(oauthCredentials);
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  //login with Phone number
  void verifyUserPhoneNumber() {
    auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then(
              (value) => print('Logged In Successfully'),
            );
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        receivedID = verificationId;
        otpFieldVisibility = true;
        //setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTPCode() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: receivedID,
      smsCode: otpController.text,
    );
    await auth
        .signInWithCredential(credential)
        .then((value) => print('User Login In Successful'));
  }
}
