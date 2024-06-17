import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controller/WebController.dart';
import '../../controller/BlockHisController.dart';
import '../db.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';



class HarmSiteList extends StatefulWidget {
  const HarmSiteList({Key? key}) : super(key: key);

  @override
  _HarmSiteListState createState() => _HarmSiteListState();
}

class _HarmSiteListState extends StateMVC<HarmSiteList> {
  late blockHisController BlockHisController;
  bool isLoading = true;

  _HarmSiteListState() : super() {
    BlockHisController = blockHisController();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await BlockHisController.loadData();
    countAdd(); // 데이터 로드 후 countAdd 호출
    setState(() {
      isLoading = false;
    });
  }

  // 리스트로 선언하여 카운트 저장
  List<List<dynamic>> countList = [];

  void countAdd() {
    countList.clear();
    for (int i = 0; i < res.length; i++) {
      String email = res[i][1];
      String site = res[i][2] != null ? res[i][2].split('/')[0] : ''; // null 체크 추가
      String at = res[i][3];

      // 사이트를 리스트에서 찾기
      bool found = false;
      for (int j = 0; j < countList.length; j++) {
        if (countList[j][0] == site) {
          // 이메일과 접속 시간을 리스트에 추가하거나 업데이트
          bool emailFound = false;
          List<List<String>> emailList = countList[j][1] as List<List<String>>;
          for (int h = 0; h < emailList.length; h++) {
            if (emailList[h][0] == email) {
              emailList[h][1] = at; // 접속 시간 업데이트
              emailFound = true;
              break;
            }
          }
          if (!emailFound) {
            emailList.add([email, at]); // 새로운 이메일과 접속 시간 추가
          }

          // 접속 횟수 증가
          ++countList[j][2];
          found = true;
          break;
        }
      }

      // 해당 사이트를 찾지 못하면 새로운 사이트와 이메일 리스트 추가
      if (!found) {
        countList.add([site, [[email, at]], 1]); // 사이트, 이메일 리스트, 초기 횟수
      }
    }

    print(countList);
    //setState(() { });
  }

  List<List> urlAt = [];
  Future<void> _getBlockAt() async {
    for (int i = 0; i < countList.length; i++) {
      await BlockHisController.getBlockAt(countList[i][1], countList[i][0]);
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.ListView.builder(
            itemCount: countList.length,
            itemBuilder: (context, index) {
              return pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${countList[index][0]}  차단횟수(${countList[index][2]})',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: List<pw.TableRow>.generate(countList[index][1].length, (i) {
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(
                                countList[index][1][i][0],
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(
                                countList[index][1][i][1],
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    // Save the PDF file
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    countAdd();
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 50),
          child: const Text('유해 사이트 목록', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? Center(
        child: Lottie.asset('assets/lottiefiles/loading_orange.json'),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40, top: 20),
                      child: Image.asset(
                        "images/free-icon-warning-sign-3076336.png", // 이미지 경로 설정
                        width: 120,
                        height: 120,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 23, bottom: 20),
                      child: Text(
                        "검출된 사이트와 관련된 \n차단 횟수를 제공합니다.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Spacer(), // 왼쪽과 오른쪽 공간을 나눔
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 5,),
                    Container(
                      height: 40,
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.amber[100],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.print),
                            onPressed: _generatePdf,
                          ),
                          Text("PDF로 다운로드"),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Container(
                      height: 40,
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.amber[200],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              // 공유 기능 추가
                            },
                          ),
                          Text("링크 공유하기"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: List.generate(countList.length, (index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              countList[index][0],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '차단횟수: ${countList[index][2].toString().padLeft(4, ' ')}', // 숫자 고정 폭
                            style: TextStyle(
                              fontFeatures: [FontFeature.tabularFigures()], // 고정 폭 숫자 사용
                            ),
                          ),
                        ],
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Table(
                            columnWidths: {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Container(
                                    color: Colors.amber[300],
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '이메일',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    color: Colors.amber[300],
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '차단 일자',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              for (var emailData in countList[index][1])
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        emailData[0],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        emailData[1],
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
