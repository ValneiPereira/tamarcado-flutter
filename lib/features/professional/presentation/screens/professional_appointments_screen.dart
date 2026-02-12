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
import '../../../client/data/models/appointment_model.dart';
import '../../../client/presentation/providers/appointments_provider.dart';

enum _TabType { pending, confirmed, history }

class ProfessionalAppointmentsScreen extends ConsumerStatefulWidget {
  const ProfessionalAppointmentsScreen({super.key});

  @override
  ConsumerState<ProfessionalAppointmentsScreen> createState() =>
      _ProfessionalAppointmentsScreenState();
}

class _ProfessionalAppointmentsScreenState
    extends ConsumerState<ProfessionalAppointmentsScreen> {
  _TabType _activeTab = _TabType.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    String? status;
    if (_activeTab == _TabType.pending) status = 'PENDING';
    if (_activeTab == _TabType.confirmed) status = 'ACCEPTED';
    await ref
        .read(appointmentsProvider.notifier)
        .loadProfessionalAppointments(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentsProvider);

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
                  String? status;
                  if (_activeTab == _TabType.pending) status = 'PENDING';
                  if (_activeTab == _TabType.confirmed) status = 'ACCEPTED';
                  await ref
                      .read(appointmentsProvider.notifier)
                      .loadProfessionalAppointments(status: status);
                },
                child: _buildContent(state),
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
      color: AppColors.secondary,
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
          _TabChip(
            label: 'Pendentes',
            active: _activeTab == _TabType.pending,
            onTap: () {
              setState(() => _activeTab = _TabType.pending);
              ref
                  .read(appointmentsProvider.notifier)
                  .loadProfessionalAppointments(status: 'PENDING');
            },
          ),
          const SizedBox(width: AppSpacing.xs),
          _TabChip(
            label: 'Confirmados',
            active: _activeTab == _TabType.confirmed,
            onTap: () {
              setState(() => _activeTab = _TabType.confirmed);
              ref
                  .read(appointmentsProvider.notifier)
                  .loadProfessionalAppointments(status: 'ACCEPTED');
            },
          ),
          const SizedBox(width: AppSpacing.xs),
          _TabChip(
            label: 'Histórico',
            active: _activeTab == _TabType.history,
            onTap: () {
              setState(() => _activeTab = _TabType.history);
              ref
                  .read(appointmentsProvider.notifier)
                  .loadProfessionalAppointments();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state) {
    if (state.isLoading && state.appointments.isEmpty) {
      return const LoadingSpinner(
          fullScreen: true, text: 'Carregando agendamentos...');
    }

    final list = state.appointments.where((a) {
      if (_activeTab == _TabType.pending) return a.status == 'PENDING';
      if (_activeTab == _TabType.confirmed) {
        return a.status == 'ACCEPTED' || a.status == 'CONFIRMED';
      }
      return a.status == 'COMPLETED' || a.status == 'CANCELLED' || a.status == 'REJECTED';
    }).toList();

    if (list.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildAppointmentCard(list[index]),
    );
  }

  Widget _buildEmptyState() {
    String msg = 'Nenhum agendamento pendente';
    if (_activeTab == _TabType.confirmed) msg = 'Nenhum agendamento confirmado';
    if (_activeTab == _TabType.history) msg = 'Nenhum histórico';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 64, color: AppColors.textLight),
          const SizedBox(height: AppSpacing.md),
          Text(
            msg,
            style: TextStyle(
                fontSize: AppTypography.lg,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel apt) {
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
                variant: _badgeVariant(apt.status),
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
              AppAvatar(name: apt.clientName, size: AvatarSize.medium),
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
                    if (apt.clientPhone != null && apt.clientPhone!.isNotEmpty)
                      Text(
                        apt.clientPhone!,
                        style: TextStyle(
                            fontSize: AppTypography.xs,
                            color: AppColors.textLight),
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
                  child: AppButton(
                    title: 'Recusar',
                    onPressed: () {
                      _confirmReject(apt.id);
                    },
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    title: 'Aceitar',
                    onPressed: () {
                      _accept(apt.id);
                    },
                    variant: ButtonVariant.primary,
                    size: ButtonSize.small,
                  ),
                ),
              ],
            ),
          ],
          if (apt.status == 'ACCEPTED' || apt.status == 'CONFIRMED') ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              title: 'Concluir Serviço',
              onPressed: () {
                _confirmComplete(apt.id);
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }

  BadgeVariant _badgeVariant(String status) {
    switch (status) {
      case 'PENDING':
        return BadgeVariant.warning;
      case 'ACCEPTED':
      case 'CONFIRMED':
        return BadgeVariant.success;
      case 'COMPLETED':
        return BadgeVariant.primary;
      default:
        return BadgeVariant.error;
    }
  }

  Future<void> _accept(String id) async {
    await ref.read(appointmentsProvider.notifier).acceptAppointment(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento aceito!')),
      );
    }
  }

  Future<void> _confirmReject(String id) async {
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

  Future<void> _confirmComplete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Concluir Agendamento'),
        content: const Text('Confirmar que o serviço foi realizado?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Não')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sim, concluir')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(appointmentsProvider.notifier).completeAppointment(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento concluído!')),
        );
      }
    }
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: active ? AppColors.secondary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: FontWeight.w500,
                    color: active
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
