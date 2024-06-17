class tb_web{
  int? web_idx;
  String? web_address;
  int? web_type;

  //getter
  int? get getIdx => web_idx;
  String? get getAddress => web_address;
  int? get getType => web_type;

  //setter
  set setIdx(int? value){
    web_idx = value;
  }
  set setAddress(String? value){
    web_address = value;
  }
  set setType(int? value){
    web_type = value;
  }

}