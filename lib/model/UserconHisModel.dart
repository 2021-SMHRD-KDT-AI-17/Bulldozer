class tb_usercon_his {
  String? u_email;
  int? uc_recent;
  String? uc_con;
  String? uc_discon;

  //getter
  String? get getEmail => u_email;
  int? get getType => uc_recent;
  String? get getCon => uc_con;
  String? get getDiscon => uc_discon;

  //setter
  set setEmail(String? value){
    u_email = value;
  }
  set setType(int? value){
    uc_recent = value;
  }
  set setCon(String? value){
    uc_con = value;
  }
  set setDiscon(String? value){
    uc_discon = value;
  }
}