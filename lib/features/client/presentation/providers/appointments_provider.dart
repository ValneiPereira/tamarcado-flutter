import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/appointments_remote_datasource.dart';
import '../../data/models/appointment_model.dart';

final appointmentsDatasourceProvider =
    Provider<AppointmentsRemoteDatasource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AppointmentsRemoteDatasource(dioClient.dio);
});

// State
class AppointmentsState {
  final List<AppointmentModel> appointments;
  final bool isLoading;
  final String? error;

  const AppointmentsState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
  });

  AppointmentsState copyWith({
    List<AppointmentModel>? appointments,
    bool? isLoading,
    String? error,
  }) {
    return AppointmentsState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  final AppointmentsRemoteDatasource _datasource;

  AppointmentsNotifier(this._datasource) : super(const AppointmentsState());

  Future<void> loadClientAppointments({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final appointments =
          await _datasource.getClientAppointments(status: status);
      state = state.copyWith(appointments: appointments, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar agendamentos',
      );
    }
  }

  Future<void> loadProfessionalAppointments({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final appointments =
          await _datasource.getProfessionalAppointments(status: status);
      state = state.copyWith(appointments: appointments, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar agendamentos',
      );
    }
  }

  Future<void> createAppointment({
    required String professionalId,
    required String serviceId,
    required String date,
    required String time,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final appointment = await _datasource.createAppointment(
        professionalId: professionalId,
        serviceId: serviceId,
        date: date,
        time: time,
        notes: notes,
      );
      state = state.copyWith(
        appointments: [...state.appointments, appointment],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao criar agendamento',
      );
      rethrow;
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      await _datasource.cancelAppointment(id);
      state = state.copyWith(
        appointments: state.appointments.where((a) => a.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao cancelar agendamento');
    }
  }

  Future<void> acceptAppointment(String id) async {
    await _datasource.acceptAppointment(id);
    await loadProfessionalAppointments();
  }

  Future<void> rejectAppointment(String id) async {
    await _datasource.rejectAppointment(id);
    await loadProfessionalAppointments();
  }

  Future<void> completeAppointment(String id) async {
    await _datasource.completeAppointment(id);
    await loadProfessionalAppointments();
  }

  void clear() {
    state = const AppointmentsState();
  }
}

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, AppointmentsState>((ref) {
  final datasource = ref.read(appointmentsDatasourceProvider);
  return AppointmentsNotifier(datasource);
});
