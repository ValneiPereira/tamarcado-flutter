import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../client/data/models/service_model.dart';
import '../../../client/data/datasources/professionals_remote_datasource.dart';

class ProfessionalProfileScreen extends ConsumerStatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  ConsumerState<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState
    extends ConsumerState<ProfessionalProfileScreen> {
  bool _isLoggingOut = false;
  List<ServiceModel> _services = [];
  bool _loadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final ds = ProfessionalsRemoteDatasource(dio);
      final list = await ds.getMyServices();
      if (mounted) setState(() => _services = list);
    } catch (_) {
      if (mounted) setState(() => _services = []);
    } finally {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  Future<void> _handleLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authProvider.notifier).signOut();
      if (mounted) context.go(RouteNames.login);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao fazer logout. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final serviceTypeLabel = user?.serviceType != null
        ? Formatters.formatServiceName(user!.serviceType!)
        : '—';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildHeader(),
              AppCard(
                variant: CardVariant.elevated,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    AppAvatar(
                      imageUrl: user?.photo,
                      name: user?.name,
                      size: AvatarSize.xxlarge,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? '—',
                            style: TextStyle(
                                fontSize: AppTypography.xl,
                                fontWeight: AppTypography.bold,
                                color: AppColors.text),
                          ),
                          Text(
                            user?.email ?? '—',
                            style: TextStyle(
                                fontSize: AppTypography.sm,
                                color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppBadge(
                            label: serviceTypeLabel,
                            variant: BadgeVariant.primary,
                            size: BadgeSize.small,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildServicesSection(),
              _buildMenuSection(),
              AppButton(
                title: _isLoggingOut ? 'Saindo...' : 'Sair da Conta',
                onPressed: () => _handleLogout(),
                disabled: _isLoggingOut,
                variant: ButtonVariant.outline,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Versão 1.0.0',
                style: TextStyle(
                    fontSize: AppTypography.sm, color: AppColors.textLight),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
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
        'Perfil',
        style: TextStyle(
            fontSize: AppTypography.xxl,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meus Serviços',
              style: TextStyle(
                  fontSize: AppTypography.lg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Edite o perfil para gerenciar serviços')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_loadingServices)
          const Center(child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: CircularProgressIndicator(),
          ))
        else if (_services.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Nenhum serviço cadastrado',
              style: TextStyle(
                  fontSize: AppTypography.base,
                  color: AppColors.textSecondary),
            ),
          )
        else
          ..._services.map((s) {
            return AppCard(
              variant: CardVariant.outlined,
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                children: [
                  Expanded(
                    child: Text(s.name,
                        style: const TextStyle(
                            fontSize: AppTypography.base,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text)),
                  ),
                  Text(
                    Formatters.formatCurrency(s.price),
                    style: const TextStyle(
                        fontSize: AppTypography.base,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildMenuSection() {
    final items = [
      _MenuItem(
          icon: Icons.person_outline,
          title: 'Editar Perfil',
          onTap: () {
            context.push('${RouteNames.professionalProfile}/edit');
          }),
      _MenuItem(
          icon: Icons.lock_outline,
          title: 'Alterar Senha',
          onTap: () {
            context.push('${RouteNames.professionalProfile}/change-password');
          }),
      _MenuItem(
          icon: Icons.work_outline,
          title: 'Gerenciar Serviços',
          onTap: () {
            context.push('${RouteNames.professionalProfile}/edit');
          }),
      _MenuItem(
          icon: Icons.schedule,
          title: 'Horários de Atendimento',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento')));
          }),
      _MenuItem(
          icon: Icons.location_on_outlined,
          title: 'Endereço de Atendimento',
          onTap: () {
            context.push('${RouteNames.professionalProfile}/address');
          }),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: items[i].onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(items[i].icon,
                        size: 24, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: Text(
                            items[i].title,
                            style: const TextStyle(
                                fontSize: AppTypography.base,
                                color: AppColors.text))),
                    Icon(Icons.chevron_right,
                        size: 20, color: AppColors.textLight),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem(
      {required this.icon, required this.title, required this.onTap});
}
