import 'dart:async';

// import 'package:bulldozer/view/ReportCheckView.dart';
import 'package:flutter/material.dart';
// import 'package:bulldozer/view/ReportView.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserMain extends StatefulWidget {
  const UserMain({super.key});
  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> with TickerProviderStateMixin{
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;
  bool _isSwitchOn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    if (_isSwitchOn) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleAnimation(bool value) {
    setState(() {
      _isSwitchOn = value;
      if (_isSwitchOn) {
        _animationController.repeat();
        _fadeController.reverse();
      } else {
        _animationController.stop();
        _fadeController.forward();
      }
    });
  }

  // 로그인 상태 확인
  String? value;
  Future<String?> loginCheck() async{
    final storage = FlutterSecureStorage();
    value = await storage.read(key:'loginM');
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return
      FutureBuilder(
        future: loginCheck(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bulldozer'),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {


                },
              ),
              actions: [
                ElevatedButton(onPressed: (){
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (_)=> ReportPage(userE:value ?? 'unknown')));

                }, child: const Text("신고 버튼")),
              ],
            ),
            body: AnimatedContainer(
              duration: const Duration(seconds: 1),
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
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.rotate(
                          angle: _animationController.value * 2 * 3.14159265359,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 2.0,
                              ),
                            ),
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    colors: const <Color>[Colors.blue, Colors.green],
                                    tileMode: TileMode.mirror,
                                    stops: [
                                      _animationController.value - 0.2,
                                      _animationController.value + 0.2
                                    ],
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  '화면 디스플레이 이미지\n(동작)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SwitchListTile(
                      title: const Text(''),
                      value: _isSwitchOn,
                      onChanged: _toggleAnimation,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _isSwitchOn ? '실시간 감시 중!' : '실시간 감시가 꺼져있습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isSwitchOn ? Colors.black : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '자동으로 백그라운드에서 애니메이션이 실행되며\n애플리케이션이 올바르게 작동합니다.',
                      style: TextStyle(
                        fontSize: 16,
                        color: _isSwitchOn ? Colors.black : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '필요 시에도 사용 가능합니다.\n준비된 기기를 보조 장치에 연결하십시오.',
                      style: TextStyle(
                        fontSize: 16,
                        color: _isSwitchOn ? Colors.black : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            drawer: Drawer(
              child: ListView(
                children: [
                  ListTile(
                      title: Text(value ?? 'unknown')
                  )
                ],
              ),
            ),

          );
        },


      );
  }


}