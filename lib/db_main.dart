import 'package:mysql_client/mysql_client.dart';

List<List> res = [];

Future<void> DBConn(String query) async {
  print("Connecting to mysql server...");

  // MySQL 접속 설정
  final conn = await MySQLConnection.createConnection(
    //host: 'project-db-campus.smhrd.com',
      host: 'project-db-cgi.smhrd.com',
      port: 3307,
      userName: 'bulldozer',
      password: 'gamblecut',
      databaseName: 'bulldozer'
  );

  await conn.connect();
  print("Connected");

  // 쿼리 실행 결과를 저장할 변수
  IResultSet? result;
  result = await conn.execute(query);

  // 쿼리 실행 성공
  if (result.isNotEmpty) {
    res.clear();
    for (final row in result.rows) {
      // 행의 인덱스 정보 출력
      //print(row.colAt(0).toString());

      // 컬럼의 내용 출력 : title 컬럼 조회
      //print(row.colByName("u_email"));

      // 쿼리 실행 결과의 모든 내용 출력
      //print(row.assoc());
      // print(test);
      // print(test[1]);

      res.add(row.assoc().values.toList());
    }
    print(res);
    print('success');
  }
  // 쿼리 실행 실패
  else {
    print('failed');
  }

  await conn.close();
  print('Disconnect');

}