import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/masks.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../shared/data/models/address_model.dart';
import '../../../shared/data/datasources/cep_remote_datasource.dart';
import '../../../shared/presentation/widgets/address_form.dart';
import '../providers/auth_provider.dart';

class RegisterClientScreen extends ConsumerStatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  ConsumerState<RegisterClientScreen> createState() =>
      _RegisterClientScreenState();
}

class _RegisterClientScreenState extends ConsumerState<RegisterClientScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  AddressModel _address = const AddressModel(
    cep: '',
    street: '',
    number: '',
    neighborhood: '',
    city: '',
    state: '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePhoneChange(String value) {
    final masked = Masks.maskPhone(value);
    _phoneController.text = masked;
    _phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: masked.length),
    );
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showError('Por favor, insira seu nome');
      return;
    }
    if (email.isEmpty) {
      _showError('Por favor, insira seu e-mail');
      return;
    }
    if (password.isEmpty || password.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres');
      return;
    }
    if (phone.isEmpty) {
      _showError('Por favor, insira seu telefone');
      return;
    }
    if (_address.cep.isEmpty ||
        _address.street.isEmpty ||
        _address.number.isEmpty ||
        _address.city.isEmpty) {
      _showError('Por favor, preencha o endereço completo');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).registerClient(
            name: name,
            email: email,
            password: password,
            phone: Masks.unmask(phone),
            address: _address.toJson(),
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
    if (msg.contains('409')) return 'Este email já está em uso';
    return 'Erro ao criar conta. Tente novamente.';
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
    final dioClient = ref.read(dioClientProvider);
    final cepDatasource = CepRemoteDatasource(dioClient.dio);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Voltar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              const Text(
                'Cadastro de Cliente',
                style: TextStyle(
                  fontSize: AppTypography.xxl,
                  fontWeight: AppTypography.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Preencha seus dados para criar sua conta',
                style: TextStyle(
                  fontSize: AppTypography.base,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Personal data section
              _buildSectionHeader('Dados Pessoais'),
              const SizedBox(height: AppSpacing.md),

              AppInput(
                label: 'Nome Completo *',
                controller: _nameController,
                hintText: 'Seu nome completo',
                leftIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
              ),
              AppInput(
                label: 'E-mail *',
                controller: _emailController,
                hintText: 'seu@email.com',
                leftIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
              ),
              AppInput(
                label: 'Senha *',
                controller: _passwordController,
                hintText: 'Mínimo 6 caracteres',
                leftIcon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
              ),
              AppInput(
                label: 'Telefone *',
                controller: _phoneController,
                hintText: '(11) 99999-9999',
                leftIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                onChanged: _handlePhoneChange,
                maxLength: 15,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Address section
              _buildSectionHeader('Endereço'),
              const SizedBox(height: AppSpacing.md),

              AddressForm(
                address: _address,
                onChanged: (addr) => setState(() => _address = addr),
                cepDatasource: cepDatasource,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Submit button
              AppButton(
                title: 'Criar Conta',
                onPressed: _handleRegister,
                loading: _isLoading,
                size: ButtonSize.large,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppTypography.lg,
            fontWeight: AppTypography.semibold,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
