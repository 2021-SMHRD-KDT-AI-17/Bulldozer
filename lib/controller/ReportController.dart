import 'package:mvc_pattern/mvc_pattern.dart';
import '../../model/ReportModel.dart';
import 'package:bulldozer/db.dart';

class reportController extends ControllerMVC {
  factory reportController([StateMVC? state]) =>
      _this ??= reportController._(state);

  reportController._(StateMVC? state)
      : _tb_report = tb_report(),
        super(state);

  final tb_report _tb_report;
  static reportController? _this;

  int? get getIdx => _tb_report.report_idx;
  String? get getEmail => _tb_report.u_email;
  String? get getAddress => _tb_report.report_address;
  String? get getDescript => _tb_report.report_descript;
  int? get getAnalysis => _tb_report.report_analysis;
  String? get getTitle => _tb_report.report_title;
  String? get getAt => _tb_report.report_at;

  final List<tb_report> reports = [];

  Future<void> loadData() async {
    await DBConn('select * from tb_report');
    reports.clear();

    for (int i = 0; i < res.length; i++) {
      if (res[i].isNotEmpty) {
        tb_report report = tb_report();
        try {
          report.setIdx = int.tryParse(res[i][0]) ?? 0;
          report.setEmail = res[i][1] as String?;
          report.setAddress = res[i][2] as String?;
          report.setDescript = res[i][3] as String?;
          report.setAnalysis = int.tryParse(res[i][4]) ?? 0;
          report.setTitle = res[i][5] as String?;
          report.setAt = res[i][6] as String?;
          reports.add(report);
        } catch (e) {
          print("Error parsing report data: $e");
        }
      }
    }
  }

  Future<List<List<dynamic>>> getRecent() async {
    await DBConn('select report_idx, u_email, report_address, report_descript, report_analysis, report_title, report_at from tb_report order by report_at limit 4;');
    return List<List<dynamic>>.from(res);
  }

  Future<void> insertReport(String email, String address, String descript) async {
    await DBConn("INSERT INTO tb_report (u_email, report_address, report_descript) VALUES ('${email}', '${address}', '${descript}');");
  }

  Future<void> deleteReport(String email, int index) async {
    await DBConn('delete from tb_report where u_email="${email}" and report_idx="${index}";');
  }
}
