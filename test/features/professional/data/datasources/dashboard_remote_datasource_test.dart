import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:tamarcado_flutter/features/professional/data/datasources/dashboard_remote_datasource.dart';
import 'package:tamarcado_flutter/features/professional/data/models/dashboard_stats_model.dart';

import 'dashboard_remote_datasource_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late DashboardRemoteDatasource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = DashboardRemoteDatasource(mockDio);
  });

  final tStatsJson = {
    'pendingAppointments': 5,
    'completedThisMonth': 10,
    'averageRating': 4.5,
    'monthRevenue': 1500.0,
    'totalRatings': 20,
  };

  final tApiResponse = {
    'data': tStatsJson
  };

  test('should return ProfessionalDashboardModel when call is successful', () async {
    // arrange
    when(mockDio.get(any)).thenAnswer(
      (_) async => Response(
        data: tApiResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/dashboard/professional/stats'),
      ),
    );

    // act
    final result = await dataSource.getProfessionalStats();

    // assert
    expect(result.pendingAppointments, 5);
    expect(result.averageRating, 4.5);
    verify(mockDio.get('/dashboard/professional/stats')).called(1);
  });
}
