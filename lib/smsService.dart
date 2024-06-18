import 'package:telephony/telephony.dart';

class smsService{
  static Telephony telephony = Telephony.instance;
  void sendConinfo(String phoneNumber,int conOrDiscon) async{
    String number = phoneNumberTreatment(phoneNumber);
    String mes="";
    if(conOrDiscon==0){
        mes="Bulldozer어플 알람 서비스 입니다.\n 귀하의 보호대상자가 Bulldozer서비스를 비활성화 했습니다";
    }else{
        mes="Bulldozer어플 알람 서비스 입니다.\n 귀하의 보호대상자가 Bulldozer서비스를 활성화 했습니다";
    }
    telephony.sendSms(
      to: number,
      message: mes,
    );
  }
  void sendWebinfo(String phoneNumber, String url)async{
    String number = phoneNumberTreatment(phoneNumber);
    telephony.sendSms(
      to: number,
      message: "Bulldozer어플 알람 서비스 입니다.\n 귀하의 보호대상자가 ${url}에 접속을 시도해 차단했습니다",
    );
  }
  String phoneNumberTreatment(String phoneNumber){
    String number = phoneNumber.replaceAll('-', '');
    number = "+82" + number.substring(1);
    return number;
  }
}