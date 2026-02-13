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
import '../../../../core/widgets/star_rating.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/reviews_remote_datasource.dart';
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
              onPressed: () => _showReviewSheet(apt),
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

  void _showReviewSheet(AppointmentModel apt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xl)),
      ),
      builder: (_) => _ReviewBottomSheet(
        appointmentId: apt.id,
        professionalName: apt.professionalName ?? 'Profissional',
        serviceName: apt.service?.name ?? '',
        dio: ref.read(dioClientProvider).dio,
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avaliação enviada com sucesso!')),
            );
            _load();
          }
        },
      ),
    );
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

class _ReviewBottomSheet extends StatefulWidget {
  final String appointmentId;
  final String professionalName;
  final String serviceName;
  final dynamic dio;
  final VoidCallback onSuccess;

  const _ReviewBottomSheet({
    required this.appointmentId,
    required this.professionalName,
    required this.serviceName,
    required this.dio,
    required this.onSuccess,
  });

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma nota')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final ds = ReviewsRemoteDatasource(widget.dio);
      final comment = _commentController.text.trim();
      await ds.createReview(
        appointmentId: widget.appointmentId,
        rating: _rating,
        comment: comment.isEmpty ? null : comment,
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Erro ao enviar avaliação';
        if (e.toString().contains('already') ||
            e.toString().contains('já foi')) {
          msg = 'Este agendamento já foi avaliado';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Avaliar Atendimento',
              style: TextStyle(
                fontSize: AppTypography.xl,
                fontWeight: AppTypography.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${widget.professionalName} - ${widget.serviceName}',
              style: TextStyle(
                fontSize: AppTypography.base,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: StarRating(
                rating: _rating.toDouble(),
                size: 40,
                showValue: false,
                interactive: true,
                onRatingChange: (val) => setState(() => _rating = val),
              ),
            ),
            if (_rating > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    _ratingLabel(_rating),
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Comentário (opcional)',
              style: TextStyle(
                fontSize: AppTypography.base,
                fontWeight: AppTypography.semibold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Conte como foi sua experiência...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              title: 'Enviar Avaliação',
              onPressed: () {
                _submit();
              },
              loading: _isSending,
              disabled: _isSending,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Regular';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }
}
