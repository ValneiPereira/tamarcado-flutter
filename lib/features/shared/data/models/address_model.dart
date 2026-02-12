class AddressModel {
  final String cep;
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.cep,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      cep: json['cep'] as String? ?? '',
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      latitude: (json['latitude'] ?? json['lat']) as double?,
      longitude: (json['longitude'] ?? json['lng']) as double?,
    );
  }

  Map<String, dynamic> toJson() => {
        'cep': cep,
        'street': street,
        'number': number,
        'complement': complement,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
      };

  AddressModel copyWith({
    String? cep,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      cep: cep ?? this.cep,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
