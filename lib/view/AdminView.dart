import 'package:bulldozer/main.dart';
import 'package:bulldozer/view/DictView.dart';
import 'package:bulldozer/view/UrlListView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controller/ReportController.dart';
import '../../view/ReportCheckView.dart';
import '../../view/UserListView.dart';
import 'package:rive/rive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controller/BlockHisController.dart';
import '../db.dart';
import 'package:flutter/painting.dart' as flutterPainting;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


const Color bottomNavBgColor = Color(0xFF17203A);

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPage2State createState() => _AdminPage2State();
}

class _AdminPage2State extends StateMVC<AdminPage> with SingleTickerProviderStateMixin {
  late blockHisController BlockHisController;
  late reportController ReportController;
  late RiveAnimationController _riveController; // Rive 컨트롤러 정의
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  _AdminPage2State() : super() {
    BlockHisController = blockHisController();
    ReportController = reportController();
  }

  List<List> report = [];
  bool isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    _riveController = SimpleAnimation('Hover Animation'); // Rive 컨트롤러 초기화
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1), // 애니메이션 지속 시간
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _initializeData();
  }

  @override
  void dispose() {
    _riveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    // 현재 스크롤 위치에서 화면 높이만큼 아래로 스크롤합니다.
    _scrollController.animateTo(
      _scrollController.position.pixels + MediaQuery.of(context).size.height,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    await loadAllData();
    await _getRecent();
    setState(() {
      isLoading = false;
    });
    _fadeController.forward(); // 페이드 애니메이션 시작
  }

  Future<void> _getRecent() async {
    report.clear();
    await ReportController.getRecent();
    report = List<List<dynamic>>.from(res);
    setState(() {});
    print(report);
  }

  Future<void> loadAllData() async {
    try {
      await loadWeekData();
      await loadSixMonthsData();
      await loadYearData();
      await loadGeneralData();
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> loadWeekData() async {
    final data = await BlockHisController.getWeek();
    setState(() {
      weekData = data;
    });
    print("Week Data: $weekData");
  }
  Future<void> loadSixMonthsData() async {
    final data = await BlockHisController.getSixMonths();
    setState(() {
      sixMonthsData = data;
    });
    print("Six Months Data: $sixMonthsData");
  }
  Future<void> loadYearData() async {
    final data = await BlockHisController.getYear();
    setState(() {
      yearData = data;
    });
    print("Year Data: $yearData");
  }
  Future<void> loadGeneralData() async {
    final data = await getData();
    setState(() {
      todayCount = data['today']!;
      totalCount = data['total']!;
      totalSiteCount = data['totalsite']!;
    });
    print(
        "General Data: today=$todayCount, total=$totalCount, totalsite=$totalSiteCount");
  }

  Future<Map<String, int>> getData() async {
    final todayCount = await BlockHisController.getToday();
    final totalCount = await BlockHisController.getTotal();
    final totalSiteCount = await BlockHisController.getTotalSite();
    return {
      'today': todayCount,
      'total': totalCount,
      'totalsite': totalSiteCount
    };
  }

  List<BarChartGroupData> getBarChartData() {
    switch (selectedPeriod) {
      case 1:
        return List.generate(
          sixMonthsData.length,
              (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: sixMonthsData[index].toDouble(),
                  color: Colors.lightBlueAccent)
            ],
          ),
        );
      case 2:
        return List.generate(
          yearData.length,
              (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: yearData[index].toDouble(),
                  color: Colors.lightBlueAccent)
            ],
          ),
        );
      default:
        return List.generate(
          weekData.length,
              (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: weekData[index].toDouble(),
                  color: Colors.lightBlueAccent)
            ],
          ),
        );
    }
  }

  List<String> getTitles() {
    DateTime now = DateTime.now();
    switch (selectedPeriod) {
      case 1:
        return List.generate(6, (index) {
          DateTime date = DateTime(now.year, now.month - (5 - index));
          return DateFormat('MM').format(date);
        });
      case 2:
        return List.generate(12, (index) {
          DateTime date = DateTime(now.year, now.month - (11 - index));
          return DateFormat('MM').format(date);
        });
      default:
        return List.generate(7, (index) {
          DateTime date = now.subtract(Duration(days: 6 - index));
          return DateFormat('MM/dd').format(date);
        });
    }
  }

  List<int> weekData = [];
  List<int> sixMonthsData = [];
  List<int> yearData = [];
  int todayCount = 0;
  int totalCount = 0;
  int totalSiteCount = 0;
  int selectedPeriod = 0; // 0: 최근 1주일, 1: 최근 6개월, 2: 최근 1년

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(
            "Bulldozer System",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.amber[400],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: flutterPainting.LinearGradient(  // flutterPainting 별칭 사용
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
                  SizedBox(width: 15,),
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
                          "관리자님 \n환영합니다.",
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
                      context, MaterialPageRoute(builder: (_) =>  ReportCheckPage()));
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
                  " 유해사이트 목록 ",
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
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : FadeTransition( // 페이드 애니메이션을 적용
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[400],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: '빈칸',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 7,
                                  )),
                              TextSpan(
                                text: '총 ',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '$totalSiteCount',
                                style: TextStyle(
                                  color: Colors.redAccent[700],
                                  fontSize: 28, // 원하는 크기로 설정
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              TextSpan(
                                text: ' 개의 유해사이트를\n',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              TextSpan(
                                text: '$totalCount',
                                style: TextStyle(
                                  color: Colors.redAccent[700],
                                  fontSize: 28, // 원하는 크기로 설정
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' 번 차단했습니다.',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 65),
                          child: Text(
                            "  유해 사이트 검출 현황",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 50,),
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: RiveAnimation.asset(
                              'assets/c4real_graph_icon.riv',
                              controllers: [_riveController],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 5, 8),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedPeriod = 0;
                          });
                        },
                        child: Text(
                          ' 최근 1주일',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPeriod == 0
                              ? Colors.amber
                              : Colors.white70,
                          side: BorderSide(width: 1, color: Colors.black87),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 5, 8),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedPeriod = 1;
                          });
                        },
                        child: Text(
                          ' 최근 6개월',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPeriod == 1
                              ? Colors.amber
                              : Colors.white,
                          side: BorderSide(width: 1, color: Colors.black87),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 8),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedPeriod = 2;
                          });
                        },
                        child: Text(
                          '  최근 1년  ',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPeriod == 2
                              ? Colors.amber
                              : Colors.white,
                          side: BorderSide(width: 1, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 200,
                  width: 350, // 차트의 넓이를 늘립니다.
                  color: Colors.white70, // 차트 영역
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: selectedPeriod == 0 ? 500 : 5000,
                      barTouchData: BarTouchData(enabled: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        getDrawingVerticalLine: (value) {
                          if (value == 3) {
                            // 원하는 위치에 점선을 그립니다.
                            return FlLine(
                              color: Colors.grey,
                              strokeWidth: 3,
                              dashArray: [3, 5], // 점선 설정
                            );
                          }
                          return FlLine(
                            color: Colors.transparent,
                          );
                        },
                        drawHorizontalLine: true,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey,
                            strokeWidth: 1,
                            dashArray: [3, 3], // 점선 설정
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        // 차트 전체 숫자 지우기
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget:
                                (double value, TitleMeta meta) {
                              const style = TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              );
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 6.0, // 적절한 여백 설정
                                child: Text(
                                    getTitles().elementAt(value.toInt()),
                                    style: style),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: selectedPeriod == 0 ? 100 : 1000,
                            getTitlesWidget:
                                (double value, TitleMeta meta) {
                              var style = TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: selectedPeriod == 0 ? 8 : 6,
                              );
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 1.0, // 여백을 늘려서 텍스트가 잘리지 않도록 합니다.
                                child: Text(value.toInt().toString(),
                                    style: style),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          // 이 부분을 추가하여 topTitles를 비활성화합니다.
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                      // 6.11 차트 박스 테두리 없앰
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: getBarChartData(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text("데이터를 한 눈에!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 21, right: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 12, 19, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueGrey),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '오늘의 차단 건수',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$todayCount건',
                              style: TextStyle(
                                  fontSize: 19, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // 좌, 위, 우, 아래
                        padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueGrey),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '누적 차단 건수',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$totalCount건',
                              style: TextStyle(
                                  fontSize: 19, color: Colors.red, fontWeight: FontWeight.bold),
                            ),

                          ],
                        ),

                      ),

                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.only(left: 240),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: formattedDate,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: " 기준",
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.keyboard_double_arrow_down_rounded),
                    color: Colors.lightBlueAccent,
                    iconSize: 50,
                  ),
                ),
                Column(
                  children: [
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 10),
                        child: Text('미등록 유해사이트 신고',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      trailing: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text("자세히"),
                          ),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportCheckPage()),
                        );
                        if (result != null) {
                          setState(() {
                            report.clear();
                            report.addAll(result);
                          });
                        }
                      },
                    ),
                    Column(
                      children: buildReportWidgets(),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildReportWidgets() {
    List<Widget> reportWidgets = [];
    for (int i = 0; i < report.length; i++) {
      reportWidgets.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: ListTile(
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "작성자: ",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      TextSpan(
                        text: report[i][1],
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "URL 주소: ",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      TextSpan(
                        text: report[i][2],
                        style: TextStyle(fontSize: 11, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                trailing: Text(/////여기
                  DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(report[i][6])),
                  style: TextStyle(fontSize: 11, color: Colors.black),
                ),
                contentPadding:
                EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              ),
            ),
          ],
        ),
      );
    }
    return reportWidgets;
  }
}