import 'package:flutter_test/flutter_test.dart';
import 'package:tamarcado_flutter/features/auth/data/models/user_model.dart';
import 'package:tamarcado_flutter/features/shared/data/models/address_model.dart';
import 'package:tamarcado_flutter/features/client/data/models/professional_model.dart';

void main() {
  group('AddressModel', () {
    test('should return a valid model from JSON', () {
      final Map<String, dynamic> jsonMap = {
        'cep': '12345-678',
        'street': 'Rua Teste',
        'number': '123',
        'neighborhood': 'Bairro',
        'city': 'Cidade',
        'state': 'SP',
      };

      final result = AddressModel.fromJson(jsonMap);

      expect(result.cep, '12345-678');
      expect(result.street, 'Rua Teste');
    });

    test('should return a JSON map containing the proper data', () {
      const model = AddressModel(
        cep: '12345-678',
        street: 'Rua Teste',
        number: '123',
        neighborhood: 'Bairro',
        city: 'Cidade',
        state: 'SP',
      );

      final result = model.toJson();

      expect(result['cep'], '12345-678');
      expect(result['street'], 'Rua Teste');
    });
  });

  group('UserModel', () {
    test('should return a valid model from JSON', () {
      final Map<String, dynamic> jsonMap = {
        'id': 'uuid-123',
        'name': 'User Test',
        'email': 'test@test.com',
        'phone': '123456789',
        'userType': 'CLIENT',
      };

      final result = UserModel.fromJson(jsonMap);

      expect(result.id, 'uuid-123');
      expect(result.isClient, true);
    });
  });

  group('ProfessionalModel', () {
    test('should return a valid model from JSON', () {
      final Map<String, dynamic> jsonMap = {
        'id': 'prop-123',
        'name': 'Professional Test',
        'category': 'Beleza',
        'serviceType': 'Cabelo',
      };

      final result = ProfessionalModel.fromJson(jsonMap);

      expect(result.id, 'prop-123');
      expect(result.name, 'Professional Test');
    });
  });
}
