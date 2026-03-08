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
import 'admin_agence_form_screen.dart';

class AdminAgencesScreen extends StatefulWidget {
  const AdminAgencesScreen({super.key});

  @override
  State<AdminAgencesScreen> createState() => _AdminAgencesScreenState();
}

class _AdminAgencesScreenState extends State<AdminAgencesScreen> {
  final ApiService _api = ApiService();

  List<dynamic> _agences = [];
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
      final auth = context.read<AuthProvider>();
      if (auth.isSuperAdmin) {
        _agences = await _api.getAgences();
      } else if (auth.agenceId != null) {
        final agence = await _api.getAgenceById(auth.agenceId!);
        _agences = [agence];
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  Future<void> _deleteAgence(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette agence ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _api.deleteAgence(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agence supprimée')));
          _loadData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de supprimer cette agence')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_isLoading) return const ShimmerLoading();
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_agences.isEmpty) return const EmptyState(icon: Icons.business_outlined, title: 'Aucune agence');

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: _agences.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
            itemBuilder: (context, index) {
              final agence = _agences[index] as Map<String, dynamic>;
              return Card(
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AdminAgenceFormScreen(agenceId: agence['id'] as int),
                    ));
                    _loadData();
                  },
                  borderRadius: AppRadius.lgAll,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: AppColors.blue100, borderRadius: AppRadius.mdAll),
                          child: const Icon(Icons.business_outlined, color: AppColors.blue500),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(agence['nom'] ?? '', style: AppTextStyles.textMd.w600),
                              Text(agence['ville'] ?? '', style: AppTextStyles.textSm.w400),
                              if (agence['siret'] != null)
                                Text('SIRET: ${agence['siret']}', style: AppTextStyles.textSm.w400.withColor(AppColors.slate400)),
                            ],
                          ),
                        ),
                        if (auth.isSuperAdmin)
                          PopupMenuButton(
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                              const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                            ],
                            onSelected: (v) {
                              if (v == 'edit') {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => AdminAgenceFormScreen(agenceId: agence['id'] as int),
                                )).then((_) => _loadData());
                              }
                              if (v == 'delete') _deleteAgence(agence['id'] as int);
                            },
                          )
                        else
                          const Icon(Icons.chevron_right, color: AppColors.slate400),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (auth.isSuperAdmin)
          Positioned(
            bottom: AppSpacing.space4,
            right: AppSpacing.space4,
            child: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const AdminAgenceFormScreen(),
                ));
                _loadData();
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}
