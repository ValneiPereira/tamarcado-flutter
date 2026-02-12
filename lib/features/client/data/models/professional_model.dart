import '../../../shared/data/models/address_model.dart';
import 'service_model.dart';
import 'review_model.dart';

class ProfessionalModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photo;
  final String category;
  final String serviceType;
  final double averageRating;
  final int totalRatings;
  final AddressModel? address;
  final double? distanceKm;
  final List<ServiceModel> services;
  final List<ReviewModel> reviews;

  const ProfessionalModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photo,
    required this.category,
    required this.serviceType,
    this.averageRating = 0,
    this.totalRatings = 0,
    this.address,
    this.distanceKm,
    this.services = const [],
    this.reviews = const [],
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      photo: json['photo'] as String?,
      category: json['category'] as String,
      serviceType: json['serviceType'] as String,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'photo': photo,
        'category': category,
        'serviceType': serviceType,
        'averageRating': averageRating,
        'totalRatings': totalRatings,
        'address': address?.toJson(),
        'distanceKm': distanceKm,
        'services': services.map((e) => e.toJson()).toList(),
      };
}
