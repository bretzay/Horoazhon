import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import 'agency_detail_screen.dart';

class AgencyListScreen extends StatefulWidget {
  final bool showAppBar;

  const AgencyListScreen({super.key, this.showAppBar = false});

  @override
  State<AgencyListScreen> createState() => _AgencyListScreenState();
}

class _AgencyListScreenState extends State<AgencyListScreen> {
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();

  List<dynamic> _agencies = [];
  List<dynamic> _filteredAgencies = [];
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
      final data = await _api.getAgences();
      if (mounted) {
        setState(() {
          _agencies = data;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredAgencies = List.from(_agencies);
    } else {
      _filteredAgencies = _agencies.where((a) {
        final agence = a as Map<String, dynamic>;
        final nom = (agence['nom'] ?? '').toString().toLowerCase();
        final ville = (agence['ville'] ?? '').toString().toLowerCase();
        return nom.contains(query) || ville.contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildBody();
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nos agences')),
        body: content,
      );
    }
    return content;
  }

  Widget _buildBody() {
    if (_isLoading) return const ShimmerLoading();
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Rechercher une agence...',
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (value) {
              setState(() => _applyFilter());
            },
          ),
        ),

        // List
        Expanded(
          child: _filteredAgencies.isEmpty
              ? const EmptyState(
                  icon: Icons.business_outlined,
                  title: 'Aucune agence trouvée',
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                    itemCount: _filteredAgencies.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
                    itemBuilder: (context, index) {
                      final agence = _filteredAgencies[index] as Map<String, dynamic>;
                      return _AgencyListCard(
                        agence: agence,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AgencyDetailScreen(agenceId: agence['id'] as int),
                          ),
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

class _AgencyListCard extends StatelessWidget {
  final Map<String, dynamic> agence;
  final VoidCallback onTap;

  const _AgencyListCard({required this.agence, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nom = agence['nom'] ?? '';
    final ville = agence['ville'] ?? '';
    final telephone = agence['telephone'];
    final logo = agence['logo'] as String?;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: AppRadius.mdAll,
                ),
                child: logo != null
                    ? ClipRRect(
                        borderRadius: AppRadius.mdAll,
                        child: Image.network(logo, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.business_outlined, color: AppColors.blue500)),
                      )
                    : const Icon(Icons.business_outlined, color: AppColors.blue500),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nom, style: AppTextStyles.textMd.w600),
                    if (ville.isNotEmpty)
                      Text(ville, style: AppTextStyles.textSm.w400),
                    if (telephone != null)
                      Text(telephone, style: AppTextStyles.textSm.w400.withColor(AppColors.slate400)),
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
