import 'dart:async';
import 'dart:convert';

import 'package:bulldozer/smsService.dart';
import 'package:bulldozer/view/ReportView.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../constants/animated_toggle_button.dart';
import '../../constants/theme_color.dart';
import '../../controller/UserconHisController.dart';
import '../../controller/UserController.dart';
import '../../controller/ReportController.dart';
import 'package:flutter/material.dart';
import '../../painter/liquid_painter.dart';
import '../../painter/radial_painter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../flaskVerifi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rive/rive.dart' as rive;
import 'package:http/http.dart' as http;

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
  String? _userT; //사용자 이메일 저장할 변수
  // 애니메이션 컨트롤러 정의
  verifi? urlVerifi=null;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가
  bool _isSwitchOn = false; // 토글 버튼 상태 저장

  late userController UserController;
  late userconHisController UserconHisController;
  final smsService sms = smsService();
  //알림창
  final TextEditingController _controller = TextEditingController();
  bool isDoneEnabled = false;
  //

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
        color: Color(0xFFd8d7da),
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
        color: Color(0x66000000),
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
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation =
    Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _fadeController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _fadeController.forward();
        }
      });

    _fadeController.forward();
    //알림창
    _controller.addListener(_detectionInput);
  }

  @override
  void dispose() {
    // Foreground 서비스 중지
    stopForegroundService();
    // 애니메이션 컨트롤러 해제
    _animationController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
    //알림창
    _controller.removeListener(_detectionInput);
    _controller.dispose();
  }
  //detectionPage
  void _detectionInput() {
    setState(() {
      isDoneEnabled = _controller.text.trim() == "확인했습니다";
    });
    print("Current input: ${_controller.text.trim()}"); // 디버깅을 위해 입력값 출력
    print("isDoneEnabled: $isDoneEnabled"); // 디버깅을 위해 상태 출력
  }
  void _showAlert(BuildContext context,String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void _localCheckInput() {
              setState(() {
                isDoneEnabled = _controller.text.trim() == "알겠습니다";
              });
              print("Current input: ${_controller.text.trim()}"); // 디버깅을 위해 입력값 출력
              print("isDoneEnabled: $isDoneEnabled"); // 디버깅을 위해 상태 출력
            }

            _controller.addListener(_localCheckInput);

            return AlertDialog(
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "images/icons/free-animated-icon-speech-bubble-8716771.png",
                        scale: 4,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${url}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "도박배너가 포함된 사이트로 인식되었습니다.\n보호자에게 메시지가 발송 되었습니다.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Pretendard",
                        ),
                      ),
                      SizedBox(height: 20),
                      Text.rich(
                        TextSpan(
                          text: '내용을 숙지하셨다면 ',
                          children: <TextSpan>[
                            TextSpan(
                              text: ' "알겠습니다" ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: '를\n입력 후 완료 버튼을 눌러주세요.',
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '알겠습니다',
                          border: OutlineInputBorder(),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: isDoneEnabled
                                ? () {
                              Navigator.of(context).pop();
                            }
                                : null,
                            child: Text('완료'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDoneEnabled ? Colors.yellow : Colors.grey,
                              side: BorderSide(
                                width: 2,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              reportController ReportController=reportController();
                              ReportController.insertReport(_userE!, url, "유해사이트 접속 후 신고");
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              '신고하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              side: BorderSide(
                                width: 2,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _controller.text="";
      // _controller.removeListener(_detectionInput); // 팝업이 닫힐 때 리스너 제거
    });
  }
  //
  // 토글 버튼 상태 변경 함수
  void _toggleAnimation(int index) async {
    if(urlVerifi==null)urlVerifi=await verifi.getInstance();
    setState(() {
      _isSwitchOn = index == 1;
      if (_isSwitchOn) {
        sms.sendConinfo(_userT!,1);
        startForegroundService();
        _animationController.forward();
      } else {
        sms.sendConinfo(_userT!,0);
        stopForegroundService();
        _animationController.duration =
        const Duration(milliseconds: _setDuration);
        _animationController.reverse().then((_) {
          _animationController.duration =
          const Duration(milliseconds: _setDuration);
        });
      }
    });

    // DB 업데이트

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
            bool isHarm= await urlVerifi!.webAnalyze(_recentUrl,_userE);
            print("!!!");
            print(isHarm);
            if(isHarm==true){
              print("유해판단");
              _showAlert(context,_recentUrl);
              _recentUrl="test23";
            }
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


  Future<void> loginCheck() async {
    if (_userE == null){
      final storage = FlutterSecureStorage();
      _userE = await storage.read(key: 'loginM');
      _userT = await storage.read(key: 'loginT');
      print("유저메인 최초 접속 | ${_userE} | ${_userT}");
    }
  }

  void _scrollDown() {
    final screenHeight = MediaQuery.of(context).size.height; // 화면 높이 가져오기
    _scrollController.animateTo(
      _scrollController.offset + screenHeight,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  String? _selectedCenter;
  String? _selectedGovernmentAgency;

  final Map<String, String> _centerUrls = {
    '중앙센터': 'https://www.example.com/center1',
    '사행산업통합관리위원회': 'https://www.ngcc.go.kr/',
    '강원랜드 마음채움센터': 'https://www.high1.com/klacc/index.do',
    '문화체육관광부': 'https://www.mcst.go.kr/kor/main.jsp',
    '한국카지노관광협회': 'http://www.koreacasino.or.kr/kcasino/main/casinoMain.do',

  };
  @override
  Widget build(BuildContext context) {
    double percentage = (_animationController.value * 100).clamp(0, 100);
    return FutureBuilder<void>(
      future: loginCheck(),
      builder: (context, snapshot) {
        return Scaffold(
          // 상단 앱바 설정
          appBar: AppBar(
            centerTitle: false,
            backgroundColor: Colors.amber,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Bulldozer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ),
                Spacer(), // 남은 공간 채우기
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPage(userE: _userE!),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 0, bottom: 5, right: 2),
                        child: Image.asset(
                          'images/icons/siren_icon2.png', // 사이렌 이미지 경로
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "신고하기!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 15.0)), // 양쪽 여백 설정
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
                    ? [Colors.amber, Colors.white]
                    : [Colors.black87, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              // 스크롤 가능하도록 수정
              controller: _scrollController, // 스크롤 컨트롤러 추가
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 13,
                    ),
                    // 진행 상태 표시기
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(210, 210),
                            painter:
                            LiquidPainter(_animationController.value, 1.0),
                          ),
                          CustomPaint(
                            size: Size(210, 210),
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
                              fontSize: 37,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 커스텀 토글 버튼
                    AnimatedToggle(
                      values: ['OFF', 'ON'],
                      onToggleCallback: _toggleAnimation,
                      textColor: _isSwitchOn
                          ? lightMode.textColor
                          : darkMode.textColor,
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
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              _isSwitchOn ? '실시간 감시 중!' : '실시간 감시가 꺼져있습니다.',
                              style: TextStyle(
                                fontSize: 19, // 글씨 크기 줄임
                                fontWeight: FontWeight.bold,
                                color:
                                _isSwitchOn ? Colors.black : Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 23),
                            Padding(
                              padding: const EdgeInsets.only(left: 9),
                              child: buildInfoRow(
                                context,
                                imagePath:
                                "images/icons/free-icon-one-5293828.png",
                                text: ' 상단 차단 버튼을 누르고 활성화 하세요.',
                                isSwitchOn: _isSwitchOn,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: buildInfoRow(
                                context,
                                imagePath:
                                "images/icons/free-icon-two-5293904.png",
                                text: ' 기본적으로 백그라운드에서 이용자의 불법 \n사이트 여부를 판단합니다.',
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
                                ' 해당 앱의 기능을 끄거나 종료 시 기입란에 기재된 보호자 연락처에게 실시간 알림이 \n전송됩니다.',
                                isSwitchOn: _isSwitchOn,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 13,
                        ),
                        TextButton(
                          onPressed: () {
                            _scrollDown();
                          },
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              "Click!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22, // 글씨 크기 줄임
                                color:
                                _isSwitchOn ? Colors.black87 : Colors.amber,
                              ),
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: IconButton(
                            onPressed: _scrollDown,
                            icon:
                            Icon(Icons.keyboard_double_arrow_down_rounded),
                            color: _isSwitchOn ? Colors.black87 : Colors.amber,
                            iconSize: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 130,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:26),
                          child: Text(
                            "  도박, 예방합시다",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28, // 글씨 크기 줄임
                              color: _isSwitchOn ? Colors.black87 : Colors.amber,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(width: 3),
                        // Rive 애니메이션 추가
                        SizedBox(
                          width: 110,
                          height: 130,
                          child: rive.RiveAnimation.asset(
                            'assets/new_plant_test.riv', // Rive 애니메이션 파일 경로
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '          "왜 사람들은 도박에 빠지는가?"',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: _isSwitchOn ? Colors.black : Colors.white,
                          ),
                        ),
                        SizedBox(height: 34),
                        Text(
                          "도박은 다양한 이유로 위험 요소가 될 수 있습니다.",
                          style: TextStyle(
                            fontSize: 14,
                            color: _isSwitchOn ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 23),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: _isSwitchOn
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      color: _isSwitchOn
                                          ? Colors.amber[900]
                                          : Colors.black),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '초기에 대박을 경험하면',
                                        style: TextStyle(
                                          color: _isSwitchOn
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '대박에 대한 기대가 높아집니다.',
                                        style: TextStyle(
                                            color: _isSwitchOn
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: _isSwitchOn
                                            ? Colors.black87
                                            : Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      color: _isSwitchOn
                                          ? Colors.amber[700]
                                          : Colors.black87),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '모험을 좋아하고 심심함을 채우기 위해',
                                        style: TextStyle(
                                          color: _isSwitchOn
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '점차 충동적으로 행동합니다.',
                                        style: TextStyle(
                                            color: _isSwitchOn
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            VerticalDivider(
                              width: 2,
                              color: Colors.black87,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: _isSwitchOn
                                            ? Colors.black54
                                            : Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      color: _isSwitchOn
                                          ? Colors.amber[500]
                                          : Colors.black54),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '도박을 통해 잃은 돈을 만회하고 싶은',
                                        style: TextStyle(
                                          color: _isSwitchOn
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '욕구가 있습니다.',
                                        style: TextStyle(
                                            color: _isSwitchOn
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: _isSwitchOn
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      color: _isSwitchOn
                                          ? Colors.amber[300]
                                          : Colors.black26),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '자신의 문제를 잊거나 해결할 수 있는',
                                        style: TextStyle(
                                          color: _isSwitchOn
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '방법이 있다고 스스로 생각합니다.',
                                        style: TextStyle(
                                            color: _isSwitchOn
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: _isSwitchOn
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      color: _isSwitchOn
                                          ? Colors.amber[200]
                                          : Colors.black12),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '건강이 악화되어 신체적 혹은 정서적 고통을',
                                        style: TextStyle(
                                          color: _isSwitchOn
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '완화하기 위해 도박에 의존하게 됩니다.',
                                        style: TextStyle(
                                            color: _isSwitchOn
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isSwitchOn ? Colors.white : Colors.black12,
                        borderRadius: BorderRadius.circular(20),
                        border: Border(
                          right: BorderSide(color: Colors.black, width: 6),
                          bottom: BorderSide(color: Colors.black, width: 6),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "도박을 하게 되는 동기",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _isSwitchOn ? Colors.black : Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 10),
                          buildMotivationRow(
                            "금전 동기\n 쉽게 큰 돈을 따고 싶거나 잃은 돈을 만회하고 싶은 욕구",
                            'images/icons/free-icon-coin-3557264.png',
                            Colors.green,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          buildMotivationRow(
                            "회피 동기\n 현실 문제의 압박감, 우울감, 스트레스를 잊고 싶은 욕구",
                            'images/icons/free-icon-mask-8945277.png',
                            Colors.blue,
                          ),
                          buildMotivationRow(
                            "유희 동기\n 가벼운 즐거움과 여가를 즐기기 위한 수단으로서의 욕구",
                            'images/icons/free-icon-poker-2460435.png',
                            Colors.purple,
                          ),
                          buildMotivationRow(
                            "흥분 동기\n 스릴과 흥분, 짜릿함, 쾌감과 즐거움을 느끼고 싶은 욕구",
                            'images/icons/free-icon-happiness-1189150.png',
                            Colors.red,
                          ),
                          buildMotivationRow(
                            "사교 동기\n 직장 동료나 친구들과 놀이 및 친목의 욕구",
                            'images/icons/free-icon-discussion-5064943.png',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(right: 250, bottom: 20),
                      child: Text("도움의 손길",
                        style: TextStyle(
                            color: _isSwitchOn ? Colors.black87 : Colors.amber[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 19
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSwitchOn ? Colors.white : Colors.black12,
                        borderRadius: BorderRadius.circular(20),
                        border: Border(
                          right: BorderSide(color: Colors.black, width: 6),
                          bottom: BorderSide(color: Colors.black, width: 6),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  hint: Text('    관련 기관 및 지역센터', style: TextStyle(fontSize: 13, color: _isSwitchOn? Colors.black87 : Colors.white),),
                                  value: _selectedCenter,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedCenter = newValue;
                                    });
                                  },
                                  items: _centerUrls.keys.map((center) {
                                    return DropdownMenuItem<String>(
                                      value: center,
                                      child: Text(center, style: TextStyle(
                                        color: Colors.black87,
                                      ),),
                                    );
                                  }).toList(),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_selectedCenter != null) {
                                    launchURL(_centerUrls[_selectedCenter]!);
                                  }
                                },
                                child: Text('이동', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),),
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(
                                      EdgeInsets.symmetric(horizontal: 15.0)), // 양쪽 여백 설정
                                  // 버튼 배경색을 흰색으로 지정
                                  backgroundColor: MaterialStateProperty.all(Colors.green[100]),
                                  // 버튼 테두리 색상과 두께를 지정
                                  side: MaterialStateProperty.all(
                                    BorderSide(color: Colors.black87, width: 2),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 정보 텍스트와 이미지를 포함하는 행 위젯 빌드 함수
  Widget buildMotivationRow(String text, String imagePath, Color color) {
    final parts = text.split('\n');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 12),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Image.asset(imagePath, width: 45, height: 45),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: parts[0] + '\n\n',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isSwitchOn ? Colors.black : Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: parts[1],
                    style: TextStyle(
                      fontSize: 15,
                      color: _isSwitchOn ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
                fontSize: 14, // 글씨 크기 변경
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

  // URL 실행 함수
  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// 뉴스 게시판 위젯 클래스
class NewsBoard extends StatefulWidget {
  @override
  _NewsBoardState createState() => _NewsBoardState();
}

class _NewsBoardState extends State<NewsBoard> {
  late Future<List<NewsArticle>> articles;

  @override
  void initState() {
    super.initState();
    articles = fetchArticles();
  }

  Future<List<NewsArticle>> fetchArticles() async {
    final String query = '온라인 불법 도박';
    final String apiKey = 'YOUR_API_KEY'; // 여기에 실제 API 키를 입력하세요.
    final String url =
        'https://openapi.naver.com/v1/search/news.json?query=$query&display=4&start=1&sort=sim'; // display를 4로 수정

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-Naver-Client-Id': 'koFk3KEI3f6cqvu6Ofzz', // 여기에 실제 클라이언트 ID를 입력하세요.
        'X-Naver-Client-Secret': 'llgy_VBswa', // 여기에 실제 클라이언트 Secret을 입력하세요.
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final items = jsonResponse['items'] as List<dynamic>;

      final articles = items.map((item) => NewsArticle.fromJson(item)).toList();

      final updatedArticles = await fetchImagesForArticles(articles);

      return updatedArticles;
    } else {
      throw Exception('Failed to load articles');
    }
  }

  Future<List<NewsArticle>> fetchImagesForArticles(
      List<NewsArticle> articles) async {
    final response = await http.post(
      Uri.parse('http://192.168.219.54:5000/get_news_images'),
      // 서버 URL에 맞게 변경하세요.
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'articles': articles}),
    );

    if (response.statusCode == 200) {
      final jsonResponse =
      json.decode(response.body)['articles'] as List<dynamic>;
      return jsonResponse.map((item) => NewsArticle.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch images for articles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsArticle>>(
      future: articles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load articles'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No articles found'));
        } else {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 5,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final article = snapshot.data![index];
              final formattedDate = DateFormat('yyyy.MM.dd(E) HH:mm').format(
                  DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US")
                      .parse(article.pubDate)); // 날짜 포맷 수정
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(article.title),
                      content: Text('기사로 이동하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            launchURL(article.link);
                          },
                          child: Text('확인'),
                        ),
                      ],
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      article.img.isNotEmpty
                          ? Image.network(
                        article.img,
                        fit: BoxFit.cover,
                        height: 120,
                        width: double.infinity,
                      )
                          : Container(
                        height: 120,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          article.desc,
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// 뉴스 기사 모델 클래스
class NewsArticle {
  final String title;
  final String link;
  final String img;
  final String desc;
  final String pubDate; // pubDate 필드 추가

  NewsArticle(
      {required this.title,
        required this.link,
        required this.img,
        required this.desc,
        required this.pubDate}); // pubDate 매개변수 추가

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
      // HTML 태그 제거
      link: json['originallink'] ?? json['link'],
      img: json['img'] ?? '',
      desc: json['description'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
      // HTML 태그 제거
      pubDate: json['pubDate'], // pubDate 필드 매핑
    );
  }
}