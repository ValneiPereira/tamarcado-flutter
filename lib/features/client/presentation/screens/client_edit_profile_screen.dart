import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/masks.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shared/data/datasources/cep_remote_datasource.dart';
import '../../../shared/data/datasources/cloudinary_datasource.dart';
import '../../../shared/data/datasources/user_remote_datasource.dart';
import '../../../shared/data/models/address_model.dart';
import '../../../shared/presentation/widgets/address_form.dart';

class ClientEditProfileScreen extends ConsumerStatefulWidget {
  const ClientEditProfileScreen({super.key});

  @override
  ConsumerState<ClientEditProfileScreen> createState() =>
      _ClientEditProfileScreenState();
}

class _ClientEditProfileScreenState extends ConsumerState<ClientEditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  late AddressModel _address;
  bool _loadingCep = false;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _localPhotoUrl;

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
      final cloudinary = ref.read(cloudinaryDatasourceProvider);
      final userId = ref.read(authProvider).user?.id.toString() ?? 'user';
      final photoUrl = await cloudinary.uploadImage(xFile, userId);
      if (photoUrl == null || !mounted) return;

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
            content: Text('Erro ao enviar foto: ${e.toString()}'),
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
        address: _address.toJson()
          ..['cep'] = Masks.unmask(_address.cep),
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
            content: Text('Erro ao atualizar perfil: ${e.toString()}'),
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
    final user = ref.watch(authProvider).user;
    final photoUrl = _localPhotoUrl ?? user?.photo;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
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
                        child: LoadingSpinner(),
                      ),
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.surface, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.textOnPrimary,
                        size: 22,
                      ),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Endereço',
                style: TextStyle(
                    fontSize: AppTypography.lg,
                    fontWeight: AppTypography.bold,
                    color: AppColors.text),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AddressForm(
              address: _address,
              onChanged: (a) => setState(() => _address = a),
              cepDatasource: ref.read(cepDatasourceProvider),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              title: 'Salvar Alterações',
              onPressed: () { _handleSave(); },
              loading: _isLoading,
              disabled: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

final cepDatasourceProvider = Provider<CepRemoteDatasource>((ref) {
  return CepRemoteDatasource(ref.read(dioClientProvider).dio);
});

final cloudinaryDatasourceProvider = Provider<CloudinaryDatasource>((ref) {
  return CloudinaryDatasource();
});
