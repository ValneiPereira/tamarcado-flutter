import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../data/models/appointment_model.dart';
import '../providers/appointments_provider.dart';

enum _TabType { upcoming, history }

class ClientAppointmentsScreen extends ConsumerStatefulWidget {
  const ClientAppointmentsScreen({super.key});

  @override
  ConsumerState<ClientAppointmentsScreen> createState() =>
      _ClientAppointmentsScreenState();
}

class _ClientAppointmentsScreenState
    extends ConsumerState<ClientAppointmentsScreen> {
  _TabType _activeTab = _TabType.upcoming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await ref.read(appointmentsProvider.notifier).loadClientAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsState = ref.watch(appointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(appointmentsProvider.notifier)
                      .loadClientAppointments();
                },
                child: _activeTab != _TabType.upcoming
                    ? _buildContent(appointmentsState, isHistory: true)
                    : _buildContent(appointmentsState, isHistory: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      color: AppColors.primary,
      child: Text(
        'Agendamentos',
        style: TextStyle(
            fontSize: AppTypography.xxl,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: _activeTab == _TabType.upcoming
                  ? AppColors.primary
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              child: InkWell(
                onTap: () {
                  setState(() => _activeTab = _TabType.upcoming);
                },
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Center(
                    child: Text(
                      'Próximos',
                      style: TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: FontWeight.w500,
                          color: _activeTab == _TabType.upcoming
                              ? AppColors.textOnPrimary
                              : AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Material(
              color: _activeTab == _TabType.history
                  ? AppColors.primary
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              child: InkWell(
                onTap: () {
                  setState(() => _activeTab = _TabType.history);
                },
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Center(
                    child: Text(
                      'Histórico',
                      style: TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: FontWeight.w500,
                          color: _activeTab == _TabType.history
                              ? AppColors.textOnPrimary
                              : AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppointmentsState state, {required bool isHistory}) {
    if (state.isLoading && state.appointments.isEmpty) {
      return const LoadingSpinner(
          fullScreen: true, text: 'Carregando agendamentos...');
    }

    final list = state.appointments.where((a) {
      if (isHistory) {
        return a.status == 'COMPLETED' || a.status == 'CANCELLED';
      }
      return a.status == 'PENDING' || a.status == 'ACCEPTED' || a.status == 'CONFIRMED';
    }).toList();

    if (list.isEmpty) {
      return _buildEmptyState(isHistory);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildAppointmentCard(list[index]),
    );
  }

  Widget _buildEmptyState(bool isHistory) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 64, color: AppColors.textLight),
          const SizedBox(height: AppSpacing.md),
          Text(
            isHistory
                ? 'Nenhum agendamento no histórico'
                : 'Nenhum agendamento futuro',
            style: TextStyle(
                fontSize: AppTypography.lg,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isHistory
                ? 'Seus agendamentos concluídos aparecerão aqui'
                : 'Agende um serviço para começar!',
            style: TextStyle(
                fontSize: AppTypography.base,
                color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel apt) {
    final statusInfo = Formatters.formatAppointmentStatus(apt.status);
    final canCancel =
        apt.status == 'PENDING' || apt.status == 'ACCEPTED' || apt.status == 'CONFIRMED';
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
                variant: _badgeVariant(statusInfo.variant),
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
                imageUrl: null,
                name: apt.professionalName,
                size: AvatarSize.medium,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apt.professionalName ?? '—',
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
          if (canCancel) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              title: 'Cancelar',
              onPressed: () => _confirmCancel(apt.id),
              variant: ButtonVariant.outline,
              size: ButtonSize.small,
            ),
          ],
          if (apt.status == 'COMPLETED') ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              title: 'Avaliar',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento')),
                );
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }

  BadgeVariant _badgeVariant(String variant) {
    switch (variant) {
      case 'success':
        return BadgeVariant.success;
      case 'error':
        return BadgeVariant.error;
      case 'warning':
        return BadgeVariant.warning;
      case 'primary':
        return BadgeVariant.primary;
      default:
        return BadgeVariant.neutral;
    }
  }

  Future<void> _confirmCancel(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text(
          'Tem certeza que deseja cancelar este agendamento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.error),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(appointmentsProvider.notifier).cancelAppointment(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento cancelado!')),
        );
      }
    }
  }
}
