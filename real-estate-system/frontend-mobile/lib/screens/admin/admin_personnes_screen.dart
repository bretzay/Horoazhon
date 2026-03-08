import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../services/api_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';
import 'admin_personne_form_screen.dart';

class AdminPersonnesScreen extends StatefulWidget {
  const AdminPersonnesScreen({super.key});

  @override
  State<AdminPersonnesScreen> createState() => _AdminPersonnesScreenState();
}

class _AdminPersonnesScreenState extends State<AdminPersonnesScreen> {
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();

  List<dynamic> _personnes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = _searchController.text.isNotEmpty
          ? await _api.searchPersonnes(_searchController.text)
          : await _api.getPersonnes();
      if (mounted) setState(() { _personnes = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  Future<void> _deletePersonne(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette personne ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _api.deletePersonne(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personne supprimée')));
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de supprimer (contrats actifs ?)')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.space3),
          color: AppColors.white,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Rechercher une personne...',
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (_) => _loadData(),
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const ShimmerLoading();
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_personnes.isEmpty) return const EmptyState(icon: Icons.people_outlined, title: 'Aucune personne trouvée');

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: _personnes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
            itemBuilder: (context, index) {
              final p = _personnes[index] as Map<String, dynamic>;
              return Card(
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AdminPersonneFormScreen(personneId: p['id'] as int),
                    ));
                    _loadData();
                  },
                  borderRadius: AppRadius.lgAll,
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
                              Text('${p['prenom'] ?? ''} ${p['nom'] ?? ''}', style: AppTextStyles.textMd.w600),
                              if (p['ville'] != null) Text(p['ville'], style: AppTextStyles.textSm.w400),
                            ],
                          ),
                        ),
                        PopupMenuButton(
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                          ],
                          onSelected: (v) {
                            if (v == 'edit') {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => AdminPersonneFormScreen(personneId: p['id'] as int),
                              )).then((_) => _loadData());
                            }
                            if (v == 'delete') _deletePersonne(p['id'] as int);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: AppSpacing.space4,
          right: AppSpacing.space4,
          child: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(
                builder: (_) => const AdminPersonneFormScreen(),
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
