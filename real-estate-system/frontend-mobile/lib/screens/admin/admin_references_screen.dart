import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../services/api_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';

class AdminReferencesScreen extends StatefulWidget {
  const AdminReferencesScreen({super.key});

  @override
  State<AdminReferencesScreen> createState() => _AdminReferencesScreenState();
}

class _AdminReferencesScreenState extends State<AdminReferencesScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;

  List<dynamic> _caracteristiques = [];
  List<dynamic> _lieux = [];
  bool _isLoading = true;
  String? _error;

  final _addCaracController = TextEditingController();
  final _addLieuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addCaracController.dispose();
    _addLieuController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([_api.getCaracteristiques(), _api.getLieux()]);
      if (mounted) {
        setState(() {
          _caracteristiques = results[0];
          _lieux = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  Future<void> _addCaracteristique() async {
    final nom = _addCaracController.text.trim();
    if (nom.isEmpty) return;
    try {
      await _api.createCaracteristique({'nom': nom});
      _addCaracController.clear();
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout')),
        );
      }
    }
  }

  Future<void> _deleteCaracteristique(int id) async {
    try {
      await _api.deleteCaracteristique(id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de supprimer (utilisée par des biens ?)')),
        );
      }
    }
  }

  Future<void> _addLieu() async {
    final nom = _addLieuController.text.trim();
    if (nom.isEmpty) return;
    try {
      await _api.createLieu({'nom': nom});
      _addLieuController.clear();
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout')),
        );
      }
    }
  }

  Future<void> _deleteLieu(int id) async {
    try {
      await _api.deleteLieu(id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de supprimer (utilisé par des biens ?)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const ShimmerLoading();
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);

    return Column(
      children: [
        TabBar(controller: _tabController, tabs: const [
          Tab(text: 'Caractéristiques'),
          Tab(text: 'Lieux'),
        ]),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList(
                items: _caracteristiques,
                addController: _addCaracController,
                onAdd: _addCaracteristique,
                onDelete: _deleteCaracteristique,
                emptyLabel: 'Aucune caractéristique',
                addHint: 'Ajouter une caractéristique...',
              ),
              _buildList(
                items: _lieux,
                addController: _addLieuController,
                onAdd: _addLieu,
                onDelete: _deleteLieu,
                emptyLabel: 'Aucun lieu',
                addHint: 'Ajouter un lieu...',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList({
    required List<dynamic> items,
    required TextEditingController addController,
    required VoidCallback onAdd,
    required Function(int) onDelete,
    required String emptyLabel,
    required String addHint,
  }) {
    return Column(
      children: [
        // Add field
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: addController,
                  decoration: InputDecoration(hintText: addHint, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              ElevatedButton(
                onPressed: onAdd,
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: items.isEmpty
              ? Center(child: Text(emptyLabel, style: AppTextStyles.textMd.w400.withColor(AppColors.slate400)))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(item['nom'] ?? '', style: AppTextStyles.textMd.w400),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outlined, color: AppColors.slate400),
                          onPressed: () => onDelete(item['id'] as int),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
