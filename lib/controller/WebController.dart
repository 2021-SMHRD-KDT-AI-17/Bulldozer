import 'package:mvc_pattern/mvc_pattern.dart';
import '../../model/WebModel.dart';
import '../../db.dart';

class webController extends ControllerMVC {

  factory webController([StateMVC? state]) =>
      _this ??= webController._(state);

  webController._(StateMVC? state)
      : _tb_web = tb_web(),
        super(state);

  final tb_web _tb_web;
  static webController? _this;

  int? get getIdx => _tb_web.web_idx;
  String? get getAddress => _tb_web.web_address;
  int? get getType => _tb_web.web_type;

  final List<tb_web> webs = [];

  Future<void> loadData() async{
    await DBConn('select * from tb_web where web_dix>0;');
    webs.clear();

    // tb_web 객체 리스트로 변환
    for (int i=0; i<res.length; i++){
      if (res[i].isNotEmpty){
        tb_web web = tb_web();
        web.setIdx = int.parse(res[i][0]) as int?;
        web.setAddress = res[i][1] as String?;
        web.setType = int.parse(res[i][2]) as int?;
        webs.add(web);
      }
    }
  }
  // tb_web 객체를 가져오는 getter
  tb_web? getWeb(int index) {
    if(index>=0 && index<webs.length) {
      return webs[index];
    }
  }
  Future<String> domainGet()async{
    await DBConn('select * from tb_web where web_idx=0');
    webs.clear();
    return res[0][1];
  }
}