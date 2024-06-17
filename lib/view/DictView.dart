import 'dart:async';

import 'package:bulldozer/view/UrlListView.dart';
import 'package:flutter/material.dart';
import '../../db.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controller/DictController.dart';
import '../../view/AdminView.dart';
import '../../view/UserListView.dart';
import 'package:flutter/painting.dart' as flutterPainting;
import 'package:lottie/lottie.dart';
import '../../view/ReportCheckView.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends StateMVC<DictionaryPage> with SingleTickerProviderStateMixin {
  late dictController DictController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLoading = true;

  TextEditingController insertWCon = TextEditingController();
  TextEditingController insertNCon = TextEditingController();

  @override
  void dispose() {
    insertWCon.dispose();
    insertNCon.dispose();
    _animationController.dispose();
    super.dispose();
  }

  _DictionaryPageState() : super(dictController()) {
    DictController = controller as dictController;
  }

  String selectedCategory = 'All';
  String selectedLevel = 'All';
  int currentPage = 0;
  final int itemsPerPage = 12;

  List<List<dynamic>>? get filteredWords {
    List<List<dynamic>>? words;
    if (selectedCategory == 'All') {
      words = res;
    } else if (selectedCategory == 'A') {
      words = res
          .where((word) =>
          RegExp(r'^[a-zA-Z]').hasMatch(word[1]!)) // 첫문자가 알파벳인지 확인
          .toList();
    } else {
      words = res.where((word) {
        String firstChar = word[1]!.substring(0, 1);
        return _matchKoreanConsonant(firstChar, selectedCategory);
      }).toList();
    }

    if (selectedLevel != 'All') {
      words = words?.where((word) => word[3] == selectedLevel).toList();
    }

    return words;
  }

  bool _matchKoreanConsonant(String firstChar, String selectedCategory) {
    Map<String, List<String>> consonantRanges = {
      'ㄱ': ['가', '나'],
      'ㄴ': ['나', '다'],
      'ㄷ': ['다', '라'],
      'ㄹ': ['라', '마'],
      'ㅁ': ['마', '바'],
      'ㅂ': ['바', '사'],
      'ㅅ': ['사', '아'],
      'ㅇ': ['아', '자'],
      'ㅈ': ['자', '차'],
      'ㅊ': ['차', '카'],
      'ㅋ': ['카', '타'],
      'ㅌ': ['타', '파'],
      'ㅍ': ['파', '하'],
      'ㅎ': ['하', '힣'],
    };

    List<String>? range = consonantRanges[selectedCategory];
    if (range != null) {
      return firstChar.compareTo(range[0]) >= 0 &&
          firstChar.compareTo(range[1]) < 0;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    await DictController.loadData();
    setState(() {
      isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _selectWord(String category) async {
    setState(() {
      isLoading = true;
    });
    await DictController.selectWord(category);
    setState(() {
      isLoading = false;
    });
    _animationController.forward(from: 0.0);
  }

  void _onCategorySelected(String category) async {
    setState(() {
      selectedCategory = category;
      currentPage = 0;
    });
    print(selectedCategory);
    if (category == 'All') {
      await _loadData();
    } else {
      await _selectWord(category);
    }
  }

  void _onLevelSelected(String level) {
    setState(() {
      selectedLevel = level;
    });
  }

  Future<void> _insertword(String word, String type) async {
    await DictController.insertWord(word, type);
  }

  Future<dynamic> insertWordPop(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.amber,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 10, 15),
              child: Text(
                '단어 추가',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    controller: insertWCon,
                    decoration: InputDecoration(
                      labelText: '단어명',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    controller: insertNCon,
                    decoration: InputDecoration(
                      labelText: '가중치',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                insertWCon.clear();
                insertNCon.clear();
              },
              child: Text(
                "초기화",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 17,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _insertword(insertWCon.text, insertNCon.text);
                Navigator.pop(context);
                insertWCon.text = '';
                insertNCon.text = '';
                setState(() {});
              },
              child: Text(
                '추가',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String searchWord = '';

  @override
  Widget build(BuildContext context) {
    final List<String> koreanConsonants = [
      'ㄱ',
      'ㄴ',
      'ㄷ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅅ',
      'ㅇ',
      'ㅈ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ'
    ];

    final totalPages = (filteredWords!.length / itemsPerPage).ceil();
    final displayWords = filteredWords!.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Padding(
          padding: const EdgeInsets.only(left: 68),
          child: Text('단어사전 열람', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: flutterPainting.LinearGradient(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Admin님 \n환영합니다.",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15),
                  VerticalDivider(
                    thickness: 2,
                    color: Colors.amber[800],
                    indent: 10,
                    endIndent: 10,
                  ),
                  SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, top: 14),
                    child: Image.asset('images/free-icon-admin-1085798.png',
                        width: 80, height: 80),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ReportCheckPage()));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => UserList()));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => HarmSiteList()));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DictionaryPage()));
                },
              ),
            ),
            SizedBox(height: 60),
            Divider(
              thickness: 2,
              color: Colors.amber[800],
              indent: 30,
              endIndent: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 150, top: 70),
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
                  // Exit 처리
                },
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
        child: Lottie.asset("assets/lottiefiles/loading_orange.json"),
      )
          : FadeTransition(
        opacity: _animation,
        child: Row(
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildCategoryButton('All'),
                  ...koreanConsonants
                      .map((consonant) => _buildCategoryButton(consonant))
                      .toList(),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 13, 12, 5),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.amber[900]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide( style: BorderStyle.solid, color: Colors.black, width: 3)
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '검색어를 입력하세요',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchWord = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 9, 6),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        insertWordPop(context);
                      },
                      icon: Icon(Icons.add, color: Colors.red),
                      label: Text(
                        "단어 추가",
                        style: TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.black87, width: 2),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 10),
                        child: Text(
                          "검색 결과",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 80),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "정렬 : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 12),
                        child: DropdownButton<String>(
                          value: selectedLevel,
                          onChanged: (String? newValue) {
                            _onLevelSelected(newValue!);
                          },
                          items: <String>['All', '상', '중', '하']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.black87,
                    indent: 20,
                    endIndent: 20,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 90),
                        child: Text(
                          "단어명",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 82),
                        child: Text(
                          "가중치",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 8.0,
                      radius: Radius.circular(16),
                      child: ListView.builder(
                        itemCount: displayWords.length,
                        itemBuilder: (context, index) {
                          if (searchWord.isNotEmpty &&
                              !displayWords[index][1].contains(searchWord)) {
                            return SizedBox.shrink();
                          }
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 19),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: Colors.black87, width: 1),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.amber[900],
                                child: Icon(Icons.book, color: Colors.white),
                              ),
                              title: Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: Text(
                                  '${displayWords[index][1]}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _getWeightColor(displayWords[index][3]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${displayWords[index][3]}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    final isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () => _onCategorySelected(category),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.amber : Colors.white,
          foregroundColor: isSelected ? Colors.black : Colors.black,
          side: BorderSide(
              color:
              isSelected ? Colors.black : Colors.transparent, width: 3.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Color _getWeightColor(String weight) {
    switch (weight) {
      case '상':
        return Colors.red;
      case '중':
        return Colors.orange;
      case '하':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}