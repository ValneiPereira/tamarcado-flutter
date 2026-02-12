import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/masks.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../client/data/models/service_model.dart';
import '../../../shared/data/datasources/cep_remote_datasource.dart';
import '../../../shared/data/datasources/cloudinary_datasource.dart';
import '../../../shared/data/datasources/user_remote_datasource.dart';
import '../../../shared/data/models/address_model.dart';
import '../../../shared/presentation/widgets/address_form.dart';
import '../../../client/data/datasources/professionals_remote_datasource.dart';

class ProfessionalEditProfileScreen extends ConsumerStatefulWidget {
  const ProfessionalEditProfileScreen({super.key});

  @override
  ConsumerState<ProfessionalEditProfileScreen> createState() =>
      _ProfessionalEditProfileScreenState();
}

class _ProfessionalEditProfileScreenState
    extends ConsumerState<ProfessionalEditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  late AddressModel _address;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _localPhotoUrl;
  List<ServiceModel> _services = [];
  bool _loadingServices = true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    _emailController.text = user?.email ?? '';
    final addr = user?.address;
    _address = addr != null
        ? AddressModel(
            cep: addr.cep,
            street: addr.street,
            number: addr.number,
            complement: addr.complement,
            neighborhood: addr.neighborhood,
            city: addr.city,
            state: addr.state,
            latitude: addr.latitude,
            longitude: addr.longitude,
          )
        : const AddressModel(
            cep: '',
            street: '',
            number: '',
            neighborhood: '',
            city: '',
            state: '',
          );
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final ds = ProfessionalsRemoteDatasource(ref.read(dioClientProvider).dio);
      final list = await ds.getMyServices();
      if (mounted) setState(() => _services = list);
    } catch (_) {
      if (mounted) setState(() => _services = []);
    } finally {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (xFile == null || !mounted) return;

    setState(() => _isUploading = true);
    try {
      final cloudinary = CloudinaryDatasource();
      final userId = ref.read(authProvider).user?.id.toString() ?? 'user';
      final photoUrl = await cloudinary.uploadImage(xFile, userId);

      final userDs = ref.read(userDatasourceProvider);
      final updated = await userDs.updatePhoto(photoUrl);
      ref.read(authProvider.notifier).updateUser(updated);
      if (mounted) setState(() => _localPhotoUrl = photoUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar foto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome é obrigatório')),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefone é obrigatório')),
      );
      return;
    }
    if (_address.cep.isEmpty ||
        _address.street.isEmpty ||
        _address.number.isEmpty ||
        _address.neighborhood.isEmpty ||
        _address.city.isEmpty ||
        _address.state.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preencha todos os campos obrigatórios do endereço')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userDs = ref.read(userDatasourceProvider);
      final updated = await userDs.updateProfile(
        name: name,
        email: _emailController.text.trim(),
        phone: phone,
        address: _address.toJson()..['cep'] = Masks.unmask(_address.cep),
      );
      ref.read(authProvider.notifier).updateUser(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Serviço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppInput(
              label: 'Nome',
              controller: nameController,
              hintText: 'Ex: Corte de cabelo',
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              label: 'Preço (R\$)',
              controller: priceController,
              hintText: '0,00',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final priceStr = priceController.text.replaceAll(',', '.');
              final price = double.tryParse(priceStr) ?? 0;
              if (name.isEmpty) return;
              Navigator.of(ctx).pop();
              try {
                final ds = ProfessionalsRemoteDatasource(
                    ref.read(dioClientProvider).dio);
                await ds.createService(name: name, price: price);
                await _loadServices();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Serviço adicionado!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Erro: $e'),
                        backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(ServiceModel service) {
    final nameController = TextEditingController(text: service.name);
    final priceController = TextEditingController(text: service.price.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Serviço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppInput(
              label: 'Nome',
              controller: nameController,
              hintText: 'Nome do serviço',
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              label: 'Preço (R\$)',
              controller: priceController,
              hintText: '0,00',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final priceStr = priceController.text.replaceAll(',', '.');
              final price = double.tryParse(priceStr) ?? 0;
              if (name.isEmpty) return;
              Navigator.of(ctx).pop();
              try {
                final ds = ProfessionalsRemoteDatasource(
                    ref.read(dioClientProvider).dio);
                await ds.updateService(
                    serviceId: service.id, name: name, price: price);
                await _loadServices();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Serviço atualizado!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Erro: $e'),
                        backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(ServiceModel service) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: Text(
            'Excluir "${service.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Não')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sim, excluir'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final ds =
          ProfessionalsRemoteDatasource(ref.read(dioClientProvider).dio);
      await ds.deleteService(service.id);
      await _loadServices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço excluído')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final photoUrl = _localPhotoUrl ?? user?.photo;
    final cepDs = CepRemoteDatasource(ref.read(dioClientProvider).dio);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _handleChangePhoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  AppAvatar(
                    imageUrl: photoUrl,
                    name: user?.name,
                    size: AvatarSize.xxlarge,
                  ),
                  if (_isUploading)
                    const Positioned(
                        right: 0,
                        bottom: 0,
                        child: SizedBox(
                            width: 40,
                            height: 40,
                            child: LoadingSpinner()))
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.surface, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: AppColors.textOnPrimary, size: 22),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Toque para alterar a foto',
              style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppInput(
              label: 'Nome',
              controller: _nameController,
              hintText: 'Seu nome completo',
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              label: 'Email',
              controller: _emailController,
              readOnly: true,
              hintText: 'Email (não pode ser alterado)',
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              label: 'Telefone',
              controller: _phoneController,
              hintText: '(00) 00000-0000',
              keyboardType: TextInputType.phone,
              inputFormatters: [Masks.phone()],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Endereço',
              style: TextStyle(
                  fontSize: AppTypography.lg,
                  fontWeight: AppTypography.bold,
                  color: AppColors.text),
            ),
            const SizedBox(height: AppSpacing.md),
            AddressForm(
              address: _address,
              onChanged: (a) => setState(() => _address = a),
              cepDatasource: cepDs,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meus Serviços',
                  style: TextStyle(
                      fontSize: AppTypography.lg,
                      fontWeight: AppTypography.bold,
                      color: AppColors.text),
                ),
                TextButton.icon(
                  onPressed: _showAddServiceDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_loadingServices)
              const Center(child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CircularProgressIndicator(),
              ))
            else
              ..._services.map((s) => ListTile(
                    title: Text(s.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Formatters.formatCurrency(s.price),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _showEditServiceDialog(s),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 20, color: AppColors.error),
                          onPressed: () => _deleteService(s),
                        ),
                      ],
                    ),
                  )),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              title: 'Salvar Alterações',
              onPressed: () {
                _handleSave();
              },
              loading: _isLoading,
              disabled: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
