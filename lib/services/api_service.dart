import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../const/string_const.dart';

class ApiService {
  static const String baseUrl = "https://kupan-backend-production-0a1c.up.railway.app/api/v1";
  final box = GetStorage();

  Future<http.Response> loginUser(String mobileNumber) async {
    final url = Uri.parse("${baseUrl}/auth/send-otp");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "contact": "+91$mobileNumber",
    });

    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> verifyOtp(String mobileNumber, String otp, String role) async {
    final url = Uri.parse("${baseUrl}/auth/verify-otp");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "contact": "+91$mobileNumber",
      "otp": otp,
      "role": role
    });

    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> updateUser(Map<String, dynamic> map) async {


    String userId = box.read(StringConst.USER_ID);
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/users/$userId");
    final headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};
    final body = jsonEncode(map);

    return await http.put(url, headers: headers, body: body);
  }
}
