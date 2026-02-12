class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode)';
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Sessão expirada. Faça login novamente.',
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Recurso não encontrado.']);
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Erro no servidor. Tente novamente mais tarde.',
  ]);
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Sem conexão com a internet.',
  ]);
}
