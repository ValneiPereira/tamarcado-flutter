import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/business_hours_remote_datasource.dart';
import '../../data/models/business_hours_model.dart';

final businessHoursDatasourceProvider =
    Provider<BusinessHoursRemoteDatasource>((ref) {
  return BusinessHoursRemoteDatasource(ref.read(dioClientProvider).dio);
});

class ProfessionalBusinessHoursScreen extends ConsumerStatefulWidget {
  const ProfessionalBusinessHoursScreen({super.key});

  @override
  ConsumerState<ProfessionalBusinessHoursScreen> createState() =>
      _ProfessionalBusinessHoursScreenState();
}

class _ProfessionalBusinessHoursScreenState
    extends ConsumerState<ProfessionalBusinessHoursScreen> {
  List<BusinessHoursModel> _hours = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBusinessHours();
  }

  Future<void> _loadBusinessHours() async {
    setState(() => _isLoading = true);
    try {
      final ds = ref.read(businessHoursDatasourceProvider);
      final hours = await ds.getBusinessHours();
      if (hours.isEmpty) {
        _hours = BusinessHoursModel.defaultWeek();
      } else {
        // Garantir que temos todos os 7 dias
        final Map<int, BusinessHoursModel> byDay = {
          for (final h in hours) h.dayOfWeek: h
        };
        _hours = List.generate(
          7,
          (i) =>
              byDay[i] ??
              BusinessHoursModel(
                dayOfWeek: i,
                startTime: '08:00',
                endTime: '18:00',
                active: false,
              ),
        );
      }
    } catch (e) {
      _hours = BusinessHoursModel.defaultWeek();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final ds = ref.read(businessHoursDatasourceProvider);
      await ds.updateBusinessHours(_hours);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Horários salvos com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar horários: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickTime(int dayIndex, bool isStart) async {
    final current = isStart
        ? _hours[dayIndex].startTime
        : _hours[dayIndex].endTime;
    final parts = current.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _hours[dayIndex] = _hours[dayIndex].copyWith(
          startTime: isStart ? formatted : null,
          endTime: isStart ? null : formatted,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Horários de Atendimento'),
      ),
      body: _isLoading
          ? const Center(child: LoadingSpinner())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Defina seus horários de atendimento para cada dia da semana.',
                    style: TextStyle(
                      fontSize: AppTypography.base,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ..._hours.asMap().entries.map((entry) {
                    final index = entry.key;
                    final hour = entry.value;
                    return _buildDayCard(index, hour);
                  }),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    title: 'Salvar Horários',
                    onPressed: () {
                      _handleSave();
                    },
                    loading: _isSaving,
                    disabled: _isSaving,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  Widget _buildDayCard(int index, BusinessHoursModel hour) {
    return AppCard(
      variant: CardVariant.elevated,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                BusinessHoursModel.dayName(hour.dayOfWeek),
                style: TextStyle(
                  fontSize: AppTypography.base,
                  fontWeight: AppTypography.semibold,
                  color: hour.active ? AppColors.text : AppColors.textLight,
                ),
              ),
              Switch(
                value: hour.active,
                onChanged: (val) {
                  setState(() {
                    _hours[index] = _hours[index].copyWith(active: val);
                  });
                },
                activeTrackColor: AppColors.secondary.withValues(alpha: 0.5),
                activeThumbColor: AppColors.secondary,
              ),
            ],
          ),
          if (hour.active) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Início',
                    value: hour.startTime,
                    onTap: () => _pickTime(index, true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildTimePicker(
                    label: 'Fim',
                    value: hour.endTime,
                    onTap: () => _pickTime(index, false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppTypography.lg,
                    fontWeight: AppTypography.semibold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            Icon(Icons.access_time, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
