// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redemptions_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedemptionsResponse _$RedemptionsResponseFromJson(Map<String, dynamic> json) =>
    RedemptionsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      statusCode: (json['statusCode'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => RedemptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RedemptionsResponseToJson(
        RedemptionsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'statusCode': instance.statusCode,
      'data': instance.data,
    };

RedemptionData _$RedemptionDataFromJson(Map<String, dynamic> json) =>
    RedemptionData(
      totalRedemptions: (json['totalRedemptions'] as num).toInt(),
      latestRedemptionAt: json['latestRedemptionAt'] as String,
      kupanId: json['kupanId'] as String,
      title: json['title'] as String,
      kupanImages: (json['kupanImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      kupanDays:
          (json['kupanDays'] as List<dynamic>).map((e) => e as String).toList(),
      buyers: (json['buyers'] as List<dynamic>)
          .map((e) => Buyer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RedemptionDataToJson(RedemptionData instance) =>
    <String, dynamic>{
      'totalRedemptions': instance.totalRedemptions,
      'latestRedemptionAt': instance.latestRedemptionAt,
      'kupanId': instance.kupanId,
      'title': instance.title,
      'kupanImages': instance.kupanImages,
      'kupanDays': instance.kupanDays,
      'buyers': instance.buyers,
    };

Buyer _$BuyerFromJson(Map<String, dynamic> json) => Buyer(
      id: json['id'] as String?,
      buyerId: json['_id'] as String,
      contact: json['contact'] as String?,
      role: json['role'] as String?,
      profilePic: json['profilePic'] as String?,
      buyerInfo: json['buyerInfo'] == null
          ? null
          : BuyerInfo.fromJson(json['buyerInfo'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['v'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$BuyerToJson(Buyer instance) => <String, dynamic>{
      'id': instance.id,
      '_id': instance.buyerId,
      'contact': instance.contact,
      'role': instance.role,
      'profilePic': instance.profilePic,
      'buyerInfo': instance.buyerInfo,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'v': instance.v,
      'name': instance.name,
    };

BuyerInfo _$BuyerInfoFromJson(Map<String, dynamic> json) => BuyerInfo(
      birthdate: json['birthdate'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      id: json['_id'] as String,
    );

Map<String, dynamic> _$BuyerInfoToJson(BuyerInfo instance) => <String, dynamic>{
      'birthdate': instance.birthdate,
      'location': instance.location,
      '_id': instance.id,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(),
      city: json['city'] as String,
      pincode: json['pincode'] as String,
      state: json['state'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'lat': instance.lat,
      'long': instance.long,
      'city': instance.city,
      'pincode': instance.pincode,
      'state': instance.state,
      'address': instance.address,
    };
