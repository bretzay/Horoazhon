import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/property_list_screen.dart';
import '../screens/agency_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../screens/client_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_biens_screen.dart';
import '../screens/admin/admin_contrats_screen.dart';
import '../screens/admin/admin_personnes_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_agences_screen.dart';
import '../screens/admin/admin_references_screen.dart';
import 'admin_drawer.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  String _drawerRoute = '';
  bool _wasAdminShell = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdminShell = auth.hasAdminNav;

    // Reset tab index when switching between public and admin shells
    // (e.g., login from tab 3 in public shell → index 3 in admin shell
    // would show SizedBox.shrink instead of the dashboard)
    if (isAdminShell != _wasAdminShell) {
      _currentIndex = 0;
      _drawerRoute = '';
      _wasAdminShell = isAdminShell;
    }

    if (isAdminShell) {
      return _buildAdminShell(auth);
    }
    return _buildPublicShell(auth);
  }

  // --- Public / Client layout ---
  Widget _buildPublicShell(AuthProvider auth) {
    final isClient = auth.isAuthenticated && auth.isClient;

    return Scaffold(
      key: isClient ? _scaffoldKey : null,
      appBar: _buildAppBar(auth),
      drawer: isClient
          ? _ClientDrawer(
              currentRoute: _drawerRoute,
              onNavigate: _handleDrawerNavigation,
            )
          : null,
      body: _drawerRoute.isNotEmpty && isClient
          ? _getClientDrawerScreen(_drawerRoute)
          : IndexedStack(
              index: _currentIndex,
              children: _getPublicScreens(auth),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _drawerRoute.isNotEmpty && isClient ? 3 : _currentIndex,
        onTap: (index) {
          if (isClient && index == 3) {
            _scaffoldKey.currentState?.openDrawer();
            return;
          }
          setState(() {
            _currentIndex = index;
            _drawerRoute = '';
          });
        },
        items: _getPublicNavItems(auth),
      ),
    );
  }

  Widget _getClientDrawerScreen(String route) {
    switch (route) {
      case '/client/dashboard':
        return const ClientDashboardScreen();
      case '/profil':
        return const ProfileScreen();
      default:
        return const Center(child: Text('Page non trouvée'));
    }
  }

  List<Widget> _getPublicScreens(AuthProvider auth) {
    return [
      const HomeScreen(),
      const PropertyListScreen(),
      const AgencyListScreen(),
      auth.isAuthenticated
          ? (auth.isClient ? const ClientDashboardScreen() : const ProfileScreen())
          : const LoginScreen(),
    ];
  }

  List<BottomNavigationBarItem> _getPublicNavItems(AuthProvider auth) {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Accueil',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.apartment),
        activeIcon: Icon(Icons.apartment),
        label: 'Biens',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.location_on_outlined),
        activeIcon: Icon(Icons.location_on),
        label: 'Agences',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outlined),
        activeIcon: const Icon(Icons.person),
        label: auth.isAuthenticated ? (auth.isClient ? 'Plus' : 'Profil') : 'Connexion',
      ),
    ];
  }

  // --- Admin / Agent layout ---
  Widget _buildAdminShell(AuthProvider auth) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(auth),
      drawer: AdminDrawer(
        currentRoute: _drawerRoute,
        onNavigate: _handleDrawerNavigation,
      ),
      body: _drawerRoute.isNotEmpty
          ? _getDrawerScreen(_drawerRoute)
          : _getAdminScreenByIndex(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _drawerRoute.isNotEmpty ? 3 : _currentIndex,
        onTap: (index) {
          if (index == 3) {
            _scaffoldKey.currentState?.openDrawer();
            return;
          }
          setState(() {
            _currentIndex = index;
            _drawerRoute = '';
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            activeIcon: Icon(Icons.apartment),
            label: 'Biens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Contrats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'Plus',
          ),
        ],
      ),
    );
  }

  Widget _getAdminScreenByIndex(int index) {
    switch (index) {
      case 0: return const AdminDashboardScreen();
      case 1: return const AdminBiensScreen();
      case 2: return const AdminContratsScreen();
      default: return const SizedBox.shrink(); // "Plus" opens drawer
    }
  }

  Widget _getDrawerScreen(String route) {
    switch (route) {
      case '/admin/personnes':
        return const AdminPersonnesScreen();
      case '/admin/utilisateurs':
        return const AdminUsersScreen();
      case '/admin/agences':
        return const AdminAgencesScreen();
      case '/admin/references':
        return const AdminReferencesScreen();
      case '/profil':
        return const ProfileScreen();
      default:
        return const Center(child: Text('Page non trouvée'));
    }
  }

  void _handleDrawerNavigation(String route) {
    setState(() {
      _drawerRoute = route;
    });
  }

  PreferredSizeWidget _buildAppBar(AuthProvider auth) {
    return AppBar(
      title: Text(
        'Horoazhon',
        style: AppTextStyles.textLg.w700.withColor(AppColors.blue500),
      ),
      centerTitle: false,
      actions: [
        if (auth.isAuthenticated)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                _roleShortLabel(auth.role),
                style: AppTextStyles.textSm.w600.withColor(AppColors.white),
              ),
              backgroundColor: AppColors.roleColor(auth.role ?? ''),
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }

  String _roleShortLabel(String? role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return 'Super Admin';
      case 'ADMIN_AGENCY':
        return 'Admin';
      case 'AGENT':
        return 'Agent';
      case 'CLIENT':
        return 'Client';
      default:
        return '';
    }
  }
}

class _ClientDrawer extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onNavigate;

  const _ClientDrawer({
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space6),
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.fullName,
                    style: AppTextStyles.textLg.w700.withColor(AppColors.white),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'Client',
                    style: AppTextStyles.textSm.w500.withColor(AppColors.blue100),
                  ),
                  if (auth.agenceNom != null) ...[
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      auth.agenceNom!,
                      style: AppTextStyles.textSm.w400.withColor(AppColors.blue100),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
                children: [
                  _ClientDrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Mon espace',
                    route: '/client/dashboard',
                    currentRoute: currentRoute,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigate('/client/dashboard');
                    },
                  ),
                  _ClientDrawerItem(
                    icon: Icons.person_outlined,
                    label: 'Profil',
                    route: '/profil',
                    currentRoute: currentRoute,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigate('/profil');
                    },
                  ),
                  const Divider(),
                  _ClientDrawerItem(
                    icon: Icons.logout,
                    label: 'Déconnexion',
                    route: '',
                    currentRoute: currentRoute,
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Déconnexion'),
                          content: const Text('Voulez-vous vous déconnecter ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                auth.logout();
                              },
                              child: const Text('Déconnexion'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const _ClientDrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = route.isNotEmpty && currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.blue500 : AppColors.slate500,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTextStyles.textMd.w500.withColor(
          isSelected ? AppColors.blue500 : AppColors.slate700,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.blue50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
      ),
      onTap: onTap,
    );
  }
}
