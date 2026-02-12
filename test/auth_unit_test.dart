import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:tamarcado_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tamarcado_flutter/features/auth/data/models/auth_response.dart';
import 'package:tamarcado_flutter/features/auth/data/models/user_model.dart';

import 'auth_unit_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late AuthRemoteDatasource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = AuthRemoteDatasource(mockDio);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password';
  
  final tUser = UserModel(
    id: '1',
    name: 'Test User',
    email: tEmail,
    phone: '123456789',
    userType: 'CLIENT',
  );

  final tAuthResponse = AuthResponse(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    user: tUser,
  );

  final tApiResponse = {
    'data': {
      'accessToken': 'access_token',
      'refreshToken': 'refresh_token',
      'user': {
        'id': '1',
        'name': 'Test User',
        'email': tEmail,
        'phone': '123456789',
        'userType': 'CLIENT',
      }
    }
  };

  test('should return AuthResponse when login is successful', () async {
    // arrange
    when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
      (_) async => Response(
        data: tApiResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/login'),
      ),
    );

    // act
    final result = await dataSource.login(email: tEmail, password: tPassword);

    // assert
    expect(result.accessToken, equals(tAuthResponse.accessToken));
    expect(result.user.id, equals(tAuthResponse.user.id));
    verify(mockDio.post('/auth/login', data: {
      'email': tEmail,
      'password': tPassword,
    })).called(1);
  });
}
