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
    List<KupanData> kupanList = [];
    
    // Handle new API response format where kupans are in data.kupans
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['kupans'] != null && dataMap['kupans'] is List) {
        kupanList = List<KupanData>.from(
          (dataMap['kupans'] as List).map((x) => KupanData.fromJson(x))
        );
      }
    } 
    // Handle old API response format where data is a list
    else if (json['data'] != null && json['data'] is List) {
      kupanList = List<KupanData>.from(
        (json['data'] as List).map((x) => KupanData.fromJson(x))
      );
    }
    
    return KupansListRes(
      success: json['success'],
      message: json['message'],
      statusCode: json['statusCode'],
      data: kupanList,
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
  final dynamic vendorId; // Can be String or Object
  final String? businessId;
  final String? outletName;
  final List<dynamic>? sellerBusinesses;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  KupanData({
    this.id,
    this.title,
    this.kupanImages,
    this.kupanDays,
    this.vendorId,
    this.businessId,
    this.outletName,
    this.sellerBusinesses,
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
      vendorId: json['vendorId'], // Keep as is (String or Object)
      businessId: json['businessId'],
      outletName: json['outletName'],
      sellerBusinesses: json['sellerBusinesses'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'kupanImages': kupanImages,
      'kupanDays': kupanDays,
      'vendorId': vendorId,
      'businessId': businessId,
      'outletName': outletName,
      'sellerBusinesses': sellerBusinesses,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }

  /// Get outlet name from vendorId's sellerBusinesses by matching businessId
  String? getOutletName() {
    // First check if outletName exists directly
    if (outletName != null && outletName!.isNotEmpty) {
      return outletName;
    }

    // If vendorId is a Map and has sellerBusinesses, find matching outlet
    if (vendorId is Map<String, dynamic>) {
      final vendorMap = vendorId as Map<String, dynamic>;
      final sellerBusinessesList = vendorMap['sellerBusinesses'] as List?;
      
      if (sellerBusinessesList != null && businessId != null) {
        try {
          final matchingBusiness = sellerBusinessesList.firstWhere(
            (business) => 
              business is Map<String, dynamic> && 
              business['_id'] == businessId,
            orElse: () => null,
          );
          
          if (matchingBusiness is Map<String, dynamic>) {
            return matchingBusiness['outletName'] as String?;
          }
        } catch (e) {
          // If no match found, return null
        }
      }
    }
    
    return null;
  }
}
