import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../services/api_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService _api = ApiService();

  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _users = await _api.getUtilisateurs();
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  Future<void> _deactivateUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver cet utilisateur ?'),
        content: const Text('L\'utilisateur ne pourra plus se connecter.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.slate700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _api.deleteUtilisateur(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utilisateur désactivé')));
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la désactivation')),
          );
        }
      }
    }
  }

  Future<void> _reactivateUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réactiver cet utilisateur ?'),
        content: const Text('L\'utilisateur pourra à nouveau se connecter.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue500),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Réactiver'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _api.reactivateUtilisateur(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utilisateur réactivé')));
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la réactivation')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const ShimmerLoading();
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_users.isEmpty) return const EmptyState(icon: Icons.manage_accounts_outlined, title: 'Aucun utilisateur');

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.space4),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
        itemBuilder: (context, index) {
          final user = _users[index] as Map<String, dynamic>;
          final role = user['role'] as String? ?? '';
          final email = user['email'] as String? ?? '';
          final isActive = user['actif'] as bool? ?? true;
          final isActivated = user['activated'] as bool? ?? true;

          return Opacity(
            opacity: isActive ? 1.0 : 0.55,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdAll,
                side: BorderSide(
                  color: isActive ? AppColors.slate200 : AppColors.slate400,
                  width: isActive ? 1.0 : 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space3),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isActive ? AppColors.blue100 : AppColors.slate200,
                      child: Icon(
                        isActive ? Icons.person_outlined : Icons.person_off_outlined,
                        color: isActive ? AppColors.blue500 : AppColors.slate500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email,
                            style: AppTextStyles.textMd.w500.withColor(
                              isActive ? AppColors.slate900 : AppColors.slate500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space1),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildRoleBadge(role),
                              _buildStatusBadge(isActive, isActivated),
                              if (user['agenceNom'] != null)
                                Text(user['agenceNom'], style: AppTextStyles.textSm.w400),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      itemBuilder: (_) => [
                        if (isActive)
                          const PopupMenuItem(
                            value: 'deactivate',
                            child: Row(
                              children: [
                                Icon(Icons.block, size: 18, color: AppColors.slate700),
                                SizedBox(width: 8),
                                Text('Désactiver'),
                              ],
                            ),
                          )
                        else
                          const PopupMenuItem(
                            value: 'reactivate',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, size: 18, color: AppColors.blue500),
                                SizedBox(width: 8),
                                Text('Réactiver'),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (v) {
                        final id = user['id'] as int;
                        if (v == 'deactivate') _deactivateUser(id);
                        if (v == 'reactivate') _reactivateUser(id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.roleColor(role),
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(role, style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isActivated) {
    final String label;
    final Color bgColor;
    final Color textColor;

    if (!isActive) {
      label = 'Inactif';
      bgColor = AppColors.slate200;
      textColor = AppColors.slate700;
    } else if (!isActivated) {
      label = 'En attente';
      bgColor = AppColors.blue100;
      textColor = AppColors.blue600;
    } else {
      label = 'Actif';
      bgColor = AppColors.slate100;
      textColor = AppColors.slate900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(label, style: AppTextStyles.textSm.w600.withColor(textColor)),
    );
  }
}
