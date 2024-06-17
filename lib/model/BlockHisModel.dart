class tb_block_his{

  int? block_idx;
  String? u_email;
  String? block_address;
  String? block_at;

  //getter
  int? get getIdx => block_idx;
  String? get getEmail => u_email;
  String? get getAddress => block_address;
  String? get getAt => block_at;

  //setter
  set setIdx(int? value){
    block_idx = value;
  }
  set setEmail(String? value){
    u_email = value;
  }
  set setAddress(String? value){
    block_address = value;
  }
  set setAt(String? value){
    block_at = value;
  }
}