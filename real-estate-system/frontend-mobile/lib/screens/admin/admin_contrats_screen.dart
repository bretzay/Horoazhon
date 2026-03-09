import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../config/app_formatters.dart';
import '../../services/api_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';
import 'admin_contrat_detail_screen.dart';

class AdminContratsScreen extends StatefulWidget {
  final bool showAppBar;

  const AdminContratsScreen({super.key, this.showAppBar = false});

  @override
  State<AdminContratsScreen> createState() => _AdminContratsScreenState();
}

class _AdminContratsScreenState extends State<AdminContratsScreen> {
  final ApiService _api = ApiService();
  final _scrollController = ScrollController();

  List<dynamic> _contrats = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; _currentPage = 0; _contrats = []; _hasMore = true; });
    await _fetchPage(0);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    await _fetchPage(_currentPage + 1);
  }

  Future<void> _fetchPage(int page) async {
    try {
      final result = await _api.getContrats(page: page, size: 15);
      final content = result['content'] as List? ?? [];
      final totalPages = result['totalPages'] as int? ?? 1;
      if (mounted) {
        setState(() {
          if (page == 0) {
            _contrats = content;
          } else {
            _contrats.addAll(content);
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

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contrats')),
        body: content,
      );
    }
    return content;
  }

  Widget _buildContent() {
    if (_isLoading) return const ShimmerLoading();
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_contrats.isEmpty) return const EmptyState(icon: Icons.description_outlined, title: 'Aucun contrat');

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.space4),
        itemCount: _contrats.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
        itemBuilder: (context, index) {
          if (index == _contrats.length) {
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
          }
          final contrat = _contrats[index] as Map<String, dynamic>;
          return _ContratCard(
            contrat: contrat,
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(
                builder: (_) => AdminContratDetailScreen(contratId: contrat['id'] as int),
              ));
              _loadData();
            },
          );
        },
      ),
    );
  }
}

class _ContratCard extends StatelessWidget {
  final Map<String, dynamic> contrat;
  final VoidCallback onTap;

  const _ContratCard({required this.contrat, required this.onTap});

  String _snapshotLabel(Map<String, dynamic> c, String type) {
    if (type == 'ACHAT' && c['snapPrix'] != null) {
      return AppFormatters.formatCurrencyShort((c['snapPrix'] as num).toDouble());
    }
    if (type == 'LOCATION' && c['snapMensualite'] != null) {
      return AppFormatters.formatRent((c['snapMensualite'] as num).toDouble());
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final statut = contrat['statut'] as String? ?? '';
    final type = contrat['type'] as String? ?? '';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: type == 'ACHAT' ? AppColors.blue100 : AppColors.slate100,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  type == 'ACHAT' ? Icons.shopping_cart_outlined : Icons.vpn_key_outlined,
                  size: 20,
                  color: type == 'ACHAT' ? AppColors.blue500 : AppColors.slate700,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppFormatters.formatContratId(contrat['id'] as int),
                          style: AppTextStyles.textMd.w600,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBg(statut.toLowerCase()),
                            borderRadius: AppRadius.fullAll,
                          ),
                          child: Text(statut,
                              style: AppTextStyles.textSm.w600.withColor(AppColors.badgeText(statut.toLowerCase()))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: type == 'ACHAT' ? AppColors.blue500 : AppColors.slate900,
                            borderRadius: AppRadius.fullAll,
                          ),
                          child: Text(type == 'ACHAT' ? 'Achat' : 'Location',
                              style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
                        ),
                        if (_snapshotLabel(contrat, type).isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(_snapshotLabel(contrat, type),
                              style: AppTextStyles.textSm.w600.withColor(AppColors.blue500)),
                        ],
                        if (contrat['dateCreation'] != null) ...[
                          const SizedBox(width: 8),
                          Text(AppFormatters.formatDateString(contrat['dateCreation'] as String?),
                              style: AppTextStyles.textSm.w400.withColor(AppColors.slate400)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.slate400),
            ],
          ),
        ),
      ),
    );
  }
}
