import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../config/app_formatters.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  final String? initialSearch;

  const PropertyListScreen({super.key, this.initialSearch});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<dynamic> _biens = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  // Filters
  String? _selectedType;
  bool? _forSale;
  bool? _forRent;

  final _types = ['APPARTEMENT', 'MAISON', 'STUDIO', 'TERRAIN'];

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
    }
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 0;
      _biens = [];
      _hasMore = true;
    });
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
        forSale: _forSale,
        forRent: _forRent,
        page: page,
        size: 10,
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
      if (mounted) {
        setState(() {
          _error = 'Erreur de chargement des biens';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = null;
      _forSale = null;
      _forRent = null;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter bar
        _buildFilterBar(),

        // Content
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      color: AppColors.white,
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _loadData();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onSubmitted: (_) => _loadData(),
          ),
          const SizedBox(height: AppSpacing.space2),

          // Type + sale/rent filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Type dropdown
                _FilterChip(
                  label: _selectedType ?? 'Type',
                  isActive: _selectedType != null,
                  onTap: () => _showTypeMenu(),
                ),
                const SizedBox(width: AppSpacing.space2),
                _FilterChip(
                  label: 'Vente',
                  isActive: _forSale == true,
                  onTap: () {
                    setState(() {
                      _forSale = _forSale == true ? null : true;
                      _forRent = null;
                    });
                    _loadData();
                  },
                ),
                const SizedBox(width: AppSpacing.space2),
                _FilterChip(
                  label: 'Location',
                  isActive: _forRent == true,
                  onTap: () {
                    setState(() {
                      _forRent = _forRent == true ? null : true;
                      _forSale = null;
                    });
                    _loadData();
                  },
                ),
                if (_selectedType != null || _forSale != null || _forRent != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  _FilterChip(
                    label: 'Effacer',
                    isActive: false,
                    onTap: _clearFilters,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tous les types'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _selectedType = null);
                _loadData();
              },
            ),
            ..._types.map((type) => ListTile(
                  title: Text(type),
                  selected: _selectedType == type,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedType = type);
                    _loadData();
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const ShimmerLoading();
    }

    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _loadData);
    }

    if (_biens.isEmpty) {
      return EmptyState(
        icon: Icons.apartment,
        title: 'Aucun bien trouvé',
        subtitle: 'Essayez de modifier vos filtres',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.space4),
        itemCount: _biens.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space4),
        itemBuilder: (context, index) {
          if (index == _biens.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.space4),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final bien = _biens[index] as Map<String, dynamic>;
          return _PropertyListCard(
            bien: bien,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PropertyDetailScreen(bienId: bien['id'] as int),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.blue500 : AppColors.white,
          borderRadius: AppRadius.fullAll,
          border: Border.all(
            color: isActive ? AppColors.blue500 : AppColors.slate200,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.textSm.w500.withColor(
            isActive ? AppColors.white : AppColors.slate700,
          ),
        ),
      ),
    );
  }
}

class _PropertyListCard extends StatelessWidget {
  final Map<String, dynamic> bien;
  final VoidCallback onTap;

  const _PropertyListCard({required this.bien, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final photoUrl = bien['principalPhotoUrl'] as String?;
    final isForSale = bien['availableForSale'] == true;
    final isForRent = bien['availableForRent'] == true;
    final prix = bien['salePrice'] ?? bien['monthlyRent'];
    final ville = bien['ville'] ?? '';
    final superficie = bien['superficie'];
    final type = bien['type'] ?? '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Photo
            Container(
              width: 120,
              height: 100,
              color: AppColors.slate100,
              child: photoUrl != null
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.image_outlined, color: AppColors.slate400)),
                    )
                  : const Center(child: Icon(Icons.image_outlined, color: AppColors.slate400)),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isForSale)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: AppColors.blue500,
                              borderRadius: AppRadius.fullAll,
                            ),
                            child: Text(
                              'Vente',
                              style: AppTextStyles.textSm.w600.withColor(AppColors.white),
                            ),
                          ),
                        if (isForRent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: AppColors.slate900,
                              borderRadius: AppRadius.fullAll,
                            ),
                            child: Text(
                              'Location',
                              style: AppTextStyles.textSm.w600.withColor(AppColors.white),
                            ),
                          ),
                        Flexible(child: Text(type, style: AppTextStyles.textSm.w400, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (prix != null)
                      Text(
                        isForSale
                            ? AppFormatters.formatCurrencyShort((prix as num).toDouble())
                            : AppFormatters.formatRent((prix as num).toDouble()),
                        style: AppTextStyles.textMd.w700.withColor(AppColors.slate900),
                      ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.slate400),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(ville, style: AppTextStyles.textSm.w400, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (superficie != null)
                          Text(
                            AppFormatters.formatArea((superficie as num).toDouble()),
                            style: AppTextStyles.textSm.w500.withColor(AppColors.slate500),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: AppColors.slate400),
            ),
          ],
        ),
      ),
    );
  }
}
