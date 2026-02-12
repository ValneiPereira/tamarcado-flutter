class ServiceModel {
  final String id;
  final String name;
  final double price;
  final bool active;
  final String? createdAt;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    this.active = true,
    this.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'active': active,
        'createdAt': createdAt,
      };
}
