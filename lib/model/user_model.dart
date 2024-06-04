class tb_user{
  String? u_email;
  String? u_pw;
  String? u_at;
  String? u_tel;

  //getter
  String? get getEmail => u_email;
  String? get getPw => u_pw;
  String? get getAt => u_at;
  String? get getTel => u_tel;

  //setter
  set setEmail(String? value){
    u_email = value;
  }
  set setPw(String? value){
    u_pw = value;
  }
  set setAt(String? value){
    u_at = value;
  }
  set setTel(String? value){
    u_tel = value;
  }

}