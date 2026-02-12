import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Masks {
  Masks._();

  // Formatadores para uso em TextFormField
  static MaskTextInputFormatter phone() => MaskTextInputFormatter(
        mask: '(##) #####-####',
        filter: {'#': RegExp(r'[0-9]')},
      );

  static MaskTextInputFormatter cep() => MaskTextInputFormatter(
        mask: '#####-###',
        filter: {'#': RegExp(r'[0-9]')},
      );

  static MaskTextInputFormatter cpf() => MaskTextInputFormatter(
        mask: '###.###.###-##',
        filter: {'#': RegExp(r'[0-9]')},
      );

  static MaskTextInputFormatter cnpj() => MaskTextInputFormatter(
        mask: '##.###.###/####-##',
        filter: {'#': RegExp(r'[0-9]')},
      );

  // Funções de formatação manual (equivalente a masks.ts)
  static String maskPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 2) return '($digits';
    if (digits.length <= 7) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2)}';
    }
    if (digits.length <= 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    }
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
  }

  static String maskCep(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 5) return digits;
    if (digits.length <= 8) {
      return '${digits.substring(0, 5)}-${digits.substring(5)}';
    }
    return '${digits.substring(0, 5)}-${digits.substring(5, 8)}';
  }

  static String maskCpf(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) {
      return '${digits.substring(0, 3)}.${digits.substring(3)}';
    }
    if (digits.length <= 9) {
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6)}';
    }
    if (digits.length <= 11) {
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
    }
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9, 11)}';
  }

  static String maskCnpj(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 2) return digits;
    if (digits.length <= 5) {
      return '${digits.substring(0, 2)}.${digits.substring(2)}';
    }
    if (digits.length <= 8) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5)}';
    }
    if (digits.length <= 12) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8)}';
    }
    if (digits.length <= 14) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
    }
    return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12, 14)}';
  }

  static String maskCurrency(String value) {
    final numbers = value.replaceAll(RegExp(r'\D'), '');
    final amount = int.parse(numbers.isEmpty ? '0' : numbers) / 100;
    return 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String unmask(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }
}
