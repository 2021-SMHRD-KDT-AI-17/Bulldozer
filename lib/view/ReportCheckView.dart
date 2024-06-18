import 'package:bulldozer/main.dart';
import 'package:bulldozer/view/AdminView.dart';
import 'package:bulldozer/view/DictView.dart';
import 'package:bulldozer/view/UrlListView.dart';
import 'package:bulldozer/view/UserListView.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controller/ReportController.dart';
import '../../view/ReportDetailView.dart';
import 'package:rive/rive.dart';
import 'package:flutter/src/painting/gradient.dart' as flutterPainting;


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
        report.getAnalysis,
        report.getTitle,
        report.getAt
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
            padding: const EdgeInsets.only(left: 57),
            child: Text(
              '신고/건의 게시판',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
          backgroundColor: Colors.amber[500],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: flutterPainting.LinearGradient( // flutterPainting 별칭 사용
                    colors: [
                      Colors.amber,
                      Colors.deepOrange,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Image.asset('images/free-icon-admin-1085798.png',
                          width: 100, height: 100),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    VerticalDivider(
                      thickness: 2,
                      color: Colors.amber[800],
                      indent: 10,
                      endIndent: 10,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 55, left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Admin님 \n환영합니다.",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 0),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    size: 28,
                    color: Colors.amber[800],
                  ),
                  title: Text(
                    " 메인 화면",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  onTap: () {
                    // 홈 화면으로 이동
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AdminPage()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.playlist_add_check_rounded,
                    size: 28,
                    color: Colors.amber[800],
                  ),
                  title: Text(
                    " 신고/건의 게시판",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => ReportCheckPage()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.people_outline_rounded,
                    size: 28,
                    color: Colors.amber[800],
                  ),
                  title: Text(
                    " 회원 관리",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  onTap: () {
                    // 회원 관리 페이지로 이동
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => UserList()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.warning,
                    size: 28,
                    color: Colors.amber[800],
                  ),
                  title: Text(
                    " 유해 사이트 목록",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => HarmSiteList()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.book_rounded,
                    size: 28,
                    color: Colors.amber[800],
                  ),
                  title: Text(
                    " 단어 사전 열람",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => DictionaryPage()));
                  },
                ),
              ),
              SizedBox(height: 60,),
              Divider(
                thickness: 2,
                color: Colors.amber[800],
                indent: 30,
                endIndent: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 120, top: 150),
                child: ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    size: 28,
                    color: Colors.amber[800],
                  ),
                  title: Text(
                    "로그아웃",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage(),),(Route<dynamic>route)=>false);
                  },
                ),
              ),
            ],
          ),
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border(
                          top: BorderSide(color: Colors.black, width: 1),
                          left: BorderSide(color: Colors.black, width: 1),
                          right: BorderSide(color: Colors.black, width: 6),
                          bottom: BorderSide(color: Colors.black, width: 6),
                        ),
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
                  padding: const EdgeInsets.only(left: 20, right: 80, bottom: 5),
                  child: Text("신고 목록",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, top: 16),
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
                          border: Border.all(width: 1, color: Colors.black87),
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
