import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://kupan-api.onrender.com/api/";

  Future<http.Response> loginUser(String mobileNumber, String userType) async {
    final url = Uri.parse("${baseUrl}auth/login");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "mobileNumber": mobileNumber,
      "userType": userType,
    });

    return await http.post(url, headers: headers, body: body);
  }
}
