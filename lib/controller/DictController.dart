import 'package:mvc_pattern/mvc_pattern.dart';
import '../../model/DictModel.dart';
import '../../db.dart';

class dictController extends ControllerMVC {

  factory dictController([StateMVC? state]) =>
      _this ??= dictController._(state);

  dictController._(StateMVC? state)
      : _tb_dict = tb_dict(),
        super(state);

  final tb_dict _tb_dict;
  static dictController? _this;

  int? get getIdx => _tb_dict.dict_idx;
  String? get getWord => _tb_dict.dict_word;
  double? get getW => _tb_dict.dict_w;
  String? get getW2 => _tb_dict.dict_type;

  final List<tb_dict> dicts = [];

  Future<void> loadData() async {
    await DBConn('select * from tb_dict order by dict_word ASC;');
    dicts.clear();

    // tb_dict 객체 리스트 변환
    for (int i = 0; i < res.length; i++) {
      if (res[i].isNotEmpty) {
        tb_dict dict = tb_dict();
        dict.setIdx = int.tryParse(res[i][0] ?? '0'); // 기본값 0
        dict.setWord = res[i][1] ?? ''; // 기본값 빈 문자열
        dict.setW = double.tryParse(res[i][2] ?? '0.0'); // 기본값 0.0
        dict.setType = res[i][3] ?? ''; // 기본값 빈 문자열
        dicts.add(dict);
      }
    }
  }

  // tb_dict 객체를 가져오는 getter
  tb_dict? getDict(int index) {
    if (index >= 0 && index < dicts.length) {
      return dicts[index];
    }
  }

  // 초성으로 가져오기
  Future<void> selectWord(String consonant) async {
    Map<String, List<String>> consonantRanges = {
      'ㄱ': ['가', '나'],
      'ㄴ': ['나', '다'],
      'ㄷ': ['다', '라'],
      'ㄹ': ['라', '마'],
      'ㅁ': ['마', '바'],
      'ㅂ': ['바', '사'],
      'ㅅ': ['사', '아'],
      'ㅇ': ['아', '자'],
      'ㅈ': ['자', '차'],
      'ㅊ': ['차', '카'],
      'ㅋ': ['카', '타'],
      'ㅌ': ['타', '파'],
      'ㅍ': ['파', '하'],
      'ㅎ': ['하', '힣'],
    };

    List<String>? range = consonantRanges[consonant];
    if (range != null) {
      await DBConn('SELECT * FROM tb_dict WHERE dict_word >= "${range[0]}" AND dict_word < "${range[1]}" ORDER BY dict_word ASC;');
    }
  }

  // 단어사전 단어 등록
  Future<void> insertWord(String word, String type) async {
    await DBConn('insert into tb_dict (dict_word, dict_type) values ("${word}", "${type}");');
  }

}