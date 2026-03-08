import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../providers/auth_provider.dart';
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

  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver cet utilisateur ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Désactiver')),
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
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la désactivation')),
        );
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

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Row(
                children: [
                  const Icon(Icons.person_outlined, color: AppColors.slate400),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email, style: AppTextStyles.textMd.w500),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.roleColor(role),
                                borderRadius: AppRadius.fullAll,
                              ),
                              child: Text(role, style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
                            ),
                            if (user['agenceNom'] != null) ...[
                              const SizedBox(width: 8),
                              Text(user['agenceNom'], style: AppTextStyles.textSm.w400),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'delete', child: Text('Désactiver')),
                    ],
                    onSelected: (v) {
                      if (v == 'delete') _deleteUser(user['id'] as int);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
