import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../professional/data/models/business_hours_model.dart';
import '../../data/datasources/appointments_remote_datasource.dart';
import '../../data/models/professional_model.dart';
import '../../data/models/service_model.dart';
import '../providers/professionals_provider.dart';
import '../../../../routing/route_names.dart';

class ProfessionalDetailScreen extends ConsumerStatefulWidget {
  final String professionalId;
  const ProfessionalDetailScreen({super.key, required this.professionalId});

  @override
  ConsumerState<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState
    extends ConsumerState<ProfessionalDetailScreen> {
  ProfessionalModel? _professional;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfessional();
  }

  Future<void> _loadProfessional() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final ds = ref.read(professionalsDatasourceProvider);
      final prof = await ds.getProfessionalById(widget.professionalId);
      if (mounted) {
        setState(() {
          _professional = prof;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar profissional';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingSpinner(fullScreen: true));
    }

    if (_error != null || _professional == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ops!')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Profissional não encontrado.'),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: 200,
                child: AppButton(
                  title: 'Tentar novamente',
                  onPressed: _loadProfessional,
                  variant: ButtonVariant.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final prof = _professional!;

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
                  _buildSectionTitle('Sobre'),
                  const SizedBox(height: AppSpacing.md),
                  _buildAboutSection(prof),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('Avaliações'),
                  const SizedBox(height: AppSpacing.md),
                  _buildReviewsSection(prof),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(prof),
    );
  }

  Widget _buildSliverAppBar(ProfessionalModel prof) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (prof.photo != null)
              Image.network(prof.photo!, fit: BoxFit.cover)
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

  Widget _buildHeaderInfo(ProfessionalModel prof) {
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
            Icon(Icons.star_border, size: 16, color: AppColors.textLight),
            const SizedBox(width: 4),
            Text(
              '${prof.totalRatings} avaliações',
              style: TextStyle(color: AppColors.textSecondary),
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

  Widget _buildAboutSection(ProfessionalModel prof) {
    final text = (prof.description != null && prof.description!.isNotEmpty)
        ? prof.description!
        : 'Profissional de ${Formatters.formatServiceName(prof.serviceType)} na categoria ${Formatters.formatServiceName(prof.category)}.';
    return Text(
      text,
      style: TextStyle(
        fontSize: AppTypography.base,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildReviewsSection(ProfessionalModel prof) {
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
      children: prof.reviews
          .map<Widget>((review) => _buildReviewItem(review))
          .toList(),
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
              AppAvatar(
                  name: review.clientName ?? 'Cliente',
                  size: AvatarSize.small),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName ?? 'Cliente',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    StarRating(rating: review.rating.toDouble(), size: 12),
                  ],
                ),
              ),
              if (review.createdAt != null)
                Text(
                  Formatters.dateToString(review.createdAt),
                  style: TextStyle(
                      fontSize: AppTypography.xs, color: AppColors.textLight),
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

  Widget _buildBottomAction(ProfessionalModel prof) {
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
          onPressed: () => _showBookingSheet(prof),
          size: ButtonSize.large,
        ),
      ),
    );
  }

  void _showBookingSheet(ProfessionalModel prof) {
    if (prof.services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Este profissional não possui serviços cadastrados')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xl)),
      ),
      builder: (_) => _BookingSheet(
        professional: prof,
        dio: ref.read(dioClientProvider).dio,
        onBook: (serviceId, date, time, notes) async {
          final ds = AppointmentsRemoteDatasource(
              ref.read(dioClientProvider).dio);
          await ds.createAppointment(
            professionalId: prof.id,
            serviceId: serviceId,
            date: date,
            time: time,
            notes: notes,
          );
        },
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Agendamento solicitado com sucesso!')),
            );
            context.go(RouteNames.clientAppointments);
          }
        },
      ),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  final ProfessionalModel professional;
  final dynamic dio;
  final Future<void> Function(
      String serviceId, String date, String time, String? notes) onBook;
  final VoidCallback onSuccess;

