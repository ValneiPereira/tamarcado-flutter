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

class ProfessionalAddressScreen extends StatelessWidget {
  const ProfessionalAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Endereço de Atendimento'),
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
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 24, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Endereço Principal',
                              style: TextStyle(
                                  fontSize: AppTypography.lg,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '${addr.street}, ${addr.number}${addr.complement != null && addr.complement!.isNotEmpty ? ' - ${addr.complement}' : ''}',
                          style: TextStyle(
                              fontSize: AppTypography.base,
                              color: AppColors.textSecondary),
                        ),
                        Text(
                          '${addr.neighborhood}, ${addr.city} - ${addr.state}',
                          style: TextStyle(
                              fontSize: AppTypography.base,
                              color: AppColors.textSecondary),
                        ),
                        Text(
                          'CEP: ${_formatCep(addr.cep)}',
                          style: TextStyle(
                              fontSize: AppTypography.base,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Divider(height: 1),
                        const SizedBox(height: AppSpacing.sm),
                        Center(
                          child: TextButton.icon(
                            onPressed: () =>
                                context.push('${RouteNames.professionalProfile}/edit'),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            label: const Text('Editar Endereço'),
                          ),
                        ),
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
                        'Adicione um endereço para seus clientes saberem onde você atende',
                        style: TextStyle(
                            fontSize: AppTypography.base,
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        title: 'Editar perfil para adicionar',
                        onPressed: () =>
                            context.push('${RouteNames.professionalProfile}/edit'),
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
}
