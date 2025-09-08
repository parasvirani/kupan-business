import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://kupan-backend-production-0a1c.up.railway.app/api/v1";

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
}
