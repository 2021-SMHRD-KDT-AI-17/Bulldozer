import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:bulldozer/model/UserconHisModel.dart';
import 'package:bulldozer/db.dart';

class userconHisController extends ControllerMVC {

  factory userconHisController([StateMVC? state]) =>
      _this ??= userconHisController._(state);

  userconHisController._(StateMVC? state)
      : _tb_usercon_his = tb_usercon_his(),
        super(state);

  final tb_usercon_his _tb_usercon_his;
  static userconHisController? _this;

  String? get getEmail => _tb_usercon_his.u_email;
  int? get getType => _tb_usercon_his.uc_recent;
  String? get getCon => _tb_usercon_his.uc_con;
  String? get getDiscon => _tb_usercon_his.uc_discon;

  final List<tb_usercon_his> usercons = [];
  List<List<dynamic>> userConHisList = [];

  Future<void> loadData() async {
    await DBConn('select * from tb_usercon_his');
    usercons.clear();

    // tb_usercon_his 객체 리스트로 변환
    for (int i=0; i<res.length; i++) {
      if (res[i].isNotEmpty) {
        tb_usercon_his usercon = tb_usercon_his();
        usercon.u_email = res[i][0] as String?;
        usercon.uc_recent = int.parse(res[i][1]) as int?;
        usercon.uc_con = res[i][2] as String?;
        usercon.uc_discon = res[i][3] as String?;
        usercons.add(usercon);
      }
    }

  }

  Future<void> addUserCon(String email)async{
    await DBConn('select * from tb_usercon_his where u_email="${email}";');
    if(res.length==0)
      await DBConn('insert into tb_usercon_his(u_email) values("${email}");');
  }
  // 실행 시간 가져오기
  Future<void> runTimeget(String email, bool state) async {
    if (state) {
      await DBConn('update tb_usercon_his set uc_con = now(), uc_recent = 1 where u_email="$email";');
    } else {
      await DBConn('update tb_usercon_his set uc_discon = now(), uc_recent = 0 where u_email="$email";');
    }
    await DBConn('select * from tb_usercon_his where u_email="$email";');
  }


  // tb_usercon_his 객체를 가져오는 getter
  tb_usercon_his? getUsercon(int index) {
    if (index >=0 && index<usercons.length) {
      return usercons[index];
    }
  }
}