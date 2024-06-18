import 'package:bulldozer/login/firebase_service.dart';
import 'package:bulldozer/controller/UserController.dart';
import 'package:bulldozer/view/JoinComPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});


  @override
  State<JoinPage> createState() => _JoinPageState();

}

class _JoinPageState extends State<JoinPage> with TickerProviderStateMixin {
  userController uc=userController();
  static const setTimer=120; // 2:00 분을 초로 설정
  late AnimationController _formController;
  late Animation<double> _formAnimation;
  String _selectedAreaCode = '010';
  final List<String> _areaCodes = ['010', '02', '031', '062'];
  final List<String> forbiddenEmail=['INSERT','SELECT','UPDATE','DELETE','DROP','TRUNCATE'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  firebaseService fireSer=firebaseService();
  bool _validateEmail = false;
  bool _validatePassword = false;
  bool _validatePhone = false;
  bool _isPasswordVisible = false;

  bool _isButtonDisabled = false;
  String _buttonText = "이메일 인증";
  int _countdownTime = setTimer;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeInOut),
    );
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await _formController.forward();
  }

  @override
  void dispose() {
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _validateForm() async{ // 백 - 회원가입
    setState(() {
      _validateEmail = _emailController.text.isEmpty;
      _validatePassword = _passwordController.text.isEmpty;
      _validatePhone = _phoneController.text.isEmpty;
    });

    if (!_validateEmail && !_validatePassword && !_validatePhone) {

      bool isExist = await uc.selectM(_emailController.text);
      bool isForbidden=false;
      String checkEmailWord=_emailController.text.toUpperCase();
      for (String forbiddenWord in forbiddenEmail){
        if(checkEmailWord.contains(forbiddenWord))isForbidden=true;
      }
      if(isForbidden==true){
        Fluttertoast.showToast(msg: "사용 불가능한 이메일 입니다.");
      }else if(isExist==false){
        try {
          if (_emailController.text != "") {
            fireSer.getinfo(_emailController.text, _passwordController.text);
            bool res=await fireSer.checkAndJoin(context);
            if(res==true){
              uc.insertM(_emailController.text, _passwordController.text,_selectedAreaCode+_phoneController.text);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => JoinComPage(userEmail:_emailController.text),),(Route<dynamic>route)=>false);
            }
          }
        } catch (e) {
          Fluttertoast.showToast(msg: "이메일 인증 중 오류가 발생했습니다.");
          print(e);
        }
      }else{
        Fluttertoast.showToast(msg: "이미 가입된 이메일 입니다.");
      }

    }
  }

  Future<void> _sendVerificationEmail() async { // 백 - 이메일 검증 --완료
    if(_emailController.text==""){
      setState(() {
        _validateEmail = _emailController.text.isEmpty;
      });
      return;
    }
    bool isExist = await uc.selectM(_emailController.text);
    bool isForbidden=false;
    String dbtest=_emailController.text.toUpperCase();
    for (String forbiddenword in forbiddenEmail){
      if(dbtest.contains(forbiddenword))isForbidden=true;
    }
    if(isForbidden==true){
      Fluttertoast.showToast(msg: "사용 불가능한 이메일 입니다.");
    }else if(isExist==false){
      try {
        if (_emailController.text != "") {
          fireSer.getinfo(_emailController.text,_passwordController.text);
          fireSer.createTempAccountAndVerifyEmail(context);
          Fluttertoast.showToast(msg: "인증 이메일이 전송되었습니다. 이메일을 확인하세요.");
          _startCountdown();
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "이메일 인증 중 오류가 발생했습니다.");
      }
    }else{
      Fluttertoast.showToast(msg: "이미 가입된 이메일 입니다.");
    }

  }

  void _startCountdown() {
    setState(() {
      _isButtonDisabled = true;
      _buttonText = "T : ";
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownTime > 0) {
          _countdownTime--;
        } else {
          timer.cancel();
          _isButtonDisabled = false;
          fireSer.deleteUser();
          _countdownTime=setTimer;
          _buttonText = "이메일 인증";
        }
      });
    });
  }

  Widget _buildNumberedTextField({
    required String number,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    bool isDropdown = false,
    bool isPassword = false,
    bool showValidationError = false,
    String? buttonText,
    VoidCallback? buttonOnPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.deepOrangeAccent,
                  child: Text(
                    number,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 높이 줄임
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.deepOrangeAccent),
                      const SizedBox(width: 16),
                      if (isDropdown)
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAreaCode,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedAreaCode = newValue!;
                              });
                            },
                            items: _areaCodes.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            style: const TextStyle(color: Colors.black),
                            iconEnabledColor: Colors.deepOrangeAccent,
                            dropdownColor: Colors.white,
                            iconSize: 24,
                          ),
                        ),
                      if (isDropdown) const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: hintText,
                            border: InputBorder.none,
                          ),
                          obscureText: isPassword && !_isPasswordVisible,
                          keyboardType: isDropdown ? TextInputType.number : TextInputType.text,
                          inputFormatters: isDropdown
                              ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)]
                              : [],
                        ),
                      ),
                      if (isPassword)
                        IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.deepOrangeAccent,
                          ),
                          onPressed: () {
                            print("암호 보이기");
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (buttonText != null)
            Padding(
              padding: const EdgeInsets.only(left: 64.0, top: 8.0),
              child: TextButton(
                onPressed: buttonOnPressed,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(buttonText),
                    if (_isButtonDisabled)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${(_countdownTime ~/ 60).toString().padLeft(2, '0')}:${(_countdownTime % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (showValidationError)
            const Padding(
              padding: EdgeInsets.only(left: 180.0, top: 10),
              child: Text(
                '* 정보를 입력해주세요!',
                style: TextStyle(color: Colors.pink, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.amber[500],
        leading: IconButton(

          icon: Icon(Icons.arrow_back,color: Colors.black87),

          onPressed: () {
            //뒤로가기
            Navigator.of(context).pop();
          },
        ),
        title: Text('가입 신청하기',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color : Colors.black87),),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Text(
                            "Hello",
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "도",
                              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "박 지킴이",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "   저희 서비스는 효과적인 불법 사이트와 도박 관련 \n범죄 예방을 위해 "
                              "부단히 노력하고 꾸준한 업데이트 중입니다.",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(thickness: 3, color: Colors.white, indent: 170, endIndent: 33,),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Join us',
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),//
                  Padding(
                    padding: const EdgeInsets.only(left: 32, right: 32),
                    child: Text(
                      "   이메일 인증을 완료 후 가입하실 비밀번호를 입력해주세요. 보호자 연락처는 추후 차단 서비스에 이용됩니다.",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 22,),
                  FadeTransition(
                    opacity: _formAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 27.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 192),
                                child: Text("E-mail",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                  textAlign: TextAlign.left,

                                ),
                              ),
                              TextButton(
                                onPressed: _isButtonDisabled ? null : _sendVerificationEmail,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.deepOrange[900],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_buttonText),
                                    if (_isButtonDisabled)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '${(_countdownTime ~/ 60).toString().padLeft(2, '0')}:${(_countdownTime % 60).toString().padLeft(2, '0')}',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          _buildNumberedTextField(
                            number: "①",
                            hintText: '가입하실 E-mail을 입력하세요.',
                            icon: Icons.email,
                            controller: _emailController,
                            showValidationError: _validateEmail,
                          ),

                          const SizedBox(height: 4),
                          const Divider(thickness: 1, color: Colors.white, indent: 48, endIndent: 2,),
                          Padding(
                            padding: const EdgeInsets.only(right: 275, top: 10),
                            child: Text("비밀번호",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                              textAlign: TextAlign.left,

                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildNumberedTextField(
                            number: "②",
                            hintText: '비밀번호를 입력하세요.',
                            icon: Icons.lock,
                            controller: _passwordController,
                            isPassword: true,
                            showValidationError: _validatePassword,
                          ),
                          const SizedBox(height: 16),
                          const Divider(thickness: 1, color: Colors.white, indent: 48, endIndent: 2,),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(right: 228),
                            child: Text("보호자 연락처",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                              textAlign: TextAlign.left,

                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildNumberedTextField(
                            number: "③",
                            hintText: '보호자 연락처 기입',
                            icon: Icons.person,
                            controller: _phoneController,
                            isDropdown: true,
                            showValidationError: _validatePhone,
                          ),
                          SizedBox(height: 20,),
                          ElevatedButton(
                            onPressed: _validateForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange[900],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 5,
                            ),

                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(80, 0, 87, 0),
                              child: const Text('회원 가입', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
