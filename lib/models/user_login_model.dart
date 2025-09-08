class UserLoginResponse {
  final String message;
  final bool success;

  UserLoginResponse({required this.message, required this.success});

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) {
    return UserLoginResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? '',
    );
  }
}