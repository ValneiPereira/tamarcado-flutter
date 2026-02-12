import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Por favor, insira seu e-mail');
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Por favor, insira um e-mail válido');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final datasource = ref.read(authDatasourceProvider);
      await datasource.forgotPassword(email);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Link enviado!'),
            content: const Text(
              'Verifique seu e-mail para redefinir sua senha.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        if (msg.contains('404')) {
          _showError('E-mail não encontrado');
        } else {
          _showError('Erro ao enviar link de recuperação. Tente novamente.');
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
                  icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
                ),
                const Text(
                  'Esqueci a Senha',
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
                    Icons.lock_reset,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Digite seu e-mail e enviaremos um link para você redefinir sua senha.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTypography.base,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppInput(
                    label: 'E-mail',
                    controller: _emailController,
                    hintText: 'seu@email.com',
                    leftIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _handleSendLink,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    title: 'Enviar link',
                    onPressed: _handleSendLink,
                    loading: _isLoading,
                    size: ButtonSize.large,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Voltar para login',
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
