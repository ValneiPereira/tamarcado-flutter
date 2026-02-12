import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:tamarcado_flutter/features/client/data/datasources/appointments_remote_datasource.dart';
import 'package:tamarcado_flutter/features/client/data/models/appointment_model.dart';

import 'appointments_remote_datasource_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late AppointmentsRemoteDatasource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = AppointmentsRemoteDatasource(mockDio);
  });

  const tId = 'apt-123';
  final tAppointmentJson = {
    'id': tId,
    'date': '2024-01-15',
    'time': '14:30',
    'status': 'PENDING',
    'clientName': 'Client Test',
    'professionalName': 'Pro Test',
  };

  final tApiResponse = {
    'data': tAppointmentJson
  };

  final tListApiResponse = {
    'data': [tAppointmentJson]
  };

  group('getAppointmentById', () {
    test('should return AppointmentModel when call is successful', () async {
      // arrange
      when(mockDio.get(any)).thenAnswer(
        (_) async => Response(
          data: tApiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/appointments/$tId'),
        ),
      );

      // act
      final result = await dataSource.getAppointmentById(tId);

      // assert
      expect(result.id, equals(tId));
      verify(mockDio.get('/appointments/$tId')).called(1);
    });
  });

  group('getClientAppointments', () {
    test('should return list of AppointmentModel when call is successful', () async {
      // arrange
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenAnswer(
        (_) async => Response(
          data: tListApiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/appointments/client'),
        ),
      );

      // act
      final result = await dataSource.getClientAppointments();

      // assert
      expect(result.length, 1);
      expect(result.first.id, tId);
      verify(mockDio.get('/appointments/client', queryParameters: {})).called(1);
    });
  });
}
