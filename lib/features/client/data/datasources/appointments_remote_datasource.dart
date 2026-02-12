import 'package:dio/dio.dart';
import '../models/appointment_model.dart';

class AppointmentsRemoteDatasource {
  final Dio _dio;

  AppointmentsRemoteDatasource(this._dio);

  Future<AppointmentModel> createAppointment({
    required String professionalId,
    required String serviceId,
    required String date,
    required String time,
    String? notes,
  }) async {
    final response = await _dio.post('/appointments', data: {
      'professionalId': professionalId,
      'serviceId': serviceId,
      'date': date,
      'time': time,
      if (notes != null) 'notes': notes,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return AppointmentModel.fromJson(data);
  }

  Future<List<AppointmentModel>> getClientAppointments({String? status}) async {
    final response = await _dio.get(
      '/appointments/client',
      queryParameters: {if (status != null) 'status': status},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppointmentModel>> getProfessionalAppointments({
    String? status,
  }) async {
    final response = await _dio.get(
      '/appointments/professional',
      queryParameters: {if (status != null) 'status': status},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    final response = await _dio.get('/appointments/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return AppointmentModel.fromJson(data);
  }

  Future<void> cancelAppointment(String id) async {
    await _dio.delete('/appointments/$id');
  }

  Future<void> acceptAppointment(String id) async {
    await _dio.put('/appointments/$id/accept');
  }

  Future<void> rejectAppointment(String id) async {
    await _dio.put('/appointments/$id/reject');
  }

  Future<void> completeAppointment(String id) async {
    await _dio.put('/appointments/$id/complete');
  }
}
