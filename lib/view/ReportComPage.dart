import 'dart:async';
import 'package:flutter/material.dart';
import '../../view/UserMain.dart';
import 'package:rive/rive.dart';


class ReportComPage extends StatefulWidget {
  const ReportComPage({super.key});

  @override
  State<ReportComPage> createState() => _ReportComPageState();
}

class _ReportComPageState extends State<ReportComPage> {
  late RiveAnimationController _controller1;
  late RiveAnimationController _controller2;
  int _timerCount = 10; // 타이머 초기값

  @override
  void initState() {
    super.initState();
    _controller1 = SimpleAnimation('Timeline 1');
    _controller2 = SimpleAnimation('animate');
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerCount > 0) {
          _timerCount--;
        } else {
          timer.cancel();
          _navigateToUserMain();
        }
      });
    });
  }

  void _navigateToUserMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserMain()),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent[200],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 5),
                  child: Text(
                    "",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '신고가 접수되었습니다.',
                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10,),
                    Text(
                      '감사합니다!',
                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
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
                Container(
                  width: 240,
                  height: 240,
                  child: RiveAnimation.asset(
                    'assets/404_cat.riv',
                    controllers: [_controller1],
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '* 신고 내용은 실시간으로 조속히 접수되며 \n적법 여부 판단 후 처리됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.amber[100],
                minimumSize: Size(120, 70),
                alignment: Alignment.centerLeft,
                textStyle: const TextStyle(fontSize: 30),
              ),
              onPressed: () {
                // 수동으로 페이지 이동
                _navigateToUserMain();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Text('$_timerCount초 후 메인 페이지로 이동합니다.',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(height: 7,),
                    SizedBox(
                      width: 200,
                      height: 60,
                      child: RiveAnimation.asset(
                        'assets/material_loader.riv',
                        controllers: [_controller2],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



