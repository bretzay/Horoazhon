import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../config/app_formatters.dart';
import '../../services/api_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';
import '../property_detail_screen.dart';
import 'admin_bien_form_screen.dart';

class AdminBiensScreen extends StatefulWidget {
  const AdminBiensScreen({super.key});

  @override
  State<AdminBiensScreen> createState() => _AdminBiensScreenState();
}

class _AdminBiensScreenState extends State<AdminBiensScreen> {
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<dynamic> _biens = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  String? _selectedType;

  // Archive filter: null = actifs only, true = actifs, false = archives
  bool? _actifFilter = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; _currentPage = 0; _biens = []; _hasMore = true; });
    await _fetchPage(0);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    await _fetchPage(_currentPage + 1);
  }

  Future<void> _fetchPage(int page) async {
    try {
      final result = await _api.getBiens(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        type: _selectedType,
        actif: _actifFilter,
        page: page,
        size: 15,
      );
      final content = result['content'] as List? ?? [];
      final totalPages = result['totalPages'] as int? ?? 1;
      if (mounted) {
        setState(() {
          if (page == 0) {
            _biens = content;
          } else {
            _biens.addAll(content);
          }
          _currentPage = page;
          _hasMore = page < totalPages - 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; _isLoadingMore = false; });
    }
  }

  Future<void> _deleteBien(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce bien ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _api.deleteBien(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bien supprimé')));
          _loadData();
        }
      } on DioException catch (e) {
        if (mounted) {
          final statusCode = e.response?.statusCode;
          if (statusCode == 409) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Ce bien a des contrats. Vous pouvez l\'archiver à la place.'),
                action: SnackBarAction(
                  label: 'Archiver',
                  onPressed: () => _toggleArchive(id, true),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Impossible de supprimer ce bien')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de supprimer ce bien')),
          );
        }
      }
    }
  }

  Future<void> _toggleArchive(int id, bool archive) async {
    try {
      if (archive) {
        await _api.archiveBien(id);
      } else {
        await _api.unarchiveBien(id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(archive ? 'Bien archivé' : 'Bien désarchivé')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search
        Container(
          padding: const EdgeInsets.all(AppSpacing.space3),
          color: AppColors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un bien...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (_) => _loadData(),
              ),
              const SizedBox(height: AppSpacing.space2),
              // Archive filter chips
              Row(
                children: [
                  _ArchiveChip(
                    label: 'Actifs',
                    isActive: _actifFilter == true,
                    onTap: () { setState(() => _actifFilter = true); _loadData(); },
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  _ArchiveChip(
                    label: 'Archivés',
                    isActive: _actifFilter == false,
                    onTap: () { setState(() => _actifFilter = false); _loadData(); },
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  _ArchiveChip(
                    label: 'Tous',
                    isActive: _actifFilter == null,
                    onTap: () { setState(() => _actifFilter = null); _loadData(); },
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const ShimmerLoading();
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_biens.isEmpty) return const EmptyState(icon: Icons.apartment, title: 'Aucun bien trouvé');

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: _biens.length + (_hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
            itemBuilder: (context, index) {
              if (index == _biens.length) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
              }
              final bien = _biens[index] as Map<String, dynamic>;
              final isActif = bien['actif'] as bool? ?? true;
              return _AdminBienCard(
                bien: bien,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PropertyDetailScreen(bienId: bien['id'] as int),
                )),
                onEdit: () async {
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AdminBienFormScreen(bienId: bien['id'] as int),
                  ));
                  _loadData();
                },
                onDelete: () => _deleteBien(bien['id'] as int),
                onToggleArchive: () => _toggleArchive(bien['id'] as int, isActif),
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
                builder: (_) => const AdminBienFormScreen(),
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

class _ArchiveChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ArchiveChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3, vertical: AppSpacing.space1),
        decoration: BoxDecoration(
          color: isActive ? AppColors.blue500 : AppColors.white,
          borderRadius: AppRadius.fullAll,
          border: Border.all(color: isActive ? AppColors.blue500 : AppColors.slate200),
        ),
        child: Text(
          label,
          style: AppTextStyles.textSm.w500.withColor(isActive ? AppColors.white : AppColors.slate700),
        ),
      ),
    );
  }
}

class _AdminBienCard extends StatelessWidget {
  final Map<String, dynamic> bien;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleArchive;

  const _AdminBienCard({
    required this.bien,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context) {
    final isForSale = bien['availableForSale'] == true;
    final isForRent = bien['availableForRent'] == true;
    final prix = bien['salePrice'] ?? bien['monthlyRent'];
    final isActif = bien['actif'] as bool? ?? true;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(AppFormatters.formatBienId(bien['id'] as int),
                            style: AppTextStyles.textSm.w600.withColor(AppColors.slate400)),
                        const SizedBox(width: 8),
                        if (!isActif)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: AppRadius.fullAll,
                            ),
                            child: Text('Archivé',
                                style: AppTextStyles.textSm.w600.withColor(AppColors.slate700)),
                          ),
                        if (isForSale)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: AppColors.blue500,
                              borderRadius: AppRadius.fullAll,
                            ),
                            child: Text('Vente',
                                style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
                          ),
                        if (isForRent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate900,
                              borderRadius: AppRadius.fullAll,
                            ),
                            child: Text('Location',
                                style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${bien['type'] ?? ''} - ${bien['ville'] ?? ''}', style: AppTextStyles.textMd.w500),
                    if (prix != null)
                      Text(
                        isForSale
                            ? AppFormatters.formatCurrencyShort((prix as num).toDouble())
                            : AppFormatters.formatRent((prix as num).toDouble()),
                        style: AppTextStyles.textSm.w600.withColor(AppColors.blue500),
                      ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(isActif ? 'Archiver' : 'Désarchiver'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                ],
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'archive') onToggleArchive();
                  if (value == 'delete') onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
