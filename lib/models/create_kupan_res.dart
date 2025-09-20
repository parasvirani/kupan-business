
class CreateKupanRes {
  final bool? success;
  final String? message;
  final int? statusCode;
  final KupanData? data;

  CreateKupanRes({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory CreateKupanRes.fromJson(Map<String, dynamic> json) {
    return CreateKupanRes(
      success: json['success'],
      message: json['message'],
      statusCode: json['statusCode'],
      data: json['data'] != null ? KupanData.fromJson(json['data']) : null,
    );
  }
}

class KupanData {
  final String? title;
  final List<String>? kupanImages;
  final List<String>? kupanDays;
  final String? vendorId;
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  KupanData({
    this.title,
    this.kupanImages,
    this.kupanDays,
    this.vendorId,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory KupanData.fromJson(Map<String, dynamic> json) {
    return KupanData(
      title: json['title'],
      kupanImages: json['kupanImages'] != null
          ? List<String>.from(json['kupanImages'])
          : [],
      kupanDays: json['kupanDays'] != null
          ? List<String>.from(json['kupanDays'])
          : [],
      vendorId: json['vendorId'],
      id: json['_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}