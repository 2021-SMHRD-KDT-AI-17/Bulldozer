import 'package:bulldozer/view/ReportComPage.dart';
import 'package:flutter/material.dart';
import '../../controller/ReportController.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ReportPage extends StatefulWidget {
  final String userE;
  const ReportPage({Key? key, required this.userE}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends StateMVC<ReportPage> {
  late reportController ReportController;

  TextEditingController addCon = TextEditingController();
  TextEditingController descriptCon = TextEditingController();

  _ReportPageState() : super(reportController()) {
    ReportController = controller as reportController;
  }

  @override
  void dispose() {
    addCon.dispose();
    descriptCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDFCF7),
        title: const Text("유해 사이트 신고"),
        actions: [
          Padding(

            padding: const EdgeInsets.only(right: 32),

            child: Image.asset("images/icons/home.png", scale: 20, ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFFDFCF7), // 이미지 배경색으로 설정
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 68,),
                        Text(
                          "  오늘도 여러분들의 제보가",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "  더 밝은 사회를 만듭니다.",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "  감사합니다.",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 200,
                      width: 180,
                      decoration: const BoxDecoration(
                        color: Color(0xffFFFEFC), // 이미지 배경색과 동일하게 설정
                        image: DecorationImage(
                          image: AssetImage('images/children.jpg'), // 예시 이미지 경로
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white, // 여전히 하얀색 배경
                  border: Border.all(color: Colors.black, style: BorderStyle.solid),

                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
                    const Text(
                      "신청 양식",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: addCon,
                      decoration: InputDecoration(
                        enabledBorder : const UnderlineInputBorder(),
                        labelText: '유해 사이트 URL 입력',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      maxLines: 6,
                      controller: descriptCon,
                      decoration: InputDecoration(
                        labelText: '상세 설명',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        //신고하기
                        _insertReport(widget.userE, addCon.text, descriptCon.text);
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ReportComPage(),),(Route<dynamic>route)=>false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent, // 버튼 배경 색상 설정
                        foregroundColor: Colors.white, // 버튼 텍스트 색상 설정
                        minimumSize: const Size(double.infinity, 50),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'images/icons/siren_icon2.png', // 아이콘 경로 설정
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text("신고하기"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {

                        // 신고내역


                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent, // 버튼 배경 색상 설정
                        foregroundColor: Colors.white, // 버튼 텍스트 색상 설정
                        minimumSize: const Size(double.infinity, 50),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'images/icons/list_icon.png', // 아이콘 경로 설정
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text("신고내역 확인하기"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 신고
  Future<void> _insertReport(String email, String address, String descript) async{
    await ReportController.insertReport(email, address, descript);
  }
}

