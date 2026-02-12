import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ClientAddressesScreen extends StatelessWidget {
  const ClientAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Endereço'),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final user = ref.watch(authProvider).user;
          final addr = user?.address;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: addr != null &&
                    (addr.street.isNotEmpty || addr.cep.isNotEmpty)
                ? AppCard(
                    variant: CardVariant.elevated,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (addr.cep.isNotEmpty)
                          _infoRow('CEP', _formatCep(addr.cep)),
                        if (addr.street.isNotEmpty)
                          _infoRow('Endereço',
                              '${addr.street}, ${addr.number}'),
                        if (addr.complement != null &&
                            addr.complement!.isNotEmpty)
                          _infoRow('Complemento', addr.complement!),
                        if (addr.neighborhood.isNotEmpty)
                          _infoRow('Bairro', addr.neighborhood),
                        if (addr.city.isNotEmpty && addr.state.isNotEmpty)
                          _infoRow('Cidade', '${addr.city}/${addr.state}'),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      Icon(Icons.location_off_outlined,
                          size: 64, color: AppColors.textLight),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Nenhum endereço cadastrado',
                        style: TextStyle(
                            fontSize: AppTypography.lg,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Adicione um endereço para facilitar seus agendamentos',
                        style: TextStyle(
                            fontSize: AppTypography.base,
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        title: 'Editar perfil para adicionar',
                        onPressed: () =>
                            context.push('${RouteNames.clientProfile}/edit'),
                        variant: ButtonVariant.outline,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  String _formatCep(String cep) {
    final d = cep.replaceAll(RegExp(r'\D'), '');
    if (d.length == 8) return '${d.substring(0, 5)}-${d.substring(5)}';
    return cep;
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: AppTypography.base,
                color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
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
}
