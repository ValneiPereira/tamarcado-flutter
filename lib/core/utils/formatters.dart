import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  // Formatar data: 15 de Janeiro de 2024
  static String formatDate(dynamic date) {
    final dateObj = _parseDate(date);
    return DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(dateObj);
  }

  // Formatar data curta: 15/01/2024
  static String formatDateShort(dynamic date) {
    final dateObj = _parseDate(date);
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(dateObj);
  }

  // Formatar hora: 14:30
  static String formatTime(String time) {
    if (time.length >= 5) return time.substring(0, 5);
    return time;
  }

  // Formatar data e hora: 15/01/2024 às 14:30
  static String formatDateTime(dynamic date, [String? time]) {
    final dateObj = _parseDate(date);
    final formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(dateObj);

    if (time != null) {
      return '$formattedDate às ${formatTime(time)}';
    }

    return DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(dateObj);
  }

  // Formatar data relativa: Hoje, Amanhã, 15 de Janeiro
  static String formatDateRelative(dynamic date) {
    final dateObj = _parseDate(date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateObj.year, dateObj.month, dateObj.day);

    if (dateOnly == today) return 'Hoje';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Amanhã';

    return DateFormat("d 'de' MMMM", 'pt_BR').format(dateObj);
  }

  // Formatar tempo relativo: há 5 minutos, há 2 dias
  static String formatTimeAgo(dynamic date) {
    final dateObj = _parseDate(date);
    final diff = DateTime.now().difference(dateObj);

    if (diff.inSeconds < 60) return 'há poucos segundos';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} minutos';
    if (diff.inHours < 24) return 'há ${diff.inHours} horas';
    if (diff.inDays < 30) return 'há ${diff.inDays} dias';
    if (diff.inDays < 365) return 'há ${(diff.inDays / 30).floor()} meses';
    return 'há ${(diff.inDays / 365).floor()} anos';
  }

  // Formatar moeda: R$ 1.234,56
  static String formatCurrency(num value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  // Formatar distância: 1.5 km ou 500 m
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  // Formatar nome do serviço: BARBEIRO -> Barbeiro
  static String formatServiceName(String service) {
    return service
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  // Formatar status do agendamento
  static ({String label, String variant}) formatAppointmentStatus(
      String status) {
    const statusMap = {
      'PENDING': (label: 'Pendente', variant: 'warning'),
      'ACCEPTED': (label: 'Confirmado', variant: 'success'),
      'CONFIRMED': (label: 'Confirmado', variant: 'success'),
      'CANCELLED': (label: 'Cancelado', variant: 'error'),
      'COMPLETED': (label: 'Concluído', variant: 'primary'),
      'REJECTED': (label: 'Recusado', variant: 'error'),
    };

    return statusMap[status] ?? (label: status, variant: 'neutral');
  }

  // Obter iniciais do nome: João Silva -> JS
  static String getInitials(String name) {
    return name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  // Obter ícone do tipo de serviço
  static String getServiceIcon(String serviceType) {
    const icons = {
      'CABELEIREIRO': '\u{1F487}',
      'BARBEIRO': '\u{1F488}',
      'ESTETICISTA': '\u{1F486}',
      'DESIGNER_SOBRANCELHA': '\u{2728}',
      'MANICURE': '\u{1F485}',
      'PSICOLOGO': '\u{1F9E0}',
      'FISIOTERAPEUTA': '\u{1F3E5}',
      'NUTRICIONISTA': '\u{1F957}',
      'PERSONAL_TRAINER': '\u{1F4AA}',
      'ELETRICISTA': '\u{26A1}',
      'ENCANADOR': '\u{1F527}',
      'TECNICO_INFORMATICA': '\u{1F4BB}',
      'MONTADOR_MOVEIS': '\u{1FA9B}',
      'PEDREIRO': '\u{1F9F1}',
      'DIARISTA': '\u{1F9F9}',
      'AULA_PARTICULAR': '\u{1F4D6}',
      'PROFESSOR_IDIOMAS': '\u{1F30D}',
      'REFORCO_ESCOLAR': '\u{1F4DA}',
      'MENTOR': '\u{1F468}\u{200D}\u{1F3EB}',
      'OUTROS': '\u{1F4E6}',
    };

    return icons[serviceType] ?? '\u{1F539}';
  }

  static DateTime _parseDate(dynamic date) {
    if (date is DateTime) return date;
    if (date is String) return DateTime.parse(date);
    throw ArgumentError('Tipo de data inválido: ${date.runtimeType}');
  }
}
