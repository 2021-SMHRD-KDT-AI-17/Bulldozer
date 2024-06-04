import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


class firebaseService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static String  tempPw="temp1234";
  User? user;
  late var myemail;
  late var mypw;
  var valiEmail=false;
  void accountinfo(email,pw){
    myemail=email;
    mypw=pw;
  }

  Future<bool> isEmailChecked() async { //이메일 인증 확인
    user = _firebaseAuth.currentUser;
    print("!!!!!!");
    print(user);
    if (user != null) {
      await user!.reload();
      return user!.emailVerified;
    }
    return false;
  }
  Future<void> deleteTempUser() async { //회원 삭제
    try {
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user!.delete();
        print('User deleted successfully');
      } else {
        print('No user is signed in');
      }
    } catch (e) {
      print('Failed to delete user: $e');
    }
  }
  Future<void> signInWithVerifyEmailAndPassword(BuildContext context) async { //임시 회원 등록과 이메일 인증
    try {
      UserCredential _credential =
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: myemail, password: "a123456");
      await _credential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
    }
  }
  Future<void> createEmailAndPassword(BuildContext context) async {
    print("!!!!");
    print(_firebaseAuth.currentUser);
    if(user?.emailVerified==true){
      try {
        UserCredential _credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: myemail,
          password: mypw,
        );
        if (_credential.user != null) {
          showSnackbar(context, "User created: ${_credential.user?.email}");
        } else {
          showSnackbar(context, "Server Error");
        }
      } on FirebaseAuthException catch (error) {
        String? _errorCode;
        switch (error.code) {
          case "email-already-in-use":
            _errorCode = error.code;
            break;
          case "invalid-email":
            _errorCode = error.code;
            break;
          case "weak-password":
            _errorCode = error.code;
            break;
          case "operation-not-allowed":
            _errorCode = error.code;
            break;
          default:
            _errorCode = null;
        }
        if (_errorCode != null) {
          showSnackbar(context, _errorCode);
        }
      } catch (e) {
        print(e);
        showSnackbar(context, "An unexpected error occurred.");
      }
    }

  }
  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}