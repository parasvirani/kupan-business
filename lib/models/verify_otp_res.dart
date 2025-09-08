
import 'package:json_annotation/json_annotation.dart';
part 'verify_otp_res.g.dart';

@JsonSerializable()
class VerifyOtpRes {
  bool? success;
  String? message;
  int? statusCode;
  UserData? data;

  VerifyOtpRes({this.success, this.message, this.statusCode, this.data});

  factory VerifyOtpRes.fromJson(Map<String, dynamic> json) => _$VerifyOtpResFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpResToJson(this);
}

@JsonSerializable()
class UserData {
  User? user;
  String? token;


  UserData({this.user, this.token});

  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable()
class User {
  SellerInfo? sellerInfo;
  @JsonKey(name: "_id")
  String? id;
  String? name;
  String? contact;
  String? role;
  String? profilePic;
  String? createdAt;
  String? updatedAt;


  User(
      {this.sellerInfo,
      this.id,
      this.name,
      this.contact,
      this.role,
      this.profilePic,
      this.createdAt,
      this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class SellerInfo {
  String? businessName;
  List<String>? outletImages;
  Location? location;


  SellerInfo({this.businessName, this.outletImages, this.location});

  factory SellerInfo.fromJson(Map<String, dynamic> json) => _$SellerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SellerInfoToJson(this);
}

@JsonSerializable()
class Location {
  String? city;


  Location({this.city});

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}