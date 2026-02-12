class BusinessHoursModel {
  final String? id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool active;

  const BusinessHoursModel({
    this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.active,
  });

  factory BusinessHoursModel.fromJson(Map<String, dynamic> json) {
    return BusinessHoursModel(
      id: json['id']?.toString(),
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String? ?? '08:00',
      endTime: json['endTime'] as String? ?? '18:00',
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'active': active,
      };

  BusinessHoursModel copyWith({
    String? id,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? active,
  }) {
    return BusinessHoursModel(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      active: active ?? this.active,
    );
  }

  static String dayName(int dayOfWeek) {
    const days = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    return days[dayOfWeek];
  }

  static String dayShortName(int dayOfWeek) {
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[dayOfWeek];
  }

  static List<BusinessHoursModel> defaultWeek() {
    return List.generate(
      7,
      (i) => BusinessHoursModel(
        dayOfWeek: i,
        startTime: '08:00',
        endTime: '18:00',
        active: i < 5,
      ),
    );
  }
}
