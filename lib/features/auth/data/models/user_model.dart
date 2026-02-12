import '../../../shared/data/models/address_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photo;
  final String userType;
  final AddressModel? address;
  final String? createdAt;

  // Campos extras para profissionais
  final String? category;
  final String? serviceType;
  final double? averageRating;
  final int? totalRatings;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photo,
    required this.userType,
    this.address,
    this.createdAt,
    this.category,
    this.serviceType,
    this.averageRating,
    this.totalRatings,
  });

  bool get isClient => userType.toUpperCase() == 'CLIENT';
  bool get isProfessional => userType.toUpperCase() == 'PROFESSIONAL';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      photo: json['photo'] as String?,
      userType: json['userType'] as String,
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String?,
      category: json['category'] as String?,
      serviceType: json['serviceType'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalRatings: json['totalRatings'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'photo': photo,
        'userType': userType,
        'address': address?.toJson(),
        'createdAt': createdAt,
        'category': category,
        'serviceType': serviceType,
        'averageRating': averageRating,
        'totalRatings': totalRatings,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photo,
    String? userType,
    AddressModel? address,
    String? createdAt,
    String? category,
    String? serviceType,
    double? averageRating,
    int? totalRatings,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      userType: userType ?? this.userType,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      serviceType: serviceType ?? this.serviceType,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
    );
  }
}
