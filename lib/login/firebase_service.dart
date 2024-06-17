import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';


class firebaseService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static String tempPw="a123456";
  User? user;
  late String myemail;
  late String mypw;
  void getinfo(email,pw){
    if(email!="") myemail=email;
    if(pw!="") mypw=pw;
  }

  Future<void> deleteUser() async { //회원 삭제
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
  Future<void> createTempAccountAndVerifyEmail(BuildContext context) async { //임시 회원 등록과 이메일 인증
    print("createTemp&sendVerifyEmail");
    try {
      UserCredential _credential =
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: myemail, password: tempPw);
      await _credential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
    }
  }
  Future<bool> checkAndJoin(BuildContext context) async{ //임시 회원 삭제 및 가입

      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: myemail, password: tempPw);
      user=userCredential.user;
    bool res=false;
    if(mypw.length<6) {
      showSnackbar(context, "비밀번호를 6자 이상으로 지정해 주세요");
    }else if(user?.emailVerified==false){
      showSnackbar(context, "이메일 인증을 완료해주세요");
    }else if(user?.emailVerified==true){
      deleteUser();
      res = true;
    }
    return res;
  }

  Future<void> createEmailAndPassword(BuildContext context) async {
    print("createEmail");
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
  void showSnackbar(BuildContext context, String message) {
    Fluttertoast.showToast(msg: message);
    // final snackBar = SnackBar(content: Text(message));
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}