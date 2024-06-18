import 'dart:async';

import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:bulldozer/model/UserModel.dart';
import 'package:bulldozer/db.dart';

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

  List<List<dynamic>> userList = [];

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

  // 추가
  Future<void> insertM(uemail,upw,utel) async{
    await DBConn("INSERT INTO tb_user (u_email, u_pw, u_tel) VALUES ('${uemail}', '${upw}', '${utel}');");
  }
  // 조회
  Future<bool> selectM(String email) async{
    await DBConn("SELECT u_email FROM tb_user where u_email='${email}'");
    users.clear();
    for (int i = 0; i < res.length; i++) {
      if (res[i].isNotEmpty) {
        tb_user user = tb_user();
        user.setEmail = res[i][0] as String?;
        users.add(user);
      }
    }
    return users.length!=0? true : false;
  }

  // 로그인
  Future<void> login(String email, String pw) async{
    await DBConn('select u_email, u_tel from tb_user where u_email="${email}" and u_pw="${pw}"');
  }

  // admin 제외 가져오기
  Future<void> list() async{
    await DBConn('select u_email, u_pw, u_at, u_tel from tb_user where u_email !="admin" group by u_email, u_pw, u_at, u_tel;');

  }

  // 특정 인덱스의 tb_user 객체를 가져오는 getter
  tb_user? getUser(int index) {
    if (index >= 0 && index < users.length) {
      return users[index];
    }
  }
}