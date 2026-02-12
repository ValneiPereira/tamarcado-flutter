class Validators {
  Validators._();

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  static bool isValidCpf(String cpf) {
    final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');

    if (cleanCpf.length != 11) return false;
    if (RegExp(r'^(\d)\1+$').hasMatch(cleanCpf)) return false;

    // Primeiro dígito verificador
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += int.parse(cleanCpf[i]) * (10 - i);
    }
    var digit = 11 - (sum % 11);
    if (digit > 9) digit = 0;
    if (digit != int.parse(cleanCpf[9])) return false;

    // Segundo dígito verificador
    sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += int.parse(cleanCpf[i]) * (11 - i);
    }
    digit = 11 - (sum % 11);
    if (digit > 9) digit = 0;
    if (digit != int.parse(cleanCpf[10])) return false;

    return true;
  }

  static bool isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    return cleanPhone.length == 10 || cleanPhone.length == 11;
  }

  static bool isValidCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
    return cleanCep.length == 8;
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidName(String name) {
    final regex = RegExp(r'^[a-zA-ZÀ-ÿ\s]{3,}$');
    return regex.hasMatch(name.trim());
  }

  static String? getValidationError(String field, String value) {
    switch (field) {
      case 'email':
        return !isValidEmail(value) ? 'Email inválido' : null;
      case 'cpf':
        return !isValidCpf(value) ? 'CPF inválido' : null;
      case 'phone':
        return !isValidPhone(value) ? 'Telefone inválido' : null;
      case 'cep':
        return !isValidCep(value) ? 'CEP inválido' : null;
      case 'password':
        return !isValidPassword(value)
            ? 'Senha deve ter no mínimo 6 caracteres'
            : null;
      case 'name':
        return !isValidName(value) ? 'Nome inválido' : null;
      default:
        return null;
    }
  }
}
