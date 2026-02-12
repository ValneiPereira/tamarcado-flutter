import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../../routing/route_names.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showError('Por favor, insira seu e-mail');
      return;
    }
    if (password.isEmpty) {
      _showError('Por favor, insira sua senha');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).login(
            email: email,
            password: password,
          );
    } catch (e) {
      if (mounted) {
        _showError(_extractError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _extractError(Object e) {
    final msg = e.toString();
    if (msg.contains('401')) return 'Email ou senha inválidos';
    if (msg.contains('404')) return 'Usuário não encontrado';
    return 'Erro ao fazer login. Tente novamente.';
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
    final authState = ref.watch(authProvider);

    if (authState.isInitializing) {
      return const LoadingSpinner(fullScreen: true);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xxl,
                  horizontal: AppSpacing.lg,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppBorderRadius.xxl),
                    bottomRight: Radius.circular(AppBorderRadius.xxl),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      size: 64,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Tá Marcado!',
                      style: TextStyle(
                        fontSize: AppTypography.xxxl,
                        fontWeight: AppTypography.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Agende serviços com facilidade',
                      style: TextStyle(
                        fontSize: AppTypography.base,
                        color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppInput(
                        label: 'E-mail',
                        controller: _emailController,
                        hintText: 'seu@email.com',
                        leftIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () =>
                            _passwordFocusNode.requestFocus(),
                        enabled: !_isLoading,
                      ),
                      AppInput(
                        label: 'Senha',
                        controller: _passwordController,
                        hintText: 'Sua senha',
                        leftIcon: Icons.lock_outline,
                        obscureText: true,
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _handleLogin,
                        enabled: !_isLoading,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(RouteNames.forgotPassword),
                          child: const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: AppTypography.sm,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        title: 'Entrar',
                        onPressed: _handleLogin,
                        loading: _isLoading,
                        size: ButtonSize.large,
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tem conta? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppTypography.base,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteNames.chooseType),
                    child: const Text(
                      'Criar conta',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppTypography.base,
                        fontWeight: AppTypography.semibold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
