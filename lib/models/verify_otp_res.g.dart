// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyOtpRes _$VerifyOtpResFromJson(Map<String, dynamic> json) => VerifyOtpRes(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : UserData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerifyOtpResToJson(VerifyOtpRes instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'statusCode': instance.statusCode,
      'data': instance.data,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String?,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      sellerInfo: json['sellerInfo'] == null
          ? null
          : SellerInfo.fromJson(json['sellerInfo'] as Map<String, dynamic>),
      id: json['_id'] as String?,
      name: json['name'] as String?,
      contact: json['contact'] as String?,
      role: json['role'] as String?,
      profilePic: json['profilePic'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'sellerInfo': instance.sellerInfo,
      '_id': instance.id,
      'name': instance.name,
      'contact': instance.contact,
      'role': instance.role,
      'profilePic': instance.profilePic,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

SellerInfo _$SellerInfoFromJson(Map<String, dynamic> json) => SellerInfo(
      businessName: json['businessName'] as String?,
      outletImages: (json['outletImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SellerInfoToJson(SellerInfo instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'outletImages': instance.outletImages,
      'location': instance.location,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      city: json['city'] as String?,
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'city': instance.city,
    };
