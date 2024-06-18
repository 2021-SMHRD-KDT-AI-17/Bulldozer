import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controller/ReportController.dart';

class ReportDetailPage extends StatefulWidget {
  final List report;
  final Function reloadReports;

  ReportDetailPage({required this.report, required this.reloadReports});

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends StateMVC<ReportDetailPage> {
  late reportController ReportController;

  _ReportDetailPageState() : super() {
    ReportController = reportController();
  }

  Future<void> _deleteReport(String email, int index) async {
    await ReportController.deleteReport(email, index);
  }

  void _showAnalysisResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Text(
            '신고 분석 결과',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
          ),
          content: Text('정말로 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '아니오',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteReport(widget.report[1], int.parse(widget.report[0]));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                widget.reloadReports();
              },
              child: Text(
                '예',
                style: TextStyle(color: Colors.red[800]),
              ),
            ),
          ],
          backgroundColor: Colors.amber[50], // AlertDialog의 배경색 설정
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Text('신고 게시판', style: TextStyle(fontWeight: FontWeight.bold,),),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.amber[300],
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.amber[300],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5, bottom: 10),
                            child: Text(
                              '작성자',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Table(
                            border: TableBorder.all(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                              width: 2,
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(4),
                              1: FlexColumnWidth(9),
                            },
                            children: [

                              TableRow(
                                children: [
                                  Container(
                                    color: Colors.amber[300],
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          "이메일",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.report.length > 1 ? widget.report[1] : 'N/A', // 유효성 검사
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Container(
                                    color: Colors.amber[300],
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          "신고 일자",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.report.length > 6 ? widget.report[6] : 'N/A', // 유효성 검사
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 26),
                          Padding(
                            padding: const EdgeInsets.only(left: 5, bottom: 15),
                            child: Text(
                              '신고 URL',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 50.0,
                              maxHeight: 180.0,
                              minWidth: double.infinity,
                            ),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black87, width: 2),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              widget.report.length > 2 ? widget.report[2] : 'N/A', // 유효성 검사
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(left: 5, bottom: 10),
                            child: Text(
                              '상세 신고 내용',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 170.0,
                              maxHeight: 180.0,
                              minWidth: double.infinity,
                            ),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black87, width: 2),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              widget.report.length > 3 ? widget.report[3] : 'N/A', // 유효성 검사
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _showAnalysisResultDialog(context),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black87),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '신고 분석 결과',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                              ),
                              SizedBox(height: 18),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15, top: 5, right: 3),
                                    child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Image.asset("images/free-icon-magnifying-glass-6299779.png")),
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                    width: 200,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      "유해 사이트입니다.",
                                      // widget.report[4],
                                      textAlign: TextAlign.center,
                                      // 이 부분 유해사이트라고 판단되면 "유해 사이트입니다.", 아니면 "합법 사이트입니다."
                                      style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('이전으로',
                                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteReport(widget.report[1], int.parse(widget.report[0]));
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('삭제하기',
                                        style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1,),
                            ],
                          ),

                        ),

                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
