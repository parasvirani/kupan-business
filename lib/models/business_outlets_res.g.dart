// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_outlets_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessOutletsRes _$BusinessOutletsResFromJson(Map<String, dynamic> json) =>
    BusinessOutletsRes(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OutletData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BusinessOutletsResToJson(BusinessOutletsRes instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'statusCode': instance.statusCode,
      'data': instance.data,
    };

OutletData _$OutletDataFromJson(Map<String, dynamic> json) => OutletData(
      email: json['email'] as String?,
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      outletName: json['outletName'] as String?,
      outletDay: (json['outletDay'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      outletTime: json['outletTime'] as String?,
      outletImages: (json['outletImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      outletNumber: json['outletNumber'] as String?,
      location: json['location'] == null
          ? null
          : OutletLocation.fromJson(json['location'] as Map<String, dynamic>),
      id: json['_id'] as String?,
    );

Map<String, dynamic> _$OutletDataToJson(OutletData instance) =>
    <String, dynamic>{
      'email': instance.email,
      'businessName': instance.businessName,
      'businessType': instance.businessType,
      'outletName': instance.outletName,
      'outletDay': instance.outletDay,
      'outletTime': instance.outletTime,
      'outletImages': instance.outletImages,
      'outletNumber': instance.outletNumber,
      'location': instance.location,
      '_id': instance.id,
    };

OutletLocation _$OutletLocationFromJson(Map<String, dynamic> json) =>
    OutletLocation(
      lat: (json['lat'] as num?)?.toDouble(),
      long: (json['long'] as num?)?.toDouble(),
      city: json['city'] as String?,
      pincode: json['pincode'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$OutletLocationToJson(OutletLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'long': instance.long,
      'city': instance.city,
      'pincode': instance.pincode,
      'state': instance.state,
      'address': instance.address,
    };
