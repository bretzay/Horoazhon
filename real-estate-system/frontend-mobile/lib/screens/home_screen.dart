import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../config/app_formatters.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();

  List<dynamic> _featuredBiens = [];
  List<dynamic> _agencies = [];
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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getBiens(size: 6),
        _api.getAgences(),
      ]);
      if (mounted) {
        setState(() {
          _featuredBiens = (results[0] as Map<String, dynamic>)['content'] as List? ?? [];
          _agencies = results[1] as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur de chargement';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ShimmerLoading(itemCount: 4);
    }

    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _loadData);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          // Hero
          _buildHero(),
          const SizedBox(height: AppSpacing.space6),

          // Search bar
          _buildSearchBar(),
          const SizedBox(height: AppSpacing.space8),

          // Featured properties
          if (_featuredBiens.isNotEmpty) ...[
            _buildSectionHeader('Biens en vedette', 'Voir tout', () {
              // Navigate to property list tab (index 1)
            }),
            const SizedBox(height: AppSpacing.space4),
            _buildPropertyCarousel(),
            const SizedBox(height: AppSpacing.space8),
          ],

          // Agencies
          if (_agencies.isNotEmpty) ...[
            _buildSectionHeader('Nos agences', 'Voir tout', () {
              // Navigate to agencies tab (index 2)
            }),
            const SizedBox(height: AppSpacing.space4),
            _buildAgencyCarousel(),
            const SizedBox(height: AppSpacing.space8),
          ],

          // Quick actions
          _buildQuickActions(),
          const SizedBox(height: AppSpacing.space4),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horoazhon',
            style: AppTextStyles.textXl.w800.withColor(AppColors.white),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Gestion immobilière simplifiée',
            style: AppTextStyles.textMd.w400.withColor(AppColors.blue100),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher un bien...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            // TODO: Navigate to property list with search query
          },
        ),
      ),
      onSubmitted: (value) {
        // TODO: Navigate to property list with search query
      },
    );
  }

  Widget _buildSectionHeader(String title, String actionText, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.textLg.w700),
        TextButton(
          onPressed: onAction,
          child: Text(actionText),
        ),
      ],
    );
  }

  Widget _buildPropertyCarousel() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredBiens.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.space4),
        itemBuilder: (context, index) {
          final bien = _featuredBiens[index] as Map<String, dynamic>;
          return _PropertyCard(bien: bien);
        },
      ),
    );
  }

  Widget _buildAgencyCarousel() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _agencies.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.space4),
        itemBuilder: (context, index) {
          final agence = _agencies[index] as Map<String, dynamic>;
          return _AgencyCard(agence: agence);
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.apartment,
            label: 'Voir les biens',
            onTap: () {
              // TODO: Navigate to property list
            },
          ),
        ),
        const SizedBox(width: AppSpacing.space4),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.location_on_outlined,
            label: 'Voir les agences',
            onTap: () {
              // TODO: Navigate to agency list
            },
          ),
        ),
      ],
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Map<String, dynamic> bien;

  const _PropertyCard({required this.bien});

  @override
  Widget build(BuildContext context) {
    final photos = bien['photos'] as List? ?? [];
    final hasPhoto = photos.isNotEmpty;
    final prix = bien['prixVente'] ?? bien['loyerMensuel'];
    final isForSale = bien['prixVente'] != null;
    final ville = bien['ville'] ?? '';
    final superficie = bien['superficie'];

    return SizedBox(
      width: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo or placeholder
            Container(
              height: 120,
              width: double.infinity,
              color: AppColors.slate100,
              child: hasPhoto
                  ? Image.network(
                      (photos[0] as Map<String, dynamic>)['chemin'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _PhotoPlaceholder(),
                    )
                  : const _PhotoPlaceholder(),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isForSale ? AppColors.blue500 : AppColors.slate900,
                      borderRadius: AppRadius.fullAll,
                    ),
                    child: Text(
                      isForSale ? 'Vente' : 'Location',
                      style: AppTextStyles.textSm.w600.withColor(AppColors.white),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  if (prix != null)
                    Text(
                      isForSale
                          ? AppFormatters.formatCurrencyShort((prix as num).toDouble())
                          : AppFormatters.formatRent((prix as num).toDouble()),
                      style: AppTextStyles.textMd.w700.withColor(AppColors.slate900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.slate400),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          ville,
                          style: AppTextStyles.textSm.w400,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
          ],
        ),
      ),
    );
  }
}

class _AgencyCard extends StatelessWidget {
  final Map<String, dynamic> agence;

  const _AgencyCard({required this.agence});

  @override
  Widget build(BuildContext context) {
    final nom = agence['nom'] ?? '';
    final ville = agence['ville'] ?? '';
    final logo = agence['logo'] as String?;

    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: AppRadius.mdAll,
                ),
                child: logo != null
                    ? ClipRRect(
                        borderRadius: AppRadius.mdAll,
                        child: Image.network(logo, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.business_outlined,
                                color: AppColors.blue500)),
                      )
                    : const Icon(Icons.business_outlined, color: AppColors.blue500),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                nom,
                style: AppTextStyles.textMd.w600,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                ville,
                style: AppTextStyles.textSm.w400,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space5),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(icon, size: 24, color: AppColors.blue500),
              ),
              const SizedBox(height: AppSpacing.space3),
              Text(label, style: AppTextStyles.textMd.w600, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image_outlined, size: 32, color: AppColors.slate400),
    );
  }
}
