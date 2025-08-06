class UserLoginResponse {
  final String message;
  final String otp;

  UserLoginResponse({required this.message, required this.otp});

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) {
    return UserLoginResponse(
      message: json['message'] ?? '',
      otp: json['otp'] ?? '',
    );
  }
}