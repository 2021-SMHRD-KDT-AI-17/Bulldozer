import 'package:bulldozer/controller/BlockHisController.dart';
import 'package:bulldozer/smsService.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../controller/WebController.dart';

class verifi{
  static final verifi _instance = verifi._internal();
  late final String email;
  late final String phone;
  final blockHisController bhc=blockHisController();
  final smsService sms = smsService();
  static Future<void>? _initFuture;
  verifi._internal();
  late final String ngrokDomain;
  late webController webCon;

  static bool sleepTime=false;
  // static bool isNavigatingBack = false; // 페이지가 뒤로갈 때 해당 웹(비유해)은 검사하지 않도록 추가
  static const platform = MethodChannel('com.example.bulldozer/browser');
  static List<String> whiteList=["naver.com", "series.naver.com", "serieson.naver.com", "sports.naver.com", "entertain.naver.com", "pay.naver.com", "stock.naver.com", "land.naver.com", "novel.naver.com", "comic.naver.com", "chzzk.naver.com", "mail.naver.com", "calendar.naver.com", "memo.naver.com", "contact.naver.com", "photo.mybox.naver.com", "blog.naver.com", "bboom.naver.com", "cafe.naver.com", "post.naver.com", "booking.naver.com", "flight.naver.com", "place.naver.com", "map.naver.com", "terms.naver.com", "kin.naver.com", "searchad.naver.com", "daum.net", "mail.daum.net", "cafe.daum.net", "finance.daum.net", "realty.daum.net", "shoppinghow.kakao.com", "map.kakao.com", "google.com"];
  static List<String> blackList=["cms-2345.com", "rb-000.com", "smtb-0372.com", "ww-ot.com", "zzz-82.com", "wbet.biz", "gob-001.com", "snc-rr.com", "fst-ccc.com", "www.xn--tl3bze78kh9hq9a.com", "mcl-ddff.com", "xn--1-v78es76b.com", "ct-010.com", "tfrastrategy.com","rs9best.net","business2community.com"];

  static Future<verifi> getInstance() async {
    if (_initFuture == null) {
      _initFuture = _domainInit();

    }
    await _initFuture;
    return _instance;
  }
  static Future<void> _domainInit() async {
    _instance.webCon = webController();
    _instance.ngrokDomain= await _instance.webCon.domainGet();
    final storage = FlutterSecureStorage();
    _instance.email = (await storage.read(key: 'loginM'))!;
    _instance.phone = (await storage.read(key: 'loginT'))!;
    print(_instance.ngrokDomain);
  }
  static Future<String> _fetchDomain() async {
    // 비동기 작업 예시 (예: 네트워크 요청)
    _instance.webCon = webController();
    await Future.delayed(Duration(seconds: 2));
    return 'Fetched data';
  }
  Future<bool> webAnalyze(url, email) async{
    bool isOk = false;
    String webURL=urlTreatment(url);
    int res=await isfWebInList(webURL);
    if(res!=-1){
      return res==0?false:true;
    };
    if (sleepTime==false) sleepTime=true;
    Future.delayed(Duration(microseconds: 550)).then((e) => sleepTime=false);
    isOk= await toFlask(webURL, email,ngrokDomain);
    return isOk;
  }
  Future<bool> webAnalyzeTestver(url, email) async {
    bool isOk = false;
    String webURL=urlTreatment(url);
    int res=await isfWebInList(webURL);
    if(res!=-1){
      return res==0?false:true;
    };
    if (sleepTime==false) sleepTime=true;
    Future.delayed(Duration(microseconds: 550)).then((e) => sleepTime=false);
    isOk= await toFlask(webURL, email,"http://192.168.219.66:5000");
    return isOk;
  }
  String urlTreatment(beforeurl){
    String resURL=beforeurl;
    // "http://" 제거
    if (resURL.startsWith("http://")) {
      resURL = resURL.substring("http://".length);
    } else if (resURL.startsWith("https://")) { // "https://"도 제거
      resURL = resURL.substring("https://".length);
    }

    // ".com" 이후의 문자열 제거
    int index = resURL.indexOf(".com");
    if (index != -1) {
      resURL = resURL.substring(0, index + 4); //
    }
    print("urlTreatment : ${resURL}");
    return resURL;
  }
  Future<int> isfWebInList(url) async{
    print("webInList");
    print(url);
    print(url=="google.com");
    print(url.contains("google.com"));
    for (String bUrl in blackList) {
      if (url.contains(bUrl)) {
        print("차단 리스트에 포함된 URL");
        await platform.invokeMethod('launchBulldozer');  // isOk가 true일 때 메세지 전송
        detection(url);
        return 1;
      }
    }
    for (String wUrl in whiteList) {
      if (url.contains(wUrl)) {
        print("허용 리스트에 포함된 URL.");
        return 0;
      }
    }
    return -1;
  }
  Future<bool> toFlask(url, email ,myDomain) async{
    bool isHarmWeb=false;
    try {
      print("shot to flask");
      final response = await http.post(
        Uri.parse('${myDomain}/service/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"url": "${url}", "id": "${email}"}),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        isHarmWeb = responseData['response'];
        if(isHarmWeb==true){
          print("URL이 유해사이트로 판별됬습니다.");
          await platform.invokeMethod('launchBulldozer'); // 코틀린쪽
          detection(url);
        }else{
          for (String wUrl in whiteList) {
            if (url.contains(wUrl))return false;
          }
          whiteList.add(url);
        }
      } else {
        print("Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return isHarmWeb;
  }
  Future<void> detection(url) async{
    await Future.delayed(Duration(milliseconds: 990));
    bhc.insertBlock(_instance.email,url);
    sms.sendWebinfo(_instance.phone,url);
    for (String bUrl in blackList){
      if (url.contains(bUrl))return;
    }
    blackList.add(url);
  }
}

