import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/models/dashboard_stats_model.dart';

final dashboardDatasourceProvider =
    Provider<DashboardRemoteDatasource>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return DashboardRemoteDatasource(dio);
});

class DashboardState {
  final ProfessionalDashboardModel? stats;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
  });
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRemoteDatasource _datasource;

  DashboardNotifier(this._datasource) : super(const DashboardState());

  Future<void> loadStats() async {
    state = const DashboardState(isLoading: true, error: null);
    try {
      final stats = await _datasource.getProfessionalStats();
      state = DashboardState(stats: stats, isLoading: false);
    } catch (e) {
      state = DashboardState(
        isLoading: false,
        error: 'Erro ao carregar o dashboard',
      );
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final datasource = ref.read(dashboardDatasourceProvider);
  return DashboardNotifier(datasource);
});
