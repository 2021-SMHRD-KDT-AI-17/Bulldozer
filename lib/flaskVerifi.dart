import 'package:http/http.dart' as http;
import 'dart:convert';

class verifi{
  void test2() async{
    {
      print("Click");
// API 요청
      try {
        final response = await http.get(Uri.parse('https://869b-180-83-53-119.ngrok-free.app/val/'));
        if (response.statusCode == 200) {
          print("!");
          print(jsonDecode(response.body));
        } else {
          print("Failed to load data. Status code: ${response.statusCode}");
        }
      } catch (e) {
        print("Error: $e");
      }
      print("!");
    }
  }

}