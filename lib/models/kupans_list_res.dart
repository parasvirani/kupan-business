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

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;

      // New flat vendor list format: data is a list directly in data
      if (dataMap['kupans'] != null && dataMap['kupans'] is List) {
        kupanList = List<KupanData>.from(
          (dataMap['kupans'] as List).map((x) => KupanData.fromJson(x)),
        );
      }
      // Prioritized format: data.upPriority.kupans + data.downPriority.kupans
      else if (dataMap['upPriority'] != null || dataMap['downPriority'] != null) {
        final upKupans = (dataMap['upPriority']?['kupans'] as List?) ?? [];
        final downKupans = (dataMap['downPriority']?['kupans'] as List?) ?? [];
        kupanList = [...upKupans, ...downKupans]
            .map((x) => KupanData.fromJson(x as Map<String, dynamic>))
            .toList();
      }
    }
    // Flat list format: data is a List directly
    else if (json['data'] != null && json['data'] is List) {
      kupanList = List<KupanData>.from(
        (json['data'] as List).map((x) => KupanData.fromJson(x)),
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
  final String? description;
  final String? kupanType;
  final List<String>? kupanImages;
  final List<String>? kupanDays;
  final dynamic vendorId; // Can be String or Object (populated)
  final String? businessId;
  final String? outletName;
  final String? outletAddress;
  final String? businessType;
  final List<dynamic>? sellerBusinesses;
  final int? dailyLimit;
  final bool? isVerified;
  final bool? isPaused;
  final bool? isCancelled;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  KupanData({
    this.id,
    this.title,
    this.description,
    this.kupanType,
    this.kupanImages,
    this.kupanDays,
    this.vendorId,
    this.businessId,
    this.outletName,
    this.outletAddress,
    this.businessType,
    this.sellerBusinesses,
    this.dailyLimit,
    this.isVerified,
    this.isPaused,
    this.isCancelled,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory KupanData.fromJson(Map<String, dynamic> json) {
    return KupanData(
      // Support both '_id' (raw model) and 'kupanId' (service-mapped)
      id: json['_id']?.toString() ?? json['kupanId']?.toString(),
      title: json['title'],
      description: json['description'],
      kupanType: json['kupanType'],
      kupanImages: json['kupanImages'] != null
          ? List<String>.from(json['kupanImages'])
          : [],
      kupanDays: json['kupanDays'] != null
          ? List<String>.from(json['kupanDays'])
          : [],
      vendorId: json['vendorId'],
      // Support both 'businessId' and 'outletId' (service-mapped)
      businessId:
          json['businessId']?.toString() ?? json['outletId']?.toString(),
      outletName: json['outletName'],
      outletAddress: json['outletAddress'],
      businessType: json['businessType'],
      sellerBusinesses: json['sellerBusinesses'],
      dailyLimit: json['dailyLimit'] as int?,
      isVerified: json['isVerified'] as bool?,
      isPaused: json['isPaused'] as bool?,
      isCancelled: json['isCancelled'] as bool?,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'kupanType': kupanType,
      'kupanImages': kupanImages,
      'kupanDays': kupanDays,
      'vendorId': vendorId,
      'businessId': businessId,
      'outletName': outletName,
      'outletAddress': outletAddress,
      'businessType': businessType,
      'sellerBusinesses': sellerBusinesses,
      'dailyLimit': dailyLimit,
      'isVerified': isVerified,
      'isPaused': isPaused,
      'isCancelled': isCancelled,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }

  /// Get outlet name from vendorId's sellerBusinesses by matching businessId
  String? getOutletName() {
    if (outletName != null && outletName!.isNotEmpty) return outletName;

    if (vendorId is Map<String, dynamic>) {
      final vendorMap = vendorId as Map<String, dynamic>;
      final sellerBusinessesList = vendorMap['sellerBusinesses'] as List?;

      if (sellerBusinessesList != null && businessId != null) {
        try {
          final matchingBusiness = sellerBusinessesList.firstWhere(
            (business) =>
                business is Map<String, dynamic> &&
                business['_id'].toString() == businessId,
            orElse: () => null,
          );

          if (matchingBusiness is Map<String, dynamic>) {
            return matchingBusiness['outletName'] as String?;
          }
        } catch (_) {}
      }
    }
    return null;
  }

  /// Get business type from vendorId's sellerBusinesses or direct field
  String? getBusinessType() {
    if (businessType != null && businessType!.isNotEmpty) return businessType;

    if (vendorId is Map<String, dynamic>) {
      final vendorMap = vendorId as Map<String, dynamic>;
      final sellerBusinessesList = vendorMap['sellerBusinesses'] as List?;

      if (sellerBusinessesList != null && businessId != null) {
        try {
          final matchingBusiness = sellerBusinessesList.firstWhere(
            (business) =>
                business is Map<String, dynamic> &&
                business['_id'].toString() == businessId,
            orElse: () => null,
          );

          if (matchingBusiness is Map<String, dynamic>) {
            return matchingBusiness['businessType'] as String?;
          }
        } catch (_) {}
      }
    }
    return null;
  }

  /// Get outlet address from vendorId's sellerBusinesses
  String? getOutletAddress() {
    if (outletAddress != null && outletAddress!.isNotEmpty) return outletAddress;

    if (vendorId is Map<String, dynamic>) {
      final vendorMap = vendorId as Map<String, dynamic>;
      final sellerBusinessesList = vendorMap['sellerBusinesses'] as List?;

      if (sellerBusinessesList != null && businessId != null) {
        try {
          final matchingBusiness = sellerBusinessesList.firstWhere(
            (business) =>
                business is Map<String, dynamic> &&
                business['_id'].toString() == businessId,
            orElse: () => null,
          );

          if (matchingBusiness is Map<String, dynamic>) {
            final loc = matchingBusiness['location'];
            if (loc is Map<String, dynamic>) {
              final parts = <String>[];
              if (loc['address'] != null && loc['address'].toString().isNotEmpty) {
                parts.add(loc['address'].toString());
              }
              if (loc['city'] != null && loc['city'].toString().isNotEmpty) {
                parts.add(loc['city'].toString());
              }
              return parts.join(', ');
            }
          }
        } catch (_) {}
      }
    }
    return null;
  }
}
