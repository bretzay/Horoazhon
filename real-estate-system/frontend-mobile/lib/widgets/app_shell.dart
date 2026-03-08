import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
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
import 'admin_drawer.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  String _drawerRoute = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Reset tab index if it becomes invalid after role change
    final maxIndex = _getMaxTabIndex(auth);
    if (_currentIndex > maxIndex) {
      _currentIndex = 0;
    }

    if (auth.hasAdminNav) {
      return _buildAdminShell(auth);
    }
    return _buildPublicShell(auth);
  }

  int _getMaxTabIndex(AuthProvider auth) {
    return 3; // All layouts have 4 tabs (index 0-3)
  }

  // --- Public / Client layout ---
  Widget _buildPublicShell(AuthProvider auth) {
    final screens = _getPublicScreens(auth);

    return Scaffold(
      appBar: _buildAppBar(auth),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _getPublicNavItems(auth),
      ),
    );
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
        label: auth.isAuthenticated ? 'Profil' : 'Connexion',
      ),
    ];
  }

  // --- Admin / Agent layout ---
  Widget _buildAdminShell(AuthProvider auth) {
    final screens = _getAdminScreens();

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(auth),
      drawer: AdminDrawer(
        currentRoute: _drawerRoute,
        onNavigate: _handleDrawerNavigation,
      ),
      body: _drawerRoute.isNotEmpty
          ? _getDrawerScreen(_drawerRoute)
          : IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
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

  List<Widget> _getAdminScreens() {
    return [
      const AdminDashboardScreen(),
      const AdminBiensScreen(),
      const AdminContratsScreen(),
      const SizedBox.shrink(), // "Plus" opens drawer
    ];
  }

  Widget _getDrawerScreen(String route) {
    switch (route) {
      case '/admin/personnes':
        return const _PlaceholderScreen(title: 'Personnes');
      case '/admin/utilisateurs':
        return const _PlaceholderScreen(title: 'Utilisateurs');
      case '/admin/agences':
        return const _PlaceholderScreen(title: 'Agences');
      case '/admin/references':
        return const _PlaceholderScreen(title: 'Données de référence');
      case '/profil':
        return const ProfileScreen();
      default:
        return const _PlaceholderScreen(title: 'Page non trouvée');
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

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: AppTextStyles.textLg.w600.withColor(AppColors.slate500),
      ),
    );
  }
}
