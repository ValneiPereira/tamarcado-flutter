import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

class TamarcadoApp extends ConsumerWidget {
  const TamarcadoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    ref.listen(authProvider, (_, next) {
      if (next.isAuthenticated) {
        registerFcmTokenIfAuthenticated(ref);
      }
    });

    return MaterialApp.router(
      title: 'Tá Marcado!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
