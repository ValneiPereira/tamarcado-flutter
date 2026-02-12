import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/loading_spinner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../client/data/models/service_model.dart';
import '../../../client/data/datasources/professionals_remote_datasource.dart';

class ProfessionalServicesScreen extends ConsumerStatefulWidget {
  const ProfessionalServicesScreen({super.key});

  @override
  ConsumerState<ProfessionalServicesScreen> createState() =>
      _ProfessionalServicesScreenState();
}

class _ProfessionalServicesScreenState
    extends ConsumerState<ProfessionalServicesScreen> {
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final ds = ProfessionalsRemoteDatasource(ref.read(dioClientProvider).dio);
      final list = await ds.getMyServices();
      if (mounted) setState(() => _services = list);
    } catch (_) {
      if (mounted) setState(() => _services = []);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Gerenciar Serviços'),
        actions: [
          IconButton(
            onPressed: _showAddServiceDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingSpinner())
          : _services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off_outlined,
                          size: 64, color: AppColors.textLight),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Nenhum serviço cadastrado',
                        style: TextStyle(
                            fontSize: AppTypography.lg,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: 250,
                        child: AppButton(
                          title: 'Adicionar Primeiro Serviço',
                          onPressed: _showAddServiceDialog,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final s = _services[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        side: const BorderSide(color: AppColors.borderLight),
                      ),
                      child: ListTile(
                        title: Text(
                          s.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Formatters.formatCurrency(s.price),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                            const SizedBox(width: AppSpacing.sm),
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
                      ),
                    );
                  },
                ),
    );
  }
}

