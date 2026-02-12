import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../client/presentation/providers/appointments_provider.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../providers/dashboard_provider.dart';

class ProfessionalDashboardScreen extends ConsumerStatefulWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  ConsumerState<ProfessionalDashboardScreen> createState() =>
      _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState
    extends ConsumerState<ProfessionalDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadStats();
      ref.read(appointmentsProvider.notifier).loadProfessionalAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final dashboardState = ref.watch(dashboardProvider);
    final appointmentsState = ref.watch(appointmentsProvider);
    final firstName = user?.name?.split(' ').first ?? '';
    final stats = dashboardState.stats;

    if (dashboardState.isLoading && stats == null) {
      return const LoadingSpinner(
          fullScreen: true, text: 'Carregando dashboard...');
    }

    final upcomingList = appointmentsState.appointments
        .where((a) => a.status == 'PENDING' || a.status == 'ACCEPTED' || a.status == 'CONFIRMED')
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(dashboardProvider.notifier).loadStats();
            await ref.read(appointmentsProvider.notifier).loadProfessionalAppointments();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user, firstName),
                if (stats == null && dashboardState.error != null)
                  _buildErrorState()
                else ...[
                  if (stats != null) _buildStatsGrid(stats),
                  const SizedBox(height: AppSpacing.lg),
                  _buildUpcomingSection(upcomingList),
                  if (stats != null) _buildRatingSection(stats),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(user, String firstName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      color: AppColors.secondary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $firstName!',
                style: TextStyle(
                    fontSize: AppTypography.xl,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textOnPrimary),
              ),
              Text(
                'Tá Marcado!',
                style: TextStyle(
                    fontSize: AppTypography.sm,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.8)),
              ),
            ],
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.textLight),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Erro ao carregar dados do dashboard',
            style: TextStyle(
                fontSize: AppTypography.base, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ProfessionalDashboardModel stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.md) / 2;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _StatCard(
              icon: Icons.calendar_today,
              value: '${stats.pendingAppointments}',
              label: 'Pendentes',
              color: AppColors.primary,
              width: width,
            ),
            _StatCard(
              icon: Icons.check_circle,
              value: '${stats.completedThisMonth}',
              label: 'Concluídos',
              color: AppColors.success,
              width: width,
            ),
            _StatCard(
              icon: Icons.star,
              value: stats.averageRating.toStringAsFixed(1),
              label: 'Avaliação',
              color: AppColors.star,
              width: width,
            ),
            _StatCard(
              icon: Icons.attach_money,
              value: Formatters.formatCurrency(stats.monthRevenue),
              label: 'Este mês',
              color: AppColors.success,
              width: width,
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingSection(List upcomingList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximos Agendamentos',
              style: TextStyle(
                  fontSize: AppTypography.lg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.professionalAppointments),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (upcomingList.isEmpty)
          AppCard(
            variant: CardVariant.elevated,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 48, color: AppColors.textLight),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Nenhum agendamento próximo',
                  style: TextStyle(
                      fontSize: AppTypography.base,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ...upcomingList.map((apt) => _buildAppointmentCard(apt)),
      ],
    );
  }

  Widget _buildAppointmentCard(apt) {
    final statusInfo = Formatters.formatAppointmentStatus(apt.status);
    final price = apt.service?.price ?? 0.0;

    return AppCard(
      variant: CardVariant.elevated,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBadge(
                label: statusInfo.label,
                variant: apt.status == 'PENDING'
                    ? BadgeVariant.warning
                    : BadgeVariant.success,
                size: BadgeSize.small,
              ),
              Text(
                '${Formatters.formatDateRelative(apt.date)} às ${Formatters.formatTime(apt.time)}',
                style: TextStyle(
                    fontSize: AppTypography.sm,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AppAvatar(
                name: apt.clientName,
                size: AvatarSize.medium,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apt.clientName ?? '—',
                      style: const TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text),
                    ),
                    Text(
                      apt.service?.name ?? '—',
                      style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.formatCurrency(price),
                style: const TextStyle(
                    fontSize: AppTypography.lg,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ],
          ),
          if (apt.status == 'PENDING') ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectAppointment(apt.id),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error)),
                    child: const Text('Recusar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptAppointment(apt.id),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success),
                    child: const Text('Aceitar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _acceptAppointment(int id) async {
    await ref.read(appointmentsProvider.notifier).acceptAppointment(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento aceito!')),
      );
    }
  }

  Future<void> _rejectAppointment(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recusar Agendamento'),
        content: const Text('Tem certeza que deseja recusar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Não')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sim, recusar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(appointmentsProvider.notifier).rejectAppointment(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento recusado')),
        );
      }
    }
  }

  Widget _buildRatingSection(ProfessionalDashboardModel stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Sua Avaliação',
          style: TextStyle(
              fontSize: AppTypography.lg,
              fontWeight: FontWeight.w600,
              color: AppColors.text),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          variant: CardVariant.elevated,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: AppTypography.bold,
                    color: AppColors.text),
              ),
              const SizedBox(height: AppSpacing.sm),
              StarRating(
                  rating: stats.averageRating,
                  size: 24,
                  showCount: true,
                  count: stats.totalRatings),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final double width;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppCard(
        variant: CardVariant.defaultCard,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: TextStyle(
                  fontSize: AppTypography.xl,
                  fontWeight: AppTypography.bold,
                  color: AppColors.text),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
