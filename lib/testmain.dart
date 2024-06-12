import 'package:bulldozer/controller/UserController.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bulldozer/login/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final firebaseService fs=firebaseService();
  dynamic dioResultJson = '';
  String dioResultValue = '';
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(onPressed: (){
              test();
            }, child: Text('flask테스트')),
            ElevatedButton(onPressed: (){

            }, child: Text(''))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void test() async{
    {
      print("Click");
      final dio= Dio();
      // API 요청
      final response;
      try {
        response = await dio.post(
          'http://192.168.219.66:5000/service/',
          data: {"url":"totogun.com/bbs/board.php?bo_table=gnb_74","id":"ahtm8210@daum.net"},
        );
        print("!");
        print(response.data);
      } catch (e) {
        print("Error: $e");
      }
      print("!");
      // // API 응답 결과 반영을 위한 상태 변경
      // setState(() {
      //   // 전체 값 호출
      //   dioResultJson = response.data;
      //
      //   // 특정 키 값 호출 : 'result' 키의 값 호출
      //   dioResultValue = response.data['result'];
      // });
    }
  }
}
