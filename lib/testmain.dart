import 'package:bulldozer/controller/user_controller.dart';
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

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    fs.getinfo("ahtm8210@naver.com","");
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
              fs.createTempAccountAndVerifyEmail(context);
            }, child: Text('가입실험')),
            ElevatedButton(onPressed: (){
              // fs.isEmailChecked();
            }, child: Text('가입확인실험')),
            ElevatedButton(onPressed: (){
              userController uc=userController();
              uc.loadData();
              print(uc.users);
            }, child: Text('DBtest')),
            ElevatedButton(onPressed: (){
              userController uc=userController();
              uc.insertM("test01234","test234","01033334444");
            }, child: Text('DBinsertTest')),
            ElevatedButton(onPressed: (){
              userController uc=userController();
              uc.selectM("asdasd");
            }, child: Text('DBselectTest'))
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
}
