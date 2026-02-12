enum ServiceCategory {
  beleza('BELEZA', 'Beleza'),
  saude('SAUDE', 'Saúde'),
  servicos('SERVICOS', 'Serviços'),
  educacao('EDUCACAO', 'Educação'),
  outros('OUTROS', 'Outros');

  final String value;
  final String label;
  const ServiceCategory(this.value, this.label);

  static ServiceCategory fromValue(String value) {
    return ServiceCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ServiceCategory.outros,
    );
  }
}

enum ServiceType {
  // Beleza
  cabeleireiro('CABELEIREIRO', 'Cabeleireiro(a)', ServiceCategory.beleza),
  barbeiro('BARBEIRO', 'Barbeiro', ServiceCategory.beleza),
  esteticista('ESTETICISTA', 'Esteticista', ServiceCategory.beleza),
  designerSobrancelha('DESIGNER_SOBRANCELHA', 'Designer de Sobrancelha', ServiceCategory.beleza),
  manicure('MANICURE', 'Manicure', ServiceCategory.beleza),

  // Saúde
  psicologo('PSICOLOGO', 'Psicólogo(a)', ServiceCategory.saude),
  fisioterapeuta('FISIOTERAPEUTA', 'Fisioterapeuta', ServiceCategory.saude),
  nutricionista('NUTRICIONISTA', 'Nutricionista', ServiceCategory.saude),
  personalTrainer('PERSONAL_TRAINER', 'Personal Trainer', ServiceCategory.saude),

  // Serviços
  eletricista('ELETRICISTA', 'Eletricista', ServiceCategory.servicos),
  encanador('ENCANADOR', 'Encanador', ServiceCategory.servicos),
  tecnicoInformatica('TECNICO_INFORMATICA', 'Técnico de Informática', ServiceCategory.servicos),
  montadorMoveis('MONTADOR_MOVEIS', 'Montador de Móveis', ServiceCategory.servicos),
  pedreiro('PEDREIRO', 'Pedreiro', ServiceCategory.servicos),
  diarista('DIARISTA', 'Diarista', ServiceCategory.servicos),

  // Educação
  aulaParticular('AULA_PARTICULAR', 'Aula Particular', ServiceCategory.educacao),
  professorIdiomas('PROFESSOR_IDIOMAS', 'Professor de Idiomas', ServiceCategory.educacao),
  reforcoEscolar('REFORCO_ESCOLAR', 'Reforço Escolar', ServiceCategory.educacao),
  mentor('MENTOR', 'Mentor', ServiceCategory.educacao),

  // Outros
  outros('OUTROS', 'Outros', ServiceCategory.outros);

  final String value;
  final String label;
  final ServiceCategory category;
  const ServiceType(this.value, this.label, this.category);

  static ServiceType fromValue(String value) {
    return ServiceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ServiceType.outros,
    );
  }

  static List<ServiceType> byCategory(ServiceCategory category) {
    return ServiceType.values.where((e) => e.category == category).toList();
  }
}

enum AppointmentStatus {
  pending('PENDING', 'Pendente'),
  accepted('ACCEPTED', 'Confirmado'),
  rejected('REJECTED', 'Recusado'),
  completed('COMPLETED', 'Concluído'),
  cancelled('CANCELLED', 'Cancelado');

  final String value;
  final String label;
  const AppointmentStatus(this.value, this.label);

  static AppointmentStatus fromValue(String value) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AppointmentStatus.pending,
    );
  }
}

enum UserType {
  client('CLIENT', 'Cliente'),
  professional('PROFESSIONAL', 'Profissional');

  final String value;
  final String label;
  const UserType(this.value, this.label);

  static UserType fromValue(String value) {
    return UserType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserType.client,
    );
  }
}

enum NotificationType {
  appointmentCreated('APPOINTMENT_CREATED'),
  appointmentAccepted('APPOINTMENT_ACCEPTED'),
  appointmentRejected('APPOINTMENT_REJECTED'),
  appointmentCompleted('APPOINTMENT_COMPLETED'),
  appointmentCancelled('APPOINTMENT_CANCELLED'),
  appointmentReminder('APPOINTMENT_REMINDER');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.appointmentCreated,
    );
  }
}
