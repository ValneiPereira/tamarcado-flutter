import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../../core/widgets/star_rating.dart';
import '../providers/professionals_provider.dart';

class ProfessionalDetailScreen extends ConsumerStatefulWidget {
  final String professionalId;
  const ProfessionalDetailScreen({super.key, required this.professionalId});

  @override
  ConsumerState<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState
    extends ConsumerState<ProfessionalDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Em um cenário real, carregaríamos os detalhes específicos aqui se não estiverem no estado
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(professionalsListProvider);
    final professionals = listState.professionals;
    
    // Tentar encontrar o profissional
    final profIndex = professionals.indexWhere((p) => p.id == widget.professionalId);
    
    if (profIndex == -1) {
      if (listState.isLoading) {
        return const Scaffold(body: LoadingSpinner(fullScreen: true));
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Ops!')),
        body: const Center(child: Text('Profissional não encontrado.')),
      );
    }
    
    final prof = professionals[profIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(prof),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(prof),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('Serviços'),
                  const SizedBox(height: AppSpacing.md),
                  ...prof.services.map((service) => _buildServiceCard(service)),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('Sobre'),
                  const SizedBox(height: AppSpacing.md),
                  _buildAboutSection(prof),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('Localização'),
                  const SizedBox(height: AppSpacing.md),
                  _buildLocationCard(prof),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('Avaliações'),
                  const SizedBox(height: AppSpacing.md),
                  _buildReviewsSection(prof),
                  const SizedBox(height: 100), // Espaço para o botão flutuante
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(prof),
    );
  }

  Widget _buildSliverAppBar(prof) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (prof.photo != null)
              Image.network(
                prof.photo!,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: AppColors.primaryLight,
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            // Gradient Overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(prof) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prof.name,
                    style: const TextStyle(
                      fontSize: AppTypography.xxxl,
                      fontWeight: AppTypography.bold,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    Formatters.formatServiceName(prof.serviceType),
                    style: TextStyle(
                      fontSize: AppTypography.lg,
                      color: AppColors.primary,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.star.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.star, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    prof.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTypography.lg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.textLight),
            const SizedBox(width: 4),
            Text(
              '${Formatters.formatDistance(prof.distanceKm ?? 0)} de distância',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Icon(Icons.access_time, size: 16, color: AppColors.textLight),
            const SizedBox(width: 4),
            const Text(
              'Aberto agora',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppTypography.xl,
        fontWeight: AppTypography.bold,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildServiceCard(service) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          Formatters.formatDuration(service.durationMinutes),
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Text(
          Formatters.formatCurrency(service.price),
          style: const TextStyle(
            fontSize: AppTypography.lg,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(prof) {
    return Text(
      'Profissional qualificado com vasta experiência em ${Formatters.formatServiceName(prof.serviceType)}. Atendimento personalizado e materiais de alta qualidade para garantir a melhor experiência para você.',
      style: TextStyle(
        fontSize: AppTypography.base,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildLocationCard(prof) {
    final addr = prof.address;
    if (addr == null) return const SizedBox();

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${addr.street}, ${addr.number}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${addr.neighborhood}, ${addr.city} - ${addr.state}',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: AppTypography.sm),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(prof) {
    if (prof.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Nenhuma avaliação ainda',
            style: TextStyle(color: AppColors.textLight),
          ),
        ),
      );
    }
    return Column(
      children: prof.reviews.map<Widget>((review) => _buildReviewItem(review)).toList(),
    );
  }

  Widget _buildReviewItem(review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: review.clientName, size: AvatarSize.small),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    StarRating(rating: review.rating.toDouble(), size: 12),
                  ],
                ),
              ),
              Text(
                Formatters.dateToString(review.createdAt),
                style: TextStyle(fontSize: AppTypography.xs, color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (review.comment != null)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                review.comment!,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(prof) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton(
          title: 'Agendar Horário',
          onPressed: () {
            // TODO: Iniciar fluxo de agendamento
          },
          size: ButtonSize.large,
        ),
      ),
    );
  }
}
