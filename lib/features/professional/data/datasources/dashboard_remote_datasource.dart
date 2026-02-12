import 'package:dio/dio.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRemoteDatasource {
  final Dio _dio;

  DashboardRemoteDatasource(this._dio);

  Future<ProfessionalDashboardModel> getProfessionalStats() async {
    final response = await _dio.get('/dashboard/professional/stats');
    final data = response.data['data'] as Map<String, dynamic>;
    return ProfessionalDashboardModel.fromJson(data);
  }

  Future<ClientDashboardModel> getClientStats() async {
    final response = await _dio.get('/dashboard/client/stats');
    final data = response.data['data'] as Map<String, dynamic>;
    return ClientDashboardModel.fromJson(data);
  }
}
