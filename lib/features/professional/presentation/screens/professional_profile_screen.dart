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
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfessionalProfileScreen extends ConsumerStatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  ConsumerState<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState
    extends ConsumerState<ProfessionalProfileScreen> {
  bool _showCancelModal = false;
  final _cancelPasswordController = TextEditingController();
  bool _isCanceling = false;
  bool _isLoggingOut = false;
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _cancelPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final userDs = ref.read(userDatasourceProvider);
      final profile = await userDs.getProfile();
      ref.read(authProvider.notifier).updateUser(profile);
    } catch (_) {}
    if (mounted) setState(() => _isLoadingProfile = false);
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

  void _handleCancelAccount() {
    setState(() {
      _showCancelModal = true;
      _cancelPasswordController.clear();
    });
  }

  Future<void> _handleConfirmCancel() async {
    final password = _cancelPasswordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Digite sua senha para confirmar a exclusão')),
      );
      return;
    }
    setState(() => _isCanceling = true);
    try {
      final userDs = ref.read(userDatasourceProvider);
      await userDs.deleteAccount();
      if (mounted) {
        await ref.read(authProvider.notifier).signOut();
        context.go(RouteNames.login);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta excluída com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCanceling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('401') || e.toString().contains('403')
                  ? 'Senha incorreta ou não autorizado.'
                  : 'Erro ao excluir conta. Tente novamente.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _showCancelModal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildAvatarSection(user),
                    _buildInfoCard(user),
                    _buildAddressCard(user),
                    _buildActions(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _showCancelModal ? _buildCancelModal() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 48, AppSpacing.lg, AppSpacing.md),
      color: AppColors.secondary,
      child: const Text(
        'Meu Perfil',
        style: TextStyle(
            fontSize: AppTypography.xxl,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnPrimary),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAvatarSection(user) {
    final serviceTypeLabel = user?.serviceType != null
        ? Formatters.formatServiceName(user!.serviceType!)
        : null;
    final categoryLabel = user?.category != null
        ? Formatters.formatServiceName(user!.category!)
        : null;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        AppAvatar(
          imageUrl: user?.photo,
          name: user?.name,
          size: AvatarSize.xxlarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          user?.name ?? '—',
          style: TextStyle(
              fontSize: AppTypography.xl,
              fontWeight: AppTypography.bold,
              color: AppColors.text),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          user?.email ?? '—',
          style: TextStyle(
              fontSize: AppTypography.base, color: AppColors.textSecondary),
        ),
        if (serviceTypeLabel != null || categoryLabel != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (categoryLabel != null)
                AppBadge(
                  label: categoryLabel,
                  variant: BadgeVariant.neutral,
                  size: BadgeSize.small,
                ),
              if (serviceTypeLabel != null)
                AppBadge(
                  label: serviceTypeLabel,
                  variant: BadgeVariant.primary,
                  size: BadgeSize.small,
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildInfoCard(user) {
    return AppCard(
      variant: CardVariant.elevated,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações Pessoais',
            style: TextStyle(
                fontSize: AppTypography.lg,
                fontWeight: AppTypography.bold,
                color: AppColors.text),
          ),
          const SizedBox(height: AppSpacing.md),
          _infoRow('Nome', user?.name ?? '—'),
          _infoRow('E-mail', user?.email ?? '—'),
          _infoRow('Telefone', user?.phone ?? '—'),
          _infoRow(
              'Tipo de Conta', 'Profissional'),
          if (user?.category != null)
            _infoRow('Categoria',
                Formatters.formatServiceName(user!.category!)),
          if (user?.serviceType != null)
            _infoRow('Tipo de Serviço',
                Formatters.formatServiceName(user!.serviceType!)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: AppTypography.base, color: AppColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: AppTypography.base,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(user) {
    final addr = user?.address;

    return AppCard(
      variant: CardVariant.elevated,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Endereço',
            style: TextStyle(
                fontSize: AppTypography.lg,
                fontWeight: AppTypography.bold,
                color: AppColors.text),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoadingProfile)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: LoadingSpinner(),
            ))
          else if (addr != null &&
              (addr.street.isNotEmpty || addr.cep.isNotEmpty)) ...[
            if (addr.cep.isNotEmpty) _infoRow('CEP', _formatCep(addr.cep)),
            if (addr.street.isNotEmpty)
              _infoRow('Rua',
                  '${addr.street}${addr.number.isNotEmpty ? ', ${addr.number}' : ''}'),
            if (addr.complement != null && addr.complement!.isNotEmpty)
              _infoRow('Complemento', addr.complement!),
            if (addr.neighborhood.isNotEmpty)
              _infoRow('Bairro', addr.neighborhood),
            if (addr.city.isNotEmpty && addr.state.isNotEmpty)
              _infoRow('Cidade/Estado', '${addr.city}/${addr.state}'),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'Nenhum endereço cadastrado',
                  style: TextStyle(
                      fontSize: AppTypography.base,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatCep(String cep) {
    final d = cep.replaceAll(RegExp(r'\D'), '');
    if (d.length == 8) return '${d.substring(0, 5)}-${d.substring(5)}';
    return cep;
  }

  Widget _buildActions() {
    return Column(
      children: [
        AppButton(
          title: 'Editar Perfil',
          onPressed: () =>
              context.push('${RouteNames.professionalProfile}/edit'),
          variant: ButtonVariant.outline,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          title: 'Alterar Senha',
          onPressed: () =>
              context.push('${RouteNames.professionalProfile}/change-password'),
          variant: ButtonVariant.outline,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          title: 'Gerenciar Serviços',
          onPressed: () =>
              context.push('${RouteNames.professionalProfile}/services'),
          variant: ButtonVariant.outline,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          title: 'Horários de Atendimento',
          onPressed: () =>
              context.push('${RouteNames.professionalProfile}/business-hours'),
          variant: ButtonVariant.outline,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          title: _isLoggingOut ? 'Saindo...' : 'Sair',
          onPressed: () {
            _handleLogout();
          },
          disabled: _isLoggingOut,
          variant: ButtonVariant.outline,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          title: 'Excluir Conta',
          onPressed: _handleCancelAccount,
          variant: ButtonVariant.outline,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildCancelModal() {
    return Container(
      color: Colors.black54,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => setState(() => _showCancelModal = false),
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppBorderRadius.xl),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Excluir Conta',
                        style: TextStyle(
                            fontSize: AppTypography.xl,
                            fontWeight: AppTypography.bold,
                            color: AppColors.text),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: AppTypography.base,
                            color: AppColors.text),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Todos os seus dados serão permanentemente removidos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppInput(
                        label: 'Digite sua senha para confirmar',
                        controller: _cancelPasswordController,
                        hintText: 'Sua senha',
                        obscureText: true,
                        enabled: !_isCanceling,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              title: 'Não, manter conta',
                              onPressed: () {
                                setState(() {
                                  _showCancelModal = false;
                                  _cancelPasswordController.clear();
                                });
                              },
                              disabled: _isCanceling,
                              variant: ButtonVariant.outline,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              title: 'Sim, excluir conta',
                              onPressed: () {
                                _handleConfirmCancel();
                              },
                              loading: _isCanceling,
                              disabled: _isCanceling,
                              variant: ButtonVariant.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
