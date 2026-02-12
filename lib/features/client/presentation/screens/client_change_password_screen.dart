import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shared/data/datasources/user_remote_datasource.dart';

class ClientChangePasswordScreen extends ConsumerStatefulWidget {
  const ClientChangePasswordScreen({super.key});

  @override
  ConsumerState<ClientChangePasswordScreen> createState() =>
      _ClientChangePasswordScreenState();
}

class _ClientChangePasswordScreenState
    extends ConsumerState<ClientChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final current = _currentController.text.trim();
    final newP = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite sua senha atual')),
      );
      return;
    }
    if (newP.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite a nova senha')),
      );
      return;
    }
    if (!Validators.isValidPassword(newP)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('A nova senha deve ter no mínimo 8 caracteres')),
      );
      return;
    }
    if (newP != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userDs = ref.read(userDatasourceProvider);
      await userDs.changePassword(
        currentPassword: current,
        newPassword: newP,
        confirmPassword: confirm,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
        );
        _currentController.clear();
        _newController.clear();
        _confirmController.clear();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('401') || e.toString().contains('403')
                  ? 'Senha atual incorreta.'
                  : 'Erro ao alterar senha. Tente novamente.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Alterar Senha'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppInput(
              label: 'Senha Atual',
              controller: _currentController,
              hintText: 'Digite sua senha atual',
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              label: 'Nova Senha',
              controller: _newController,
              hintText: 'Mínimo 8 caracteres',
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              label: 'Confirmar Nova Senha',
              controller: _confirmController,
              hintText: 'Digite a senha novamente',
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              title: 'Alterar Senha',
              onPressed: () { _handleChangePassword(); },
              loading: _isLoading,
              disabled: _isLoading,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}
