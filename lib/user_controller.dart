import 'dart:async';

import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:bulldozer/model/user_model.dart';
import 'package:bulldozer/db_main.dart';

class userController extends ControllerMVC {

  factory userController([StateMVC? state]) =>
      _this ??= userController._(state);

  userController._(StateMVC? state)
      : _tb_user = tb_user(),
        super(state);

  final tb_user _tb_user;
  static userController? _this;

  String? get getEmail => _tb_user.u_email;
  String? get getPw => _tb_user.u_pw;
  String? get getAt => _tb_user.u_at;
  String? get getTel => _tb_user.u_tel;

  final List<tb_user> users = [];

  // tb_user 객체에 결과를 담음
  Future<void> loadData() async {
    await DBConn('select * from tb_user');
    users.clear();

    // tb_user 객체 리스트로 변환
    for (int i = 0; i < res.length; i++) {
      if (res[i].isNotEmpty) {
        tb_user user = tb_user();
        user.setEmail = res[i][0] as String?;
        user.setPw = res[i][1] as String?;
        user.setAt = res[i][2] as String?;
        user.setTel = res[i][3] as String?;
        users.add(user);
      }
    }
  }

  // 임시코드-추가
  Future<void> insertM() async{
    await DBConn("INSERT INTO tb_user (u_email, u_pw, u_at, u_tel) VALUES ('u_email 011', 'u_pw 011', NOW(), 'u_tel 011');");
  }

  // 임시코드-삭제
  Future<void> deleteM() async{
    await DBConn('delete from tb_user where u_email="u_email 011";');
  }

  // 임시코드-수정
  Future<void> updateM() async{
    await DBConn('update tb_user set u_email="u_email 008" where u_email="DB유"');
  }

  // 로그인
  Future<void> login(String email, String pw) async{
    await DBConn('select u_pw from tb_user where u_email="${email}"');
  }

  // 특정 인덱스의 tb_user 객체를 가져오는 getter
  tb_user? getUser(int index) {
    if (index >= 0 && index < users.length) {
      return users[index];
    }
  }
}