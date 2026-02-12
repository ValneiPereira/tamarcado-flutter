import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/services_data.dart';
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

class _ServiceEntry {
  String name;
  double price;
  int duration;

  _ServiceEntry() : name = '', price = 0, duration = 30;

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'duration': duration,
      };

  bool get isValid => name.trim().isNotEmpty && price > 0;
}

class RegisterProfessionalScreen extends ConsumerStatefulWidget {
  const RegisterProfessionalScreen({super.key});

  @override
  ConsumerState<RegisterProfessionalScreen> createState() =>
      _RegisterProfessionalScreenState();
}

class _RegisterProfessionalScreenState
    extends ConsumerState<RegisterProfessionalScreen> {
  // Personal data
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Category
  ServiceCategory _selectedCategory = ServiceCategory.beleza;
  late ServiceType _selectedServiceType;

  // Services
  final List<_ServiceEntry> _services = [_ServiceEntry()];

  // Address
  AddressModel _address = const AddressModel(
    cep: '',
    street: '',
    number: '',
    neighborhood: '',
    city: '',
    state: '',
  );

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedServiceType = ServiceType.byCategory(_selectedCategory).first;
  }

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

  void _handleCategoryChange(ServiceCategory? category) {
    if (category == null) return;
    setState(() {
      _selectedCategory = category;
      _selectedServiceType = ServiceType.byCategory(category).first;
    });
  }

  void _addService() {
    setState(() => _services.add(_ServiceEntry()));
  }

  void _removeService(int index) {
    if (_services.length <= 1) return;
    setState(() => _services.removeAt(index));
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

    final validServices = _services.where((s) => s.isValid).toList();
    if (validServices.isEmpty) {
      _showError('Adicione pelo menos um serviço com nome e preço');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).registerProfessional(
            name: name,
            email: email,
            password: password,
            phone: Masks.unmask(phone),
            address: _address.toJson(),
            category: _selectedCategory.value,
            serviceType: _selectedServiceType.value,
            services: validServices.map((s) => s.toJson()).toList(),
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
    final serviceTypes = ServiceType.byCategory(_selectedCategory);

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
                'Cadastro Profissional',
                style: TextStyle(
                  fontSize: AppTypography.xxl,
                  fontWeight: AppTypography.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Preencha seus dados para oferecer seus serviços',
                style: TextStyle(
                  fontSize: AppTypography.base,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // === Personal Data ===
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

              // === Category ===
              _buildSectionHeader('Área de Atuação'),
              const SizedBox(height: AppSpacing.md),

              // Category dropdown
              _buildDropdownField(
                label: 'Categoria *',
                value: _selectedCategory,
                items: ServiceCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ))
                    .toList(),
                onChanged: _handleCategoryChange,
              ),
              const SizedBox(height: AppSpacing.md),

              // Service type dropdown
              _buildDropdownField(
                label: 'Tipo de Serviço *',
                value: _selectedServiceType,
                items: serviceTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label),
                        ))
                    .toList(),
                onChanged: (ServiceType? type) {
                  if (type != null) {
                    setState(() => _selectedServiceType = type);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // === Services ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('Serviços Oferecidos'),
                  TextButton.icon(
                    onPressed: _isLoading ? null : _addService,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              ..._services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;
                return _buildServiceCard(index, service);
              }),

              const SizedBox(height: AppSpacing.lg),

              // === Address ===
              _buildSectionHeader('Endereço de Atendimento'),
              const SizedBox(height: AppSpacing.md),

              AddressForm(
                address: _address,
                onChanged: (addr) => setState(() => _address = addr),
                cepDatasource: cepDatasource,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Submit
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppTypography.lg,
        fontWeight: AppTypography.semibold,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTypography.sm,
            fontWeight: AppTypography.medium,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: _isLoading ? null : onChanged,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: const TextStyle(
              fontSize: AppTypography.base,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(int index, _ServiceEntry service) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Serviço ${index + 1}',
                style: const TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.semibold,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_services.length > 1)
                IconButton(
                  onPressed: _isLoading ? null : () => _removeService(index),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.error,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppInput(
            label: 'Nome do Serviço *',
            hintText: 'Ex: Corte masculino',
            onChanged: (v) => service.name = v,
            enabled: !_isLoading,
          ),
          Row(
            children: [
              Expanded(
                child: AppInput(
                  label: 'Preço (R\$) *',
                  hintText: '50.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (v) =>
                      service.price = double.tryParse(v) ?? 0,
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppInput(
                  label: 'Duração (min)',
                  hintText: '30',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (v) =>
                      service.duration = int.tryParse(v) ?? 30,
                  enabled: !_isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
