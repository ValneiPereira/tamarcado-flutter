import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tamarcado_flutter/core/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  group('Formatters', () {
    test('formatCurrency should format value correctly', () {
      expect(Formatters.formatCurrency(1234.56), contains('1.234,56'));
    });

    test('formatTime should format time string correctly', () {
      expect(Formatters.formatTime('14:30:00'), '14:30');
      expect(Formatters.formatTime('09:00'), '09:00');
    });

    test('getInitials should return correct initials', () {
      expect(Formatters.getInitials('João Silva'), 'JS');
      expect(Formatters.getInitials('Maria'), 'M');
      expect(Formatters.getInitials(''), '');
    });

    test('formatDistance should format distance correctly', () {
      expect(Formatters.formatDistance(1.5), '1.5 km');
      expect(Formatters.formatDistance(0.5), '500 m');
    });

    test('formatServiceName should format correctly', () {
      expect(Formatters.formatServiceName('CORTE_CABELO'), 'Corte Cabelo');
    });
  });
}
