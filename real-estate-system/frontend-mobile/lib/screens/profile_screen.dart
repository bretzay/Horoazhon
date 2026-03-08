import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  bool _showPasswordSection = false;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }
    if (_newPasswordController.text.isEmpty || _currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      await _api.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() => _showPasswordSection = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe modifié avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe actuel incorrect')),
        );
      }
    }
    if (mounted) setState(() => _isChangingPassword = false);
  }

  void _confirmLogout(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        // User info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space5),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.blue100,
                    borderRadius: AppRadius.fullAll,
                  ),
                  child: Center(
                    child: Text(
                      '${(auth.prenom ?? '').isNotEmpty ? auth.prenom![0] : ''}${(auth.nom ?? '').isNotEmpty ? auth.nom![0] : ''}',
                      style: AppTextStyles.textXl.w700.withColor(AppColors.blue500),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Text('${auth.prenom ?? ''} ${auth.nom ?? ''}', style: AppTextStyles.textLg.w700),
                const SizedBox(height: AppSpacing.space1),
                Text(auth.email ?? '', style: AppTextStyles.textMd.w400.withColor(AppColors.slate500)),
                const SizedBox(height: AppSpacing.space2),
                Chip(
                  label: Text(
                    _roleLabel(auth.role),
                    style: AppTextStyles.textSm.w600.withColor(AppColors.white),
                  ),
                  backgroundColor: AppColors.roleColor(auth.role ?? ''),
                ),
                if (auth.agenceNom != null) ...[
                  const SizedBox(height: AppSpacing.space2),
                  Text(auth.agenceNom!, style: AppTextStyles.textMd.w400.withColor(AppColors.slate500)),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space6),

        // Change password section
        Card(
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
                borderRadius: AppRadius.lgAll,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  child: Row(
                    children: [
                      const Icon(Icons.key, color: AppColors.slate500),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Text('Changer le mot de passe', style: AppTextStyles.textMd.w600),
                      ),
                      Icon(
                        _showPasswordSection ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.slate400,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showPasswordSection)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space4, 0, AppSpacing.space4, AppSpacing.space4),
                  child: Column(
                    children: [
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
                      ),
                      const SizedBox(height: AppSpacing.formFieldGap),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                      ),
                      const SizedBox(height: AppSpacing.formFieldGap),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isChangingPassword ? null : _changePassword,
                          child: _isChangingPassword
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                              : const Text('Modifier'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.space6),

        // Logout button
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _confirmLogout(auth),
            icon: const Icon(Icons.logout),
            label: const Text('Déconnexion'),
          ),
        ),
      ],
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'SUPER_ADMIN': return 'Super Administrateur';
      case 'ADMIN_AGENCY': return 'Administrateur Agence';
      case 'AGENT': return 'Agent';
      case 'CLIENT': return 'Client';
      default: return '';
    }
  }
}
