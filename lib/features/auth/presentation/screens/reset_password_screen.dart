import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../providers/auth_provider.dart';
import '../../../../routing/route_names.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (code.isEmpty || code.length != 6) {
      _showError('Digite o código de 6 dígitos recebido por e-mail');
      return;
    }

    if (password.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    if (password != confirm) {
      _showError('As senhas não coincidem');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final datasource = ref.read(authDatasourceProvider);
      await datasource.resetPassword(code: code, newPassword: password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha redefinida com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(RouteNames.login);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        if (msg.contains('400') || msg.contains('inválido') || msg.contains('expirado')) {
          _showError('Código inválido ou expirado. Solicite um novo código.');
        } else {
          _showError('Erro ao redefinir senha. Tente novamente.');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textOnPrimary),
                ),
                const Text(
                  'Redefinir Senha',
                  style: TextStyle(
                    fontSize: AppTypography.xl,
                    fontWeight: AppTypography.semibold,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  const Icon(
                    Icons.lock_open,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Digite o código enviado para\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppTypography.base,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppInput(
                    label: 'Código de 6 dígitos',
                    controller: _codeController,
                    hintText: '000000',
                    leftIcon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: 'Nova senha',
                    controller: _passwordController,
                    hintText: 'Mínimo 6 caracteres',
                    leftIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    rightIcon: _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onRightIconPress: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: 'Confirmar nova senha',
                    controller: _confirmPasswordController,
                    hintText: 'Repita a nova senha',
                    leftIcon: Icons.lock_outline,
                    obscureText: _obscureConfirm,
                    rightIcon: _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onRightIconPress: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _handleResetPassword,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    title: 'Redefinir Senha',
                    onPressed: _handleResetPassword,
                    loading: _isLoading,
                    size: ButtonSize.large,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Voltar',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppTypography.base,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
