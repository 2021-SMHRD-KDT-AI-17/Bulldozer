import 'package:bulldozer/view/join_page.dart';
// import 'package:project_bulldozer/report_check_page.dart';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';


// final Uri _url = Uri.parse('https://naver.com');


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _imagePositionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();

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

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
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
    await _moveController.forward();
    await _formController.forward();
  }

  // Future<void> _launchUrl() async {
  //   if (!await launchUrl(_url)) {
  //     throw Exception('Could not launch $_url');
  //   }
  // }

  @override
  void dispose() {
    _fadeController.dispose();
    _moveController.dispose();
    _formController.dispose();
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
                  position: _imagePositionAnimation,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Image(
                        image: AssetImage('images/sadcat.png'),
                        height: 200,
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
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Username',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
            child: const TextField(
              obscureText: true,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                hintText: 'Password',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // primary 대신 backgroundColor 사용
              foregroundColor: Colors.white, // onPrimary 대신 foregroundColor 사용
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: const Text('로그인', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_)=> const JoinPage()));

            },
            child: const Text('아직 회원이 아니신가요? 회원가입', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(onPressed: //_launchUrl
              (){}
            , child: Text('Show Flutter homepage'), )
        ],
      ),
    );
  }
}
