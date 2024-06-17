import 'package:fluttertoast/fluttertoast.dart';

import '../../view/JoinView.dart';
import '../../view/UserMain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mysql_client/mysql_client.dart';
import '../../controller/UserController.dart';
import '../../model/UserModel.dart';
import '../../view/AdminView.dart';
import '../../view/DictView.dart';
import '../../view/JoinView.dart';
import '../../view/UrlListView.dart';
import '../../view/UserListView.dart';
import 'package:bulldozer/db.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _moveController;
  late AnimationController _formController;
  late AnimationController _initialMoveController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _imagePositionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _initialMoveAnimation;

  final storage = const FlutterSecureStorage();
  late userController UserController;

  TextEditingController _idCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    UserController = userController();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _moveController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _formController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _initialMoveController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 2.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _initialMoveAnimation =
        Tween<Offset>(begin: const Offset(-2.0, 0), end: const Offset(0, 0))
            .animate(
          CurvedAnimation(parent: _initialMoveController, curve: Curves.easeInOut),
        );
    _imagePositionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween:
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-0.1, 0))
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
            begin: const Offset(-0.1, 0), end: const Offset(0.1, 0))
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween:
        Tween<Offset>(begin: const Offset(0.1, 0), end: const Offset(0, 0))
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween:
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, -0.5))
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );
    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeInOut),
    );
    _startAnimationSequence();
    _isLogin();
  }

  Future<void> _startAnimationSequence() async {
    await _fadeController.forward();
    await _initialMoveController.forward();
    await _moveController.forward();
    await _formController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _moveController.dispose();
    _formController.dispose();
    _idCon.dispose();
    _pwCon.dispose();
    _initialMoveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'Bulldozer와 함께하는',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        '도박 STOP! 라이프',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5), // 이미지와 텍스트 사이의 간격
                SlideTransition(
                  position: _initialMoveAnimation,
                  child: SlideTransition(
                    position: _imagePositionAnimation,
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Image(
                          image: AssetImage('images/icons/bulldozer_icon.png'),
                          height: 160,
                        ),
                      ),
                    ),
                  ),
                ),
              Stack(
                children: [
                  // 테두리 텍스트
                  Text(
                    'Bulldozer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 43,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 7
                        ..color = Colors.black,
                    ),
                  ),
                  // 원래 텍스트
                  const Text(
                    'Bulldozer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 43,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10), // 로그인 폼과 이미지 사이의 여백
                FadeTransition(
                  opacity: _formAnimation,
                  child: _buildLoginForm(),
                ),
                const SizedBox(height: 5),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Bulldozer Co.,LTD. All Rights Reserved.',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(width: 2, color: Colors.black87),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _idCon,
              decoration: const InputDecoration(
                icon: Icon(Icons.person, color: Colors.orange, size: 30,),
                hintText: '이메일을 입력하세요.',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(width: 2, color: Colors.black87),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _pwCon,
              obscureText: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.lock, color: Colors.orange, size: 26,),
                hintText: '비밀번호를 입력하세요.',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 로그인 메서드 자리
              if(_idCon.text==""&&_pwCon.text=="")Fluttertoast.showToast(msg: "이메일과 비밀번호를 입력해주세요.");
              else if(_idCon.text=="")Fluttertoast.showToast(msg: "이메일을 입력해주세요.");
              else if(_pwCon.text=="")Fluttertoast.showToast(msg: "비밀번호를 입력해주세요.");
              _login(_idCon.text, _pwCon.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600], // primary 대신 backgroundColor 사용
              foregroundColor: Colors.white, // onPrimary 대신 foregroundColor 사용
              padding: const EdgeInsets.symmetric(horizontal: 86, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
                side: const BorderSide(color: Colors.black, width: 2), // 테두리 추가
              ),
              elevation: 5,
            ),
            child: const Text('로그인', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 23),
          const Row(
            children: [
              Expanded(
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white,
                  indent: 20,
                  endIndent: 10,
                ),
              ),
              Text(
                "or",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white,
                  indent: 10,
                  endIndent: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("   아직 회원이 아니신가요?", style: TextStyle(color: Colors.white)),
              Stack(
                children: [
                  Positioned(
                    bottom: 10,
                    left: 9,
                    child: Container(height: 2, width: 58, color: Colors.amber,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinPage()));
                    },
                    child: const Text('회원가입',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              )
              ,
            ],
          ),
        ],
      ),
    );
  }

  // 로그인 정보 있는지 확인
  Future<void> _isLogin() async {
    String? value = await storage.read(key: 'loginM');
    if(value!=null){
      print('${value}');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserMain(),),(Route<dynamic>route)=>false);
    }
  }


  // 로그인
  Future<void> _login(String email, String pw) async{

    await UserController.login(email, pw);
    if(res.length==0){
      Fluttertoast.showToast(msg: "이메일과 비밀번호를 확인해보세요");
      return;
    }
    print(res);

    if(res[0][0] != 'admin'){
      // 로그인 성공
      print('로그인 성공');
      await storage.write(key: 'loginM', value: '${email}');
      print('${email}');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserMain(),),(Route<dynamic>route)=>false);
    } else if (res[0][0] == 'admin') {
      print('관리자');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AdminPage(),),(Route<dynamic>route)=>false);
    }
  }

}
