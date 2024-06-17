class tb_report{
  int? report_idx;
  String? u_email;
  String? report_address;
  String? report_descript;
  int? report_analysis;
  String? report_title;
  String? report_at;

  //getter
  int? get getIdx => report_idx;
  String? get getEmail => u_email;
  String? get getAddress => report_address;
  String? get getDescript => report_descript;
  int? get getAnalysis => report_analysis;
  String? get getTitle => report_title;
  String? get getAt => report_at;

  //setter
  set setIdx(int? value){
    report_idx = value;
  }
  set setEmail(String? value){
    u_email = value;
  }
  set setAddress(String? value){
    report_address = value;
  }
  set setDescript(String? value){
    report_descript = value;
  }
  set setAnalysis(int? value){
    report_analysis = value;
  }
  set setTitle(String? value){
    report_title = value;
  }
  set setAt(String? value){
    report_at = value;
  }
}