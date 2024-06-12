import 'package:bulldozer/main.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class JoinComPage extends StatefulWidget {
  const JoinComPage({super.key,required this.userEmail});
  final String userEmail;
  @override
  State<JoinComPage> createState() => _JoinComPageState();
}

class _JoinComPageState extends State<JoinComPage> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 'Animation 1'을 실제 애니메이션 이름으로 설정
    _controller = SimpleAnimation('Animation 1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("images/bulldozer_icon.png", width: 60, height: 60,),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 5),
                  child: Text("Bulldozer", style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                ),
              ],
            ),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                // 원래 이미지 배경
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Rive 애니메이션
                Container(
                  width: 200,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/check_animation.riv',
                    controllers: [_controller],
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '회원가입 완료',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '${widget.userEmail}\n 님의 회원가입이 성공적으로 완료되었습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '* (주) bulldozer(이하 "회사")는 이용자의 보호를 위해 \n 가입 정보와 관련 데이터를 보관 중이며\n  ⌜개인 정보 보호법⌟ 및 관계 법령이 정한 바를 준수합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(   //모서리를 둥글게
                      borderRadius: BorderRadius.circular(20)), backgroundColor: Colors.amber,
                  // onPrimary: Colors.blue,   //글자색
                  minimumSize: Size(120, 70),   //width, height

                  //child 정렬 - 아래의 Text('$test')
                  alignment: Alignment.centerLeft,
                  textStyle: const TextStyle(fontSize: 30)
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage(),),(Route<dynamic>route)=>false);
                // 로그인 페이지로 이동
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                child: Text('로그인 바로하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
