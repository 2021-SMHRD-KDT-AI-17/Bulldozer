import 'dart:async';

import 'package:bulldozer/view/ReportView.dart';
import 'package:flutter/services.dart';

import '../../constants/animated_toggle_button.dart';
// import 'package:bulldozer/view/ReportCheckView.dart';
import '../../constants/theme_color.dart';
import '../../controller/UserconHisController.dart';
import '../../controller/UserController.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../painter/liquid_painter.dart';
import '../../painter/radial_painter.dart';
// import 'package:bulldozer/view/ReportView.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../flaskVerifi.dart';

class UserMain extends StatefulWidget {
  static const backService = MethodChannel('ForegroundServiceChannel'); // 코틀린
  static const browserChannel = MethodChannel('com.example.bulldozer/browser'); //코틀린
  const UserMain({super.key});

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> with TickerProviderStateMixin {
  String _url = ""; // URL 정보를 저장할 변수
  String _recentUrl="test1234";
  String _backUrl="test5678";
  String? _userE; //사용자 이름 저장할 변수
  // 애니메이션 컨트롤러 정의
  verifi? urlVerifi=null;
  late AnimationController _animationController;
  bool _isSwitchOn = false; // 토글 버튼 상태 저장

  late userController UserController;
  late userconHisController UserconHisController;

  _UserMainState() : super() {
    UserController = userController();
    UserconHisController = userconHisController();
  }

  // 애니메이션 지속 시간 설정
  static const _setDuration = 600;

  // 라이트 모드 설정
  ThemeColor lightMode = ThemeColor(
    gradient: [
      const Color(0xDDFF0080),
      const Color(0xDDFF8C00),
    ],
    backgroundColor: const Color(0xFFFFFFFF),
    textColor: const Color(0xFF000000),
    toggleButtonColor: const Color(0xFFFFFFFF),
    toggleBackgroundColor: const Color(0xFFe7e7e8),
    shadow: const [
      BoxShadow(
        color: const Color(0xFFd8d7da),
        spreadRadius: 5,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );

  // 다크 모드 설정
  ThemeColor darkMode = ThemeColor(
    gradient: [
      const Color(0xFF8983F7),
      const Color(0xFFA3DAFB),
    ],
    backgroundColor: const Color(0xFF26242e),
    textColor: const Color(0xFFFFFFFF),
    toggleButtonColor: const Color(0xFf34323d),
    toggleBackgroundColor: const Color(0xFF222029),
    shadow: const <BoxShadow>[
      BoxShadow(
        color: const Color(0x66000000),
        spreadRadius: 5,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    //url 가져오기
    _setupMethodChannel();
    // Foreground 서비스 중지
    stopForegroundService();
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: _setDuration),
      vsync: this,
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Foreground 서비스 중지
    stopForegroundService();
    // 애니메이션 컨트롤러 해제
    _animationController.dispose();
    super.dispose();
  }

  // 토글 버튼 상태 변경 함수
  void _toggleAnimation(int index) async {
    if(urlVerifi==null)urlVerifi=await verifi.getInstance();
    setState(() {
      _isSwitchOn = index == 1;
      if (_isSwitchOn) {
        _animationController.forward();
        startForegroundService();
      } else {
        _animationController.duration =
        const Duration(milliseconds: _setDuration);
        stopForegroundService();
        _animationController.reverse().then((_) {
          _animationController.duration =
          const Duration(milliseconds: _setDuration);
        });
      }
    });

    // DB 업데이트
    _userE = await loginCheck();
    if (_userE != null) {
      await UserconHisController.addUserCon(_userE!);
      await UserconHisController.runTimeget(_userE!, _isSwitchOn);
    }
  }
  // url 가져오기
  void _setupMethodChannel() {
    UserMain.browserChannel.setMethodCallHandler((call) async {
      print("callupdateUrl");
      if (call.method == "updateUrl") {
        setState(() {
          _url = call.arguments as String;
        });
        if(_url!="Search or type web address"){
          print("url:"+_url);
          print("rurl:"+_recentUrl);
          print("burl:"+_backUrl);
          if(_url.contains(_recentUrl)==false&&_url.contains(_backUrl)==false){

            _recentUrl=_url;
            bool isHarm= await urlVerifi!.webAnalyzeTestver(_recentUrl,_userE);
            if(isHarm==true)_recentUrl="";
            else _backUrl=_recentUrl;
          }
        }
      }
    });
  }
  Future<void> startForegroundService() async {
    try {
      print("Attempting to start Foreground Service");
      await UserMain.backService.invokeMethod('startForegroundService');
      print("Foreground Service Started");
    } on PlatformException catch (e) {
      print("Failed to start foreground service: ${e.message}");
    }
  }

  Future<void> stopForegroundService() async {
    try {
      print("Attempting to stop Foreground Service");
      await UserMain.backService.invokeMethod('stopForegroundService');
      print("Foreground Service Stopped");
    } on PlatformException catch (e) {
      print("Failed to stop foreground service: ${e.message}");
    }
  }
  // 로그인 상태 확인


  Future<String?> loginCheck() async {
    final storage = FlutterSecureStorage();
    _userE = await storage.read(key: 'loginM');
    return _userE;
  }


  @override
  Widget build(BuildContext context) {
    double percentage = (_animationController.value * 100).clamp(0, 100);
    return FutureBuilder<String?>(
      future: loginCheck(),
      builder: (context, snapshot) {
        return Scaffold(
          // 상단 앱바 설정
          appBar: AppBar(
            centerTitle: false,
            backgroundColor: Colors.yellow,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Bulldozer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 28,
                    ),
                  ),
                ),
                Spacer(), // 남은 공간 채우기
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPage(userE: snapshot.data ?? 'unknown'),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 5, right: 2),
                        child: Image.asset(
                          'images/icons/siren_icon2.png', // 사이렌 이미지 경로
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "신고하기!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 15.0)), // 양쪽 여백 설정
                    // 버튼 배경색을 흰색으로 지정
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    // 버튼 테두리 색상과 두께를 지정
                    side: MaterialStateProperty.all(
                      BorderSide(color: Colors.black54, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 애니메이션 컨테이너 설정
          body: AnimatedContainer(
            duration: const Duration(milliseconds: _setDuration),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSwitchOn
                    ? [Colors.yellow, Colors.orangeAccent]
                    : [Colors.black87, Colors.black54],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 진행 상태 표시기
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(200, 200),
                          painter:
                          LiquidPainter(_animationController.value, 1.0),
                        ),
                        CustomPaint(
                          size: Size(200, 200),
                          painter: RadialProgressPainter(
                            value: percentage,
                            backgroundGradientColors: [
                              const Color(0xffFF7A01),
                              const Color(0xffFF0069),
                              const Color(0xff7639FB),
                            ],
                            minValue: 0,
                            maxValue: 100,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // 커스텀 토글 버튼
                  AnimatedToggle(
                    values: ['OFF', 'ON'],
                    onToggleCallback: _toggleAnimation,
                    textColor:
                    _isSwitchOn ? lightMode.textColor : darkMode.textColor,
                    backgroundColor: _isSwitchOn
                        ? lightMode.toggleBackgroundColor
                        : darkMode.toggleBackgroundColor,
                    buttonColor: _isSwitchOn
                        ? lightMode.toggleButtonColor
                        : darkMode.toggleButtonColor,
                    shadows: _isSwitchOn ? darkMode.shadow : lightMode.shadow,

                  ),
                  const SizedBox(height: 30),
                  // 정보 텍스트와 이미지
                  Container(
                    decoration: BoxDecoration(
                      color: _isSwitchOn ? Colors.white70 : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            _isSwitchOn ? '실시간 감시 중!' : '실시간 감시가 꺼져있습니다.',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: _isSwitchOn ? Colors.black : Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: buildInfoRow(
                              context,
                              imagePath: "images/icons/free-icon-one-5293828.png",
                              text: ' 상단 차단 버튼을 누르고 활성화 하세요',
                              isSwitchOn: _isSwitchOn,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: buildInfoRow(
                              context,
                              imagePath: "images/icons/free-icon-two-5293904.png",
                              text: ' 기본적으로 백그라운드에서 \n 이용자의 불법 사이트 여부를 판단합니다.',
                              isSwitchOn: _isSwitchOn,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: buildInfoRow(
                              context,
                              imagePath:
                              "images/icons/free-icon-three-5293883.png",
                              text:
                              ' 해당 어플의 기능을 끄거나 종료시 \n 가입란에 기재된 보호자 연락처에게 \n 실시간 알림이 전송됩니다.',
                              isSwitchOn: _isSwitchOn,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 정보 텍스트와 이미지를 포함하는 행 위젯 빌드 함수
  Widget buildInfoRow(BuildContext context,
      {required String imagePath,
        required String text,
        required bool isSwitchOn}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        children: [
          Image.asset(imagePath),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isSwitchOn ? Colors.black : Colors.white,
              ),
              textAlign: TextAlign.left,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
