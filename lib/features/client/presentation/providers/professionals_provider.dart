import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/services_data.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/professionals_remote_datasource.dart';
import '../../data/models/professional_model.dart';

final professionalsDatasourceProvider =
    Provider<ProfessionalsRemoteDatasource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ProfessionalsRemoteDatasource(dioClient.dio);
});

// Search State
enum SortBy { distance, rating }

class ProfessionalSearchState {
  final int step;
  final ServiceCategory? selectedCategory;
  final String? selectedServiceType;
  final SortBy sortBy;

  const ProfessionalSearchState({
    this.step = 1,
    this.selectedCategory,
    this.selectedServiceType,
    this.sortBy = SortBy.distance,
  });

  ProfessionalSearchState copyWith({
    int? step,
    ServiceCategory? selectedCategory,
    String? selectedServiceType,
    SortBy? sortBy,
  }) {
    return ProfessionalSearchState(
      step: step ?? this.step,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedServiceType: selectedServiceType ?? this.selectedServiceType,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class ProfessionalSearchNotifier
    extends StateNotifier<ProfessionalSearchState> {
  ProfessionalSearchNotifier() : super(const ProfessionalSearchState());

  void setCategory(ServiceCategory category) {
    state = state.copyWith(
      selectedCategory: category,
      step: 2,
    );
  }

  void setServiceType(String serviceType) {
    state = state.copyWith(
      selectedServiceType: serviceType,
      step: 3,
    );
  }

  void setServiceTypeForStep2(String serviceType) {
    state = state.copyWith(
      selectedServiceType: serviceType,
      step: 2,
    );
  }

  void setStep(int step) {
    state = state.copyWith(step: step);
  }

  void setSortBy(SortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void reset() {
    state = const ProfessionalSearchState();
  }

  void goBack() {
    if (state.step > 1) {
      state = state.copyWith(step: state.step - 1);
    }
  }
}

final professionalSearchProvider = StateNotifierProvider<
    ProfessionalSearchNotifier, ProfessionalSearchState>((ref) {
  return ProfessionalSearchNotifier();
});

// Professionals List State
class ProfessionalsListState {
  final List<ProfessionalModel> professionals;
  final bool isLoading;
  final String? error;
  final int totalPages;
  final int currentPage;

  const ProfessionalsListState({
    this.professionals = const [],
    this.isLoading = false,
    this.error,
    this.totalPages = 0,
    this.currentPage = 0,
  });

  ProfessionalsListState copyWith({
    List<ProfessionalModel>? professionals,
    bool? isLoading,
    String? error,
    int? totalPages,
    int? currentPage,
  }) {
    return ProfessionalsListState(
      professionals: professionals ?? this.professionals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ProfessionalsListNotifier
    extends StateNotifier<ProfessionalsListState> {
  final ProfessionalsRemoteDatasource _datasource;

  ProfessionalsListNotifier(this._datasource)
      : super(const ProfessionalsListState());

  Future<void> searchProfessionals({
    String? category,
    String? serviceType,
    double? latitude,
    double? longitude,
    String sortBy = 'distance',
    int page = 0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _datasource.searchProfessionals(
        category: category,
        serviceType: serviceType,
        latitude: latitude,
        longitude: longitude,
        sortBy: sortBy,
        page: page,
      );

      final content = (response['content'] as List<dynamic>?)
              ?.map((e) =>
                  ProfessionalModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      state = state.copyWith(
        professionals: page == 0
            ? content
            : [...state.professionals, ...content],
        isLoading: false,
        totalPages: response['totalPages'] as int? ?? 0,
        currentPage: page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao buscar profissionais',
      );
    }
  }

  void clear() {
    state = const ProfessionalsListState();
  }
}

final professionalsListProvider = StateNotifierProvider<
    ProfessionalsListNotifier, ProfessionalsListState>((ref) {
  final datasource = ref.read(professionalsDatasourceProvider);
  return ProfessionalsListNotifier(datasource);
});

// Selected Professional
final selectedProfessionalProvider =
    StateProvider<ProfessionalModel?>((ref) => null);
