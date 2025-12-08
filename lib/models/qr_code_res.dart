class QRCodeRes {
  final bool? success;
  final String? message;
  final int? statusCode;
  final QRCodeData? data;

  QRCodeRes({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory QRCodeRes.fromJson(Map<String, dynamic> json) {
    return QRCodeRes(
      success: json['success'],
      message: json['message'],
      statusCode: json['statusCode'],
      data: json['data'] != null ? QRCodeData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'data': data?.toJson(),
    };
  }
}

class QRCodeData {
  final String? qrUrl;

  QRCodeData({
    this.qrUrl,
  });

  factory QRCodeData.fromJson(Map<String, dynamic> json) {
    return QRCodeData(
      qrUrl: json['qrUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qrUrl': qrUrl,
    };
  }
}
