import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controller/ReportController.dart';
import '../../view/ReportDetailView.dart';
import 'package:rive/rive.dart';


import 'package:bulldozer/db.dart';

class ReportCheckPage extends StatefulWidget {
  const ReportCheckPage({super.key});

  @override
  _ReportCheckPageState createState() => _ReportCheckPageState();
}

class _ReportCheckPageState extends StateMVC<ReportCheckPage> {
  late reportController ReportController;

  _ReportCheckPageState() : super(reportController()) {
    ReportController = controller as reportController;
  }

  List<List<dynamic>> reports = [];
  final Set<int> _selectedIndices = Set<int>();
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ReportController.loadData();
    setState(() {
      reports = List<List<dynamic>>.from(ReportController.reports.map((report) => [
        report.getIdx,
        report.getEmail,
        report.getAddress,
        report.getDescript,
      ]));
    });
  }

  void _reloadData() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (reports.length / _itemsPerPage).ceil();
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = (_currentPage * _itemsPerPage).clamp(0, reports.length);
    final List<List<dynamic>> currentItems = reports.sublist(startIndex, endIndex);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, reports);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 62),
            child: Text(
              '신고/건의 게시판',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
          backgroundColor: Colors.amber[500],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    child: RiveAnimation.asset(
                      'assets/solicitud_de_cuentas.riv',
                      fit: BoxFit.cover,
                      animations: ['Animation 1'], // 재생할 애니메이션 이름
                    ),
                  ),
                  Divider(
                    height: 10, // Divider의 폭을 줄임
                    color: Colors.amber,
                    thickness: 2,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1, color: Colors.black87),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.7),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(1, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '총 신고 건수',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${reports.length}", style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent),),
                              Text(" 건", style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 120, bottom: 5),
                  child: Text("신고 목록",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text("클릭시 상세 내용으로 이동합니다.",
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey),),
                )
              ],
            ),
            Divider(
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.blueGrey,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: currentItems.length,
                itemBuilder: (context, index) {
                  final reportItem = currentItems[index];
                  return Dismissible(
                    key: Key(reportItem[0].toString()), // Unique key for each item
                    background: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    direction: DismissDirection.startToEnd,
                    dismissThresholds: {DismissDirection.startToEnd: 0.25},
                    onDismissed: (direction) {
                      setState(() {
                        reports.removeAt(startIndex + index);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black87),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportDetailPage(
                                report: reportItem,
                                reloadReports: _reloadData,
                              ),
                            ),
                          );
                          if (result != null) {
                            _reloadData();
                          }
                        },
                        child: Row(
                          children: [
                            SizedBox(width: 5,),
                            CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(Icons.report, color: Colors.yellow, size: 28,),
                            ),
                            SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reportItem[1],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(reportItem[2]),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,),
                            SizedBox(width: 10,),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  ...List.generate(totalPages, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentPage = index + 1;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _currentPage == index + 1 ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1,color: Colors.black87),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: _currentPage == index + 1 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10), // 페이지네이션과 FAB 사이의 간격 조절
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton(
            onPressed: _reloadData,
            child: Icon(Icons.refresh),
            backgroundColor: Colors.amber,
          ),
        ),
      ),
    );
  }
}