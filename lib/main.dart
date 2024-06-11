import 'package:bulldozer/view/JoinView.dart';
import 'package:bulldozer/view/UserMain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:bulldozer/controller/UserController.dart';
import 'package:bulldozer/model/UserModel.dart';
// import 'package:bulldozer/view/AdminView.dart';
// import 'package:bulldozer/view/DictView.dart';
// import 'package:bulldozer/view/JoinView.dart';
// import 'package:bulldozer/view/UrlListView.dart';
// import 'package:bulldozer/view/UserMainView.dart';
// import 'package:bulldozer/view/test.dart';
// import 'package:bulldozer/view/testview.dart';
// import 'package:bulldozer/view/UserListView.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:bulldozer/db_main.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

final Uri _url = Uri.parse('https://naver.com');

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
    _initialMoveAnimation = Tween<Offset>(begin: const Offset(-2.0, 0), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _initialMoveController, curve: Curves.easeInOut),
    );
    _imagePositionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-0.1, 0)).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-0.1, 0), end: const Offset(0.1, 0)).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0.1, 0), end: const Offset(0, 0)).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, -0.5)).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.1).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );
    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeInOut),
    );
    _startAnimationSequence();
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
                const SizedBox(height: 150),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'Bulldozer와 함께하는',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '도박 STOP! 라이프',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                SlideTransition(
                  position: _initialMoveAnimation,
                  child: SlideTransition(
                    position: _imagePositionAnimation,
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Image(
                          image: AssetImage('images/bulldozer_icon.png'),
                          height: 170,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 0), // 로그인 폼과 이미지 사이의 여백
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
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
                icon: Icon(Icons.person),
                hintText: 'YourEmail',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
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
                icon: Icon(Icons.lock),
                hintText: 'Password',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // 로그인 메서드 자리
              _login(_idCon.text, _pwCon.text);

              print('Username: ${_idCon.text}');
              print('Password: ${_pwCon.text}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // primary 대신 backgroundColor 사용
              foregroundColor: Colors.white, // onPrimary 대신 foregroundColor 사용
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
            child: const Text('로그인', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinPage()));
            },
            child: const Text('아직 회원이 아니신가요? 회원가입', style: TextStyle(color: Colors.white)),
          ),
          // ElevatedButton(
          //   onPressed: _launchUrl,
          //   child: const Text('Show Flutter homepage'),
          // ),
        ],
      ),
    );
  }

  // 로그인
  Future<void> _login(String email, String pw) async{
    final storage = FlutterSecureStorage();
    await UserController.login(email, pw);
    print(res);

    if(res[0][0] == pw && email != 'admin'){
      // 로그인 성공
      print('로그인 성공');
      await storage.write(key: 'loginM', value: '${email}');
      String? value = await storage.read(key: 'loginM');
      print('${value}');

      Navigator.push(context, MaterialPageRoute(builder: (context) => UserMain(),));
    } else if (res[0][0] == 'admin' && email == 'admin') {
      print('관리자');
      // Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage(),));
    } else {
      // 로그인 실패
      print('로그인 실패');
    }
  }

}
