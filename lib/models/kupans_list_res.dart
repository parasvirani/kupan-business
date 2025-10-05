class KupansListRes {
  final bool? success;
  final String? message;
  final int? statusCode;
  List<KupanData>? data;

  KupansListRes({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory KupansListRes.fromJson(Map<String, dynamic> json) {
    return KupansListRes(
      success: json['success'],
      message: json['message'],
      statusCode: json['statusCode'],
      data: json['data'] != null
          ? List<KupanData>.from(
          json['data'].map((x) => KupanData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'data': data != null ? data!.map((x) => x.toJson()).toList() : [],
    };
  }
}

class KupanData {
  final String? id;
  final String? title;
  final List<String>? kupanImages;
  final List<String>? kupanDays;
  final String? vendorId;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  KupanData({
    this.id,
    this.title,
    this.kupanImages,
    this.kupanDays,
    this.vendorId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory KupanData.fromJson(Map<String, dynamic> json) {
    return KupanData(
      id: json['_id'],
      title: json['title'],
      kupanImages: json['kupanImages'] != null
          ? List<String>.from(json['kupanImages'])
          : [],
      kupanDays: json['kupanDays'] != null
          ? List<String>.from(json['kupanDays'])
          : [],
      vendorId: json['vendorId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'kupanImages': kupanImages,
      'kupanDays': kupanDays,
      'vendorId': vendorId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
