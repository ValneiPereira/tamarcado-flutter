import 'service_model.dart';

class AppointmentModel {
  final String id;
  final String? clientId;
  final String? clientName;
  final String? clientPhone;
  final String? professionalId;
  final String? professionalName;
  final String? professionalPhone;
  final ServiceModel? service;
  final String date;
  final String time;
  final String status;
  final String? notes;
  final double? distance;
  final bool reviewed;
  final String? createdAt;
  final String? updatedAt;

  const AppointmentModel({
    required this.id,
    this.clientId,
    this.clientName,
    this.clientPhone,
    this.professionalId,
    this.professionalName,
    this.professionalPhone,
    this.service,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
    this.distance,
    this.reviewed = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String?,
      clientName: json['clientName'] as String?,
      clientPhone: json['clientPhone'] as String?,
      professionalId: json['professionalId'] as String?,
      professionalName: json['professionalName'] as String?,
      professionalPhone: json['professionalPhone'] as String?,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'] as Map<String, dynamic>)
          : null,
      date: json['date'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      reviewed: json['reviewed'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'professionalId': professionalId,
        'service': service?.toJson(),
        'date': date,
        'time': time,
        'status': status,
        'notes': notes,
      };
}
