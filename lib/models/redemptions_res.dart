import 'package:json_annotation/json_annotation.dart';

part 'redemptions_res.g.dart';

@JsonSerializable()
class RedemptionsResponse {
  final bool success;
  final String message;
  final int statusCode;
  final List<RedemptionData> data;

  RedemptionsResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory RedemptionsResponse.fromJson(Map<String, dynamic> json) =>
      _$RedemptionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RedemptionsResponseToJson(this);
}

@JsonSerializable()
class RedemptionData {
  final int totalRedemptions;
  final String? latestRedemptionAt;
  final String kupanId;
  final String title;
  final List<String> kupanImages;
  final List<String> kupanDays;
  final List<Buyer> buyers;

  RedemptionData({
    required this.totalRedemptions,
    this.latestRedemptionAt,
    required this.kupanId,
    required this.title,
    required this.kupanImages,
    required this.kupanDays,
    required this.buyers,
  });

  factory RedemptionData.fromJson(Map<String, dynamic> json) =>
      _$RedemptionDataFromJson(json);

  Map<String, dynamic> toJson() => _$RedemptionDataToJson(this);
}

@JsonSerializable()
class Buyer {
  final String? id;
  @JsonKey(name: '_id')
  final String? buyerId;
  final String? contact;
  final String? role;
  final String? profilePic;
  final BuyerInfo? buyerInfo;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final String? name;

  Buyer({
    this.id,
    this.buyerId,
    this.contact,
    this.role,
    this.profilePic,
    this.buyerInfo,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.name,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) => _$BuyerFromJson(json);

  Map<String, dynamic> toJson() => _$BuyerToJson(this);
}

@JsonSerializable()
class BuyerInfo {
  final String? birthdate;
  final Location? location;
  @JsonKey(name: '_id')
  final String? id;

  BuyerInfo({
    this.birthdate,
    this.location,
    this.id,
  });

  factory BuyerInfo.fromJson(Map<String, dynamic> json) =>
      _$BuyerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BuyerInfoToJson(this);
}

@JsonSerializable()
class Location {
  final double? lat;
  final double? long;
  final String? city;
  final String? pincode;
  final String? state;
  final String? address;

  Location({
    this.lat,
    this.long,
    this.city,
    this.pincode,
    this.state,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
