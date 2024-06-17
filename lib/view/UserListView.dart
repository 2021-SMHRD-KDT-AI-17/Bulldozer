import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controller/BlockHisController.dart';
import '../../controller/UserController.dart';
import '../../db.dart';
import '../../controller/UserconHisController.dart';
import 'package:fl_chart/fl_chart.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

List<List> user = [];
List<List> userConHis = [];
List<List> blockCnt = [];
List<List> withTC = []; // user + 차단시작/종료 시간

class _UserListState extends StateMVC<UserList> with SingleTickerProviderStateMixin {
  late userController UserController;
  late userconHisController UserconHisController;
  late blockHisController BlockHisController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoading = true; // 로딩 상태 추가
  int currentPage = 0;
  int itemsPerPage = 6; // 페이지당 항목 수
  final ScrollController _scrollController = ScrollController();

  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadData();
  }

  _UserListState() : super() {
    UserController = userController();
    UserconHisController = userconHisController();
    BlockHisController = blockHisController();
  }

  // 데이터 불러오기
  Future<void> _loadData() async {
    user.clear();
    userConHis.clear();
    blockCnt.clear();
    withTC.clear();

    await UserController.list();
    user = List<List<dynamic>>.from(res);

    await UserconHisController.loadData();
    userConHis = List<List<dynamic>>.from(res);

    await BlockHisController.getBlockCnt();
    blockCnt = List<List<dynamic>>.from(res);

    // 사용자 차단 이력과 사용자 정보를 비교하여 화면에 표시할 데이터 구성
    for (List<dynamic> userData in user) {
      bool foundConHis = false;
      String email = userData[0];
      String start = "-";
      String end = "-";
      int blockCount = 0;

      for (List<dynamic> userConHisData in userConHis) {
        if (email == userConHisData[0]) {
          start = userConHisData[2];
          end = userConHisData[3] ?? "-";
          foundConHis = true;
          break;
        }
      }

      for (List<dynamic> blockData in blockCnt) {
        if (email == blockData[0]) {
          blockCount = int.parse(blockData[1]);
          break;
        }
      }

      withTC.add([
        userData,
        start, // 차단 시작 시간
        end, // 차단 종료 시간이 없으면 "-"로 설정
        blockCount > 0 ? blockCount.toString() : "-" // 차단 횟수
      ]);
    }

    // user 테이블에 없는 이메일들 추가
    for (List<dynamic> blockData in blockCnt) {
      bool found = false;
      String email = blockData[0];
      for (List<dynamic> userData in user) {
        if (email == userData[0]) {
          found = true;
          break;
        }
      }
      if (!found) {
        withTC.add([
          [email],
          "-", // 차단 시작 시간
          "-", // 차단 종료 시간
          int.parse(blockData[1]) > 0 ? blockData[1].toString() : "-" // 차단 횟수
        ]);
      }
    }

    setState(() {
      isLoading = false; // 로딩 상태 업데이트
      _animationController.forward(from: 0.0);
    });
  }

  int getActiveUsers() {
    return withTC.where((user) {
      String start = user[1];
      String end = user[2];
      if (start == "-") {
        return false;
      }
      if (end == "-") {
        return true;
      }
      return DateTime.parse(start).isBefore(DateTime.now()) &&
          DateTime.parse(end).isAfter(DateTime.now());
    }).length;
  }

  int getInactiveUsers() {
    return withTC.length - getActiveUsers();
  }

  Widget _buildCardContent(List<dynamic> withTCData) {
    String start = withTCData[1];
    String end = withTCData[2];
    String statusText;
    Color statusColor;

    if (start == "-" || (end != "-" && DateTime.parse(start).isAfter(DateTime.now()))) {
      statusText = "비활성화 중";
      statusColor = Colors.red.shade100;
    } else {
      statusText = "활성화 중";
      statusColor = Colors.blue.shade100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            "${withTCData[0][0]}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: const TextStyle(color: Colors.black, fontSize: 13),
            ),
          ),
        ),
        Divider(color: Colors.black87, thickness: 0.7, indent: 16, endIndent: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "차단 시작                          $start",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "차단 종료                          $end",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "유해 URL 접속 횟수          ${withTCData[3]}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
      ],
    );
  }

  List<List> getPaginatedData() {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > withTC.length) {
      endIndex = withTC.length;
    }
    return withTC.sublist(startIndex, endIndex);
  }

  Widget buildPagination() {
    List<Widget> pages = [];
    int totalPages = (withTC.length / itemsPerPage).ceil();

    // First and Previous buttons
    pages.add(IconButton(
      icon: const Icon(Icons.first_page, size: 20,),
      onPressed: currentPage > 0
          ? () {
        setState(() {
          currentPage = 0;
        });
      }
          : null,
    ));
    pages.add(IconButton(
      icon: const Icon(Icons.chevron_left),
      onPressed: currentPage > 0
          ? () {
        setState(() {
          currentPage--;
        });
      }
          : null,
    ));

    // Page number buttons
    int startPage = currentPage > 4 ? currentPage - 4 : 0;
    int endPage = startPage + 9 < totalPages ? startPage + 9 : totalPages - 1;

    for (int i = startPage; i <= endPage; i++) {
      pages.add(
        TextButton(
          onPressed: () {
            setState(() {
              currentPage = i;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8), // 높이 줄이기
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: i == currentPage ? Colors.blue : Colors.transparent,
            ),
            child: Text(
              (i + 1).toString(),
              style: TextStyle(
                fontSize: 14, // 폰트 크기 줄이기
                color: i == currentPage ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    // Next and Last buttons
    pages.add(IconButton(
      icon: const Icon(Icons.chevron_right),
      onPressed: currentPage < totalPages - 1
          ? () {
        setState(() {
          currentPage++;
        });
      }
          : null,
    ));
    pages.add(IconButton(
      icon: const Icon(Icons.last_page),
      onPressed: currentPage < totalPages - 1
          ? () {
        setState(() {
          currentPage = totalPages - 1;
        });
      }
          : null,
    ));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pages,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<List> paginatedData = getPaginatedData();
    int activeUsers = getActiveUsers();
    int inactiveUsers = getInactiveUsers();
    double activePercentage = withTC.length > 0 ? (activeUsers / withTC.length) * 100 : 0;
    double inactivePercentage = withTC.length > 0 ? (inactiveUsers / withTC.length) * 100 : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 84),
          child: Text("회원 목록",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 애니메이션
          : FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber,
                      Colors.deepOrange,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                  ),
                ),
                height: 60,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 40,
                      child: Text(
                        "현재 가입 회원 수는 ",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      right: 20,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              width: 100,
                              child: Text(
                                "${withTC.length}명",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            " 입니다.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 90, bottom: 8),
                        child: Text("이용자 현황", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
                        ),
                      ),
                      Container(
                        width: 170,
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black87, // 테두리 색상
                            width: 1, // 테두리 두께
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [

                            Text(
                              "활성화 중",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Text(
                                "${activeUsers} 명",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 170,
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black87, // 테두리 색상
                            width: 1, // 테두리 두께
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "비활성화 중",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Text(
                                "${inactiveUsers} 명",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "             * ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())} 기준",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,

                        ),
                        textAlign: TextAlign.end,
                      ),

                    ],
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 1,
                    height: 166,
                    color: Colors.amber[900], // 중앙 선 추가
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.blue[300],
                              value: activePercentage.isNaN ? 0 : activePercentage,
                              title: '${activePercentage.toStringAsFixed(1)}%',
                              radius: 38,
                              titleStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.red[300],
                              value: inactivePercentage.isNaN ? 0 : inactivePercentage,
                              title: '${inactivePercentage.toStringAsFixed(1)}%',
                              radius: 38,
                              titleStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    itemCount: paginatedData.length,
                    itemBuilder: (context, index) {
                      if (index >= paginatedData.length) {
                        // 인덱스 범위 초과를 방지
                        return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (context, _, __) => UserDetail(
                                  withTC: paginatedData[index],
                                  index: index + (currentPage * itemsPerPage),
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'userCard${index + (currentPage * itemsPerPage)}',
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                                side: const BorderSide(
                                    color: Colors.black87, width: 1),
                              ),
                              elevation: 5,
                              color: Colors.white,
                              child: _buildCardContent(paginatedData[index]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            buildPagination(),
          ],
        ),
      ),
    );
  }
}

class UserDetail extends StatefulWidget {
  final List<dynamic> withTC;
  final int index;

  const UserDetail({
    required this.withTC,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  _UserDetailState createState() => _UserDetailState();
}

class _UserDetailState extends StateMVC<UserDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 500,
            child: Hero(
              tag: 'userCard${widget.index}',
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: _buildCardContent(widget.withTC),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(List<dynamic> withTCData) {
    String start = withTCData[1];
    String end = withTCData[2];
    String statusText;
    Color statusColor;

    if (start == "-" || (end != "-" && DateTime.parse(start).isAfter(DateTime.now()))) {
      statusText = "비활성화 중";
      statusColor = Colors.red.shade100;
    } else {
      statusText = "활성화 중";
      statusColor = Colors.blue.shade100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            "${withTCData[0][0]}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: const TextStyle(color: Colors.black, fontSize: 13),
            ),
          ),
        ),
        const Divider(color: Colors.black87, thickness: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "차단 시작: $start",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              Text(
                "차단 종료: $end",
                style:  TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              Text(
                "유해 url 접속 횟수: ${withTCData[3]}",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
