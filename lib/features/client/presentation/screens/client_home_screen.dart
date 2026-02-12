import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/services_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../../core/widgets/star_rating.dart';
import '../providers/professionals_provider.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  bool _showCategoryModal = false;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      if (await Geolocator.isLocationServiceEnabled()) {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) setState(() => _position = pos);
      }
    } catch (_) {}
  }

  void _searchProfessionals() {
    final search = ref.read(professionalSearchProvider);
    ref.read(professionalsListProvider.notifier).searchProfessionals(
          category: search.selectedCategory?.value,
          serviceType: search.selectedServiceType,
          latitude: _position?.latitude,
          longitude: _position?.longitude,
          sortBy: search.sortBy == SortBy.distance ? 'distance' : 'rating',
        );
    ref.read(professionalSearchProvider.notifier).setStep(3);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final searchState = ref.watch(professionalSearchProvider);
    final listState = ref.watch(professionalsListProvider);
    final firstName = user?.name?.split(' ').first ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user),
            Expanded(
              child: listState.isLoading
                  ? const LoadingSpinner(
                      fullScreen: true,
                      text: 'Buscando profissionais...',
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: _buildStepContent(
                        searchState,
                        listState,
                        firstName,
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomSheet: _showCategoryModal ? _buildCategoryModal(searchState) : null,
    );
  }

  Widget _buildHeader(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md,
          AppSpacing.lg, AppSpacing.md),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tá Marcado!',
            style: TextStyle(
                fontSize: AppTypography.xxl,
                fontWeight: AppTypography.bold,
                color: AppColors.textOnPrimary),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textOnPrimary),
                onPressed: () {},
              ),
              AppAvatar(
                imageUrl: user?.photo,
                name: user?.name,
                size: AvatarSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    ProfessionalSearchState searchState,
    ProfessionalsListState listState,
    String firstName,
  ) {
    switch (searchState.step) {
      case 1:
        return _buildStep1(searchState, firstName);
      case 2:
        return _buildStep2(searchState);
      case 3:
        return _buildStep3(searchState, listState);
      default:
        return _buildStep1(searchState, firstName);
    }
  }

  Widget _buildStep1(ProfessionalSearchState searchState, String firstName) {
    final category = searchState.selectedCategory ?? ServiceCategory.beleza;
    final types = ServiceType.byCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá, $firstName!',
          style: TextStyle(
              fontSize: AppTypography.xxl,
              fontWeight: AppTypography.bold,
              color: AppColors.text),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Qual serviço você precisa?',
          style: TextStyle(
              fontSize: AppTypography.base, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Categoria',
            style: TextStyle(
                fontSize: AppTypography.sm,
                fontWeight: AppTypography.medium,
                color: AppColors.text)),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => setState(() => _showCategoryModal = true),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: AppTypography.base,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...types.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: InkWell(
                  onTap: () {
                    ref.read(professionalSearchProvider.notifier).setCategory(category);
                    ref.read(professionalSearchProvider.notifier).setServiceTypeForStep2(type.value);
                  },
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    child: Row(
                      children: [
                        Text(
                          Formatters.getServiceIcon(type.value),
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            type.label.toUpperCase(),
                            style: const TextStyle(
                                fontSize: AppTypography.base,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary, size: 24),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildStep2(ProfessionalSearchState searchState) {
    final typeLabel = searchState.selectedServiceType != null
        ? Formatters.formatServiceName(searchState.selectedServiceType!)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
              ref.read(professionalSearchProvider.notifier).goBack(),
          child: Row(
            children: [
              const Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Voltar',
                style: TextStyle(
                    fontSize: AppTypography.base,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          typeLabel,
          style: TextStyle(
              fontSize: AppTypography.xl,
              fontWeight: AppTypography.bold,
              color: AppColors.text),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Escolha o serviço desejado:',
          style: TextStyle(
              fontSize: AppTypography.base, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: AppColors.textLight),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Os profissionais serão listados na próxima etapa.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: AppTypography.base,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _searchProfessionals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: const Text('Buscar profissionais'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(
      ProfessionalSearchState searchState, ProfessionalsListState listState) {
    final sortBy = searchState.sortBy;
    final list = [...listState.professionals];
    list.sort((a, b) {
      if (sortBy == SortBy.distance) {
        final da = a.distanceKm ?? double.infinity;
        final db = b.distanceKm ?? double.infinity;
        return da.compareTo(db);
      }
      return b.averageRating.compareTo(a.averageRating);
    });

    final typeLabel = searchState.selectedServiceType != null
        ? Formatters.formatServiceName(searchState.selectedServiceType!)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
              ref.read(professionalSearchProvider.notifier).goBack(),
          child: Row(
            children: [
              const Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Voltar',
                style: TextStyle(
                    fontSize: AppTypography.base,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          typeLabel,
          style: TextStyle(
              fontSize: AppTypography.xl,
              fontWeight: AppTypography.bold,
              color: AppColors.text),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          list.isEmpty
              ? 'Nenhum profissional encontrado'
              : '${list.length} profissionais encontrados',
          style: TextStyle(
              fontSize: AppTypography.base, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _SortChip(
                label: 'Distância',
                icon: Icons.location_on,
                selected: sortBy == SortBy.distance,
                onTap: () => ref
                    .read(professionalSearchProvider.notifier)
                    .setSortBy(SortBy.distance),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SortChip(
                label: 'Avaliação',
                icon: Icons.star,
                selected: sortBy == SortBy.rating,
                onTap: () => ref
                    .read(professionalSearchProvider.notifier)
                    .setSortBy(SortBy.rating),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (list.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 48, color: AppColors.textLight),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Nenhum profissional encontrado',
                  style: TextStyle(
                      fontSize: AppTypography.base,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ...list.map((prof) {
            final price = prof.services.isNotEmpty
                ? prof.services.first.price
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    // TODO: navegar para detalhe do profissional
                    // context.push('${RouteNames.clientHome}/professional/${prof.id}');
                  },
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        AppAvatar(
                          imageUrl: prof.photo,
                          name: prof.name,
                          size: AvatarSize.large,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prof.name,
                                style: const TextStyle(
                                    fontSize: AppTypography.lg,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text),
                              ),
                              StarRating(
                                rating: prof.averageRating,
                                size: 14,
                                showCount: true,
                                count: prof.totalRatings,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    Formatters.formatDistance(
                                        prof.distanceKm ?? 0),
                                    style: TextStyle(
                                        fontSize: AppTypography.sm,
                                        color: AppColors.textSecondary),
                                  ),
                                  const Spacer(),
                                  Text(
                                    Formatters.formatCurrency(price),
                                    style: const TextStyle(
                                        fontSize: AppTypography.base,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget? _buildCategoryModal(ProfessionalSearchState searchState) {
    if (!_showCategoryModal) return null;
    return Container(
      color: Colors.black54,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Categoria',
                  style: TextStyle(
                      fontSize: AppTypography.xl,
                      fontWeight: AppTypography.bold,
                      color: AppColors.text),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: ServiceCategory.values.map((cat) {
                    final selected =
                        (searchState.selectedCategory ?? ServiceCategory.beleza) ==
                            cat;
                    return ListTile(
                      title: Text(
                        cat.value,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.w500,
                          color: selected ? AppColors.primary : AppColors.text,
                        ),
                      ),
                      onTap: () {
                        ref
                            .read(professionalSearchProvider.notifier)
                            .setCategory(cat);
                        setState(() => _showCategoryModal = false);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.gray100,
      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected
                      ? AppColors.textOnPrimary
                      : AppColors.text),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? AppColors.textOnPrimary
                      : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
