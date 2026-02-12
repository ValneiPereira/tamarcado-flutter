import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../routing/route_names.dart';

class ChooseTypeScreen extends StatelessWidget {
  const ChooseTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Title
              const Text(
                'Criar Conta',
                style: TextStyle(
                  fontSize: AppTypography.xxl,
                  fontWeight: AppTypography.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Você é:',
                style: TextStyle(
                  fontSize: AppTypography.lg,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Client card
              AppCard(
                variant: CardVariant.elevated,
                onPress: () => context.push(RouteNames.registerClient),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.lg),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Cliente',
                              style: TextStyle(
                                fontSize: AppTypography.lg,
                                fontWeight: AppTypography.semibold,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Quero contratar serviços de profissionais',
                              style: TextStyle(
                                fontSize: AppTypography.sm,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Professional card
              AppCard(
                variant: CardVariant.elevated,
                onPress: () => context.push(RouteNames.registerProfessional),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.lg),
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          size: 28,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Profissional',
                              style: TextStyle(
                                fontSize: AppTypography.lg,
                                fontWeight: AppTypography.semibold,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Quero oferecer meus serviços e receber agendamentos',
                              style: TextStyle(
                                fontSize: AppTypography.sm,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Back button
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                label: const Text(
                  'Voltar para login',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppTypography.base,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
