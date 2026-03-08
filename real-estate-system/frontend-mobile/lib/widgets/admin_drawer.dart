import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';
import '../providers/auth_provider.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onNavigate;

  const AdminDrawer({
    super.key,
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
            // Header
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
                    _roleLabel(auth.role),
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

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
                children: [
                  _DrawerItem(
                    icon: Icons.people_outlined,
                    label: 'Personnes',
                    route: '/admin/personnes',
                    currentRoute: currentRoute,
                    onTap: () => _navigate(context, '/admin/personnes'),
                  ),
                  if (auth.isAdmin)
                    _DrawerItem(
                      icon: Icons.manage_accounts_outlined,
                      label: 'Utilisateurs',
                      route: '/admin/utilisateurs',
                      currentRoute: currentRoute,
                      onTap: () => _navigate(context, '/admin/utilisateurs'),
                    ),
                  _DrawerItem(
                    icon: Icons.business_outlined,
                    label: 'Agences',
                    route: '/admin/agences',
                    currentRoute: currentRoute,
                    onTap: () => _navigate(context, '/admin/agences'),
                  ),
                  if (auth.isSuperAdmin)
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Données de référence',
                      route: '/admin/references',
                      currentRoute: currentRoute,
                      onTap: () => _navigate(context, '/admin/references'),
                    ),
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.person_outlined,
                    label: 'Profil',
                    route: '/profil',
                    currentRoute: currentRoute,
                    onTap: () => _navigate(context, '/profil'),
                  ),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Déconnexion',
                    route: '',
                    currentRoute: currentRoute,
                    onTap: () => _confirmLogout(context, auth),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    Navigator.pop(context); // close drawer
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
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context); // close drawer
    onNavigate(route);
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return 'Super Administrateur';
      case 'ADMIN_AGENCY':
        return 'Administrateur Agence';
      case 'AGENT':
        return 'Agent';
      case 'CLIENT':
        return 'Client';
      default:
        return '';
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const _DrawerItem({
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
