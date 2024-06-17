class tb_dict{
  int? dict_idx;
  String? dict_word;
  double? dict_w;
  String? dict_type;

  //getter
  int? get getIdx => dict_idx;
  String? get getW => dict_word;
  double? get getW1 => dict_w;
  String? get getW2 => dict_type;

  //setter
  set setIdx(int? value){
    dict_idx = value;
  }
  set setWord(String? value){
    dict_word = value;
  }
  set setW(double? value){
    dict_w = value;
  }
  set setType(String? value){
    dict_type = value;
  }
}