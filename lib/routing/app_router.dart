import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/choose_type_screen.dart';
import '../features/auth/presentation/screens/register_client_screen.dart';
import '../features/auth/presentation/screens/register_professional_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/client/presentation/screens/client_home_screen.dart';
import '../features/client/presentation/screens/professional_detail_screen.dart';
import '../features/client/presentation/screens/client_appointments_screen.dart';
import '../features/client/presentation/screens/client_profile_screen.dart';
import '../features/client/presentation/screens/client_edit_profile_screen.dart';
import '../features/client/presentation/screens/client_addresses_screen.dart';
import '../features/client/presentation/screens/client_change_password_screen.dart';
import '../features/professional/presentation/screens/professional_dashboard_screen.dart';
import '../features/professional/presentation/screens/professional_appointments_screen.dart';
import '../features/professional/presentation/screens/professional_services_screen.dart';
import '../features/professional/presentation/screens/professional_profile_screen.dart';
import '../features/professional/presentation/screens/professional_edit_profile_screen.dart';
import '../features/professional/presentation/screens/professional_address_screen.dart';
import '../core/theme/app_colors.dart';
import 'route_names.dart';

// Client Shell com Bottom Navigation
class ClientShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ClientShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.textOnPrimary,
        unselectedItemColor: const Color(0x99FFFFFF),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Agendamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// Professional Shell com Bottom Navigation
class ProfessionalShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ProfessionalShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        backgroundColor: AppColors.secondary,
        selectedItemColor: AppColors.textOnPrimary,
        unselectedItemColor: const Color(0x99FFFFFF),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Agendamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// Classe para notificar o GoRouter sobre mudanças no estado de auth sem recriar o roteador
class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final authRefreshListenableProvider =
    Provider((ref) => AuthRefreshListenable(ref));

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.read(authRefreshListenableProvider);

  return GoRouter(
    initialLocation: RouteNames.login,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      if (authState.isInitializing) return null;

      final isAuth = authState.isAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location == RouteNames.login ||
          location == RouteNames.chooseType ||
          location.startsWith('/register') ||
          location == RouteNames.forgotPassword;

      // Não autenticado tentando acessar rota protegida
      if (!isAuth && !isAuthRoute) return RouteNames.login;

      // Autenticado tentando acessar rota de auth
      if (isAuth && isAuthRoute) {
        return authState.user?.isClient == true
            ? RouteNames.clientHome
            : RouteNames.professionalDashboard;
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.chooseType,
        builder: (_, __) => const ChooseTypeScreen(),
      ),
      GoRoute(
        path: RouteNames.registerClient,
        builder: (_, __) => const RegisterClientScreen(),
      ),
      GoRoute(
        path: RouteNames.registerProfessional,
        builder: (_, __) => const RegisterProfessionalScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // Client shell (tab navigation)
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            ClientShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.clientHome,
              builder: (_, __) => const ClientHomeScreen(),
              routes: [
                GoRoute(
                  path: 'professional/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ProfessionalDetailScreen(professionalId: id);
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.clientAppointments,
              builder: (_, __) => const ClientAppointmentsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.clientProfile,
              builder: (_, __) => const ClientProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, __) => const ClientEditProfileScreen(),
                ),
                GoRoute(
                  path: 'addresses',
                  builder: (_, __) => const ClientAddressesScreen(),
                ),
                GoRoute(
                  path: 'change-password',
                  builder: (_, __) => const ClientChangePasswordScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),

      // Professional shell (tab navigation)
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            ProfessionalShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.professionalDashboard,
              builder: (_, __) => const ProfessionalDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.professionalAppointments,
              builder: (_, __) => const ProfessionalAppointmentsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.professionalProfile,
              builder: (_, __) => const ProfessionalProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, __) => const ProfessionalEditProfileScreen(),
                ),
                GoRoute(
                  path: 'services',
                  builder: (_, __) => const ProfessionalServicesScreen(),
                ),
                GoRoute(
                  path: 'address',
                  builder: (_, __) => const ProfessionalAddressScreen(),
                ),
                GoRoute(
                  path: 'change-password',
                  builder: (_, __) => const ClientChangePasswordScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página não encontrada: ${state.error}'),
      ),
    ),
  );
});
