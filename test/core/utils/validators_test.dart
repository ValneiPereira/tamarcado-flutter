import 'package:flutter_test/flutter_test.dart';
import 'package:tamarcado_flutter/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('isValidEmail should validate email correctly', () {
      expect(Validators.isValidEmail('test@test.com'), isTrue);
      expect(Validators.isValidEmail('test@test'), isFalse);
      expect(Validators.isValidEmail('test.com'), isFalse);
    });

    test('isValidCpf should validate CPF correctly', () {
      // Valid CPF (generated for testing)
      expect(Validators.isValidCpf('444.444.444-44'), isFalse); // Same digits
      expect(Validators.isValidCpf('123.456.789-09'), isTrue);
    });

    test('isValidPhone should validate phone correctly', () {
      expect(Validators.isValidPhone('(11) 99999-9999'), isTrue);
      expect(Validators.isValidPhone('11999999999'), isTrue);
      expect(Validators.isValidPhone('12345'), isFalse);
    });

    test('isValidCep should validate CEP correctly', () {
      expect(Validators.isValidCep('12345-678'), isTrue);
      expect(Validators.isValidCep('12345678'), isTrue);
      expect(Validators.isValidCep('123'), isFalse);
    });

    test('isValidPassword should validate password correctly', () {
      expect(Validators.isValidPassword('123456'), isTrue);
      expect(Validators.isValidPassword('12345'), isFalse);
    });
  });
}
