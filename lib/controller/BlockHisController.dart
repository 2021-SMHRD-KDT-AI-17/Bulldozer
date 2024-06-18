import 'package:mvc_pattern/mvc_pattern.dart';
import '../../model/BlockHisModel.dart';
import '../../db.dart';

class blockHisController extends ControllerMVC {

  factory blockHisController([StateMVC? state]) =>
      _this ?? blockHisController._(state);

  blockHisController._(StateMVC? state)
      : _tb_block_his = tb_block_his(),
        super(state);

  final tb_block_his _tb_block_his;
  static blockHisController? _this;

  int? get getIdx => _tb_block_his.block_idx;
  String? get getEmail => _tb_block_his.u_email;
  String? get getAddress => _tb_block_his.block_address;
  String? get getAt => _tb_block_his.block_at;

  final List<tb_block_his> blocks = [];

  Future<void> loadData() async{
    await DBConn('select * from tb_block_his');
    blocks.clear();

    // tb_block_his 객체 리스트로 변환
    for (int i=0; i<res.length; i++) {
      if (res[i].isNotEmpty) {
        tb_block_his block = tb_block_his();
        block.setIdx = int.parse(res[i][0]) as int?;
        block.setEmail = res[i][1] as String?;
        block.setAddress = res[i][2] as String?;
        block.setAt = res[i][3] as String?;
        blocks.add(block);
      }
    }
  }

  // tb_block_his 객체를 가져오는 getter
  tb_block_his? getBlock(int index) {
    if (index >= 0 && index < blocks.length) {
      return blocks[index];
    }
  }

  // 차단횟수 확인
  Future<void> insertBlock(String email, String address) async{
    await DBConn('insert into tb_block_his(u_email, block_address) values("${email}", "${address}");');
  }
  // 차단횟수 확인
  Future<void> getBlockAt(String email, String address) async{
    await DBConn('SELECT u_email, block_address, block_at FROM tb_block_his '
        'WHERE u_email = "${email}" AND block_address LIKE "%${address}%" order by block_at DESC;');
  }

  // 접속횟수 확인
  Future<void> getBlockCnt() async{
    await DBConn('SELECT u.u_email, COUNT(b.u_email) AS frequency FROM tb_user u LEFT JOIN tb_block_his b ON u.u_email = b.u_email GROUP BY u.u_email'
        ' UNION SELECT b.u_email, COUNT(b.u_email) AS frequency FROM tb_block_his b LEFT JOIN tb_user u ON u.u_email = b.u_email WHERE u.u_email IS NULL GROUP BY b.u_email;');
  }


  // 차단 건수 확인 ---------------------------------------------------------------------
  Future<int> getToday() async {
    await DBConn(
        'SELECT COUNT(*) AS count_today FROM tb_block_his WHERE DATE(block_at) = CURDATE();');
    if (res.isNotEmpty) {
      return int.parse(res.first[0]);
    } else {
      return 0;
    }
  }

  Future<int> getTotal() async {
    await DBConn(
        'SELECT COUNT(*) FROM tb_block_his;');
    if (res.isNotEmpty) {
      return int.parse(res.first[0]);
    } else {
      return 0;
    }
  }

  Future<int> getTotalSite() async {
    await DBConn(
        'SELECT COUNT(DISTINCT block_address) FROM tb_block_his;');
    if (res.isNotEmpty) {
      return int.parse(res.first[0]);
    } else {
      return 0;
    }
  }
  // -------------------------------------------------------------------

  // 최근 1주일 검출 현황
  Future<List<int>> getWeek() async {
    await DBConn('''
      SELECT 
        DATE_SUB(CURDATE(), INTERVAL seq DAY) AS date,
          COUNT(tb.block_at) AS count_per_day
        FROM 
            (SELECT 0 AS seq UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) AS seq
        LEFT JOIN 
            tb_block_his tb ON DATE(tb.block_at) = DATE_SUB(CURDATE(), INTERVAL seq DAY)
        GROUP BY 
            seq
        ORDER BY 
            seq DESC;
  ''');

    List<int> weekCounts = List.filled(7, 0); // 일주일 동안의 날짜별 차단 건수를 저장할 리스트 초기화

    if (res.isNotEmpty) {
      for (int i = 0; i < res.length; i++) {
        int count = int.parse(res[i][1]);
        weekCounts[i] = count;
      }
    }
    return weekCounts;
  }

  // 최근 6개월 검출 현황
  Future<List<int>> getSixMonths() async {
    await DBConn('''
        SELECT 
        DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL seq MONTH), '%Y-%m') AS month,
        COALESCE(COUNT(tb.block_at), 0) AS count_per_month
        FROM (
        SELECT 0 AS seq UNION ALL 
        SELECT 1 UNION ALL 
        SELECT 2 UNION ALL 
        SELECT 3 UNION ALL 
        SELECT 4 UNION ALL 
        SELECT 5
        ) AS seq
        LEFT JOIN tb_block_his tb 
        ON DATE_FORMAT(tb.block_at, '%Y-%m') = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL seq MONTH), '%Y-%m')
        GROUP BY month
        ORDER BY month;
  ''');
    List<int> monthCounts = List.filled(6, 0); // 6개월 동안의 월별 차단 건수를 저장할 리스트 초기화

    if (res.isNotEmpty) {
      for (int i = 0; i < res.length; i++) {
        int count = int.parse(res[i][1]);
        monthCounts[i] = count; // 최신 월이 마지막 인덱스에 오도록 설정
      }
    }
    return monthCounts;
  }

  // 최근 1년 검출 현황
  Future<List<int>> getYear() async {
    await DBConn('''
            SELECT 
            DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL seq MONTH), '%Y-%m') AS month,
            COALESCE(COUNT(tb.block_at), 0) AS count_per_month
        FROM (
            SELECT 0 AS seq UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
            UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 
            UNION ALL SELECT 10 UNION ALL SELECT 11
        ) AS seq
        LEFT JOIN tb_block_his tb 
        ON DATE_FORMAT(tb.block_at, '%Y-%m') = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL seq MONTH), '%Y-%m')
        GROUP BY month
        ORDER BY month;
  ''');

    List<int> yearCounts = List.filled(12, 0); // 1년 동안의 월별 차단 건수를 저장할 리스트 초기화

    if (res.isNotEmpty) {
      for (int i = 0; i < res.length; i++) {
        int count = int.parse(res[i][1]);
        yearCounts[i] = count; // 최신 월이 마지막 인덱스에 오도록 설정
      }
    }
    return yearCounts;
  }



}