  const _BookingSheet({
    required this.professional,
    required this.dio,
    required this.onBook,
    required this.onSuccess,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  ServiceModel? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final _notesController = TextEditingController();
  bool _isBooking = false;
  List<BusinessHoursModel> _businessHours = [];
  bool _loadingHours = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessHours();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessHours() async {
    try {
      final response = await widget.dio
          .get('/professionals/${widget.professional.id}/business-hours');
      final data = response.data['data'] as List<dynamic>;
      if (mounted) {
        setState(() {
          _businessHours = data
              .map(
                  (e) => BusinessHoursModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _loadingHours = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingHours = false);
      }
    }
  }

  /// Converts day of week: DateTime (1=Monday..7=Sunday) to our model (0=Monday..6=Sunday)
  int _dartWeekdayToModel(int dartWeekday) => dartWeekday - 1;

  /// Get available time slots for a given date based on business hours
  List<String> _getTimeSlotsForDate(DateTime date) {
    final dayOfWeek = _dartWeekdayToModel(date.weekday);
    final hours =
        _businessHours.where((h) => h.dayOfWeek == dayOfWeek && h.active);

    if (hours.isEmpty) return [];

    final bh = hours.first;
    final slots = <String>[];

    final startParts = bh.startTime.split(':');
    final endParts = bh.endTime.split(':');
    var currentHour = int.parse(startParts[0]);
    var currentMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    // Generate slots every 30 minutes
    while (currentHour < endHour ||
        (currentHour == endHour && currentMinute < endMinute)) {
      slots.add(
          '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}');
      currentMinute += 30;
      if (currentMinute >= 60) {
        currentMinute -= 60;
        currentHour++;
      }
    }

    return slots;
  }

  /// Check if a date has available business hours
  bool _isDateAvailable(DateTime date) {
    final dayOfWeek = _dartWeekdayToModel(date.weekday);
    return _businessHours.any((h) => h.dayOfWeek == dayOfWeek && h.active);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      selectableDayPredicate:
          _businessHours.isNotEmpty ? _isDateAvailable : null,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
      });
    }
  }

  Future<void> _handleBook() async {
    if (_selectedService == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione serviço, data e horário')),
      );
      return;
    }

    setState(() => _isBooking = true);
    final dateStr =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    try {
      await widget.onBook(
        _selectedService!.id,
        dateStr,
        _selectedTimeSlot!,
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.professional.services;
    final timeSlots = _selectedDate != null
        ? _getTimeSlotsForDate(_selectedDate!)
        : <String>[];

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
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
                'Agendar Horário',
                style: TextStyle(
                  fontSize: AppTypography.xl,
                  fontWeight: AppTypography.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Service selection
              const Text(
                'Selecione o serviço',
                style: TextStyle(
                  fontSize: AppTypography.base,
                  fontWeight: AppTypography.semibold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...services.map((service) => RadioListTile<ServiceModel>(
                    title: Text(service.name),
                    subtitle: Text(Formatters.formatCurrency(service.price)),
                    value: service,
                    groupValue: _selectedService,
                    activeColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _selectedService = val),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )),
              const SizedBox(height: AppSpacing.md),

              // Date selection
              const Text(
                'Data',
                style: TextStyle(
                  fontSize: AppTypography.base,
                  fontWeight: AppTypography.semibold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? Formatters.formatDateShort(_selectedDate!)
                            : 'Selecione a data',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? AppColors.text
                              : AppColors.textLight,
                        ),
                      ),
                      Icon(Icons.calendar_today,
                          size: 20, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Time slots
              const Text(
                'Horário',
                style: TextStyle(
                  fontSize: AppTypography.base,
                  fontWeight: AppTypography.semibold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_loadingHours)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_selectedDate == null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Selecione uma data primeiro',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                )
              else if (timeSlots.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Nenhum horário disponível nesta data',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: timeSlots.map((slot) {
                    final isSelected = _selectedTimeSlot == slot;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(
                            () => _selectedTimeSlot = selected ? slot : null);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.text,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.md),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: AppSpacing.md),

              // Notes
              const Text(
                'Observações (opcional)',
                style: TextStyle(
                  fontSize: AppTypography.base,
                  fontWeight: AppTypography.semibold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Alguma observação para o profissional?',
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
                title: 'Confirmar Agendamento',
                onPressed: () {
                  _handleBook();
                },
                loading: _isBooking,
                disabled: _isBooking,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
