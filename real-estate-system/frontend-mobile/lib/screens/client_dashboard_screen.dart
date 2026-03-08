import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../config/app_formatters.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import 'property_detail_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  final ApiService _api = ApiService();

  List<dynamic> _biens = [];
  List<dynamic> _contrats = [];
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
      final results = await Future.wait([
        _api.getClientBiens(size: 5),
        _api.getClientContrats(size: 5),
      ]);
      if (mounted) {
        setState(() {
          _biens = (results[0])['content'] as List? ?? [];
          _contrats = (results[1])['content'] as List? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_isLoading) return const ShimmerLoading();
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          // Welcome
          Text(
            'Bonjour, ${auth.prenom ?? ''}',
            style: AppTextStyles.textXl.w700,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Votre espace client',
            style: AppTextStyles.textMd.w400.withColor(AppColors.slate500),
          ),

          const SizedBox(height: AppSpacing.space6),

          // Stat cards
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _StatCard(
                  icon: Icons.apartment,
                  label: 'Biens',
                  value: '${_biens.length}',
                  variant: 0,
                ),
                const SizedBox(width: AppSpacing.space3),
                _StatCard(
                  icon: Icons.description_outlined,
                  label: 'Contrats',
                  value: '${_contrats.length}',
                  variant: 1,
                ),
                const SizedBox(width: AppSpacing.space3),
                _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Actifs',
                  value: '${_contrats.where((c) => (c as Map)['statut'] == 'EN_COURS').length}',
                  variant: 2,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space8),

          // Recent properties
          Text('Mes biens récents', style: AppTextStyles.textLg.w600),
          const SizedBox(height: AppSpacing.space3),

          if (_biens.isEmpty)
            const EmptyState(
              icon: Icons.apartment,
              title: 'Aucun bien',
              subtitle: 'Vous n\'avez pas encore de biens',
            )
          else
            ..._biens.map((b) {
              final bien = b as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                child: Card(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(bienId: bien['id'] as int),
                      ),
                    ),
                    borderRadius: AppRadius.lgAll,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${bien['type'] ?? ''} - ${bien['ville'] ?? ''}',
                                  style: AppTextStyles.textMd.w600,
                                ),
                                Text(
                                  AppFormatters.formatBienId(bien['id'] as int),
                                  style: AppTextStyles.textSm.w400,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.slate400),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: AppSpacing.space6),

          // Recent contracts
          Text('Mes contrats récents', style: AppTextStyles.textLg.w600),
          const SizedBox(height: AppSpacing.space3),

          if (_contrats.isEmpty)
            const EmptyState(
              icon: Icons.description_outlined,
              title: 'Aucun contrat',
              subtitle: 'Vous n\'avez pas encore de contrats',
            )
          else
            ..._contrats.map((c) {
              final contrat = c as Map<String, dynamic>;
              final statut = contrat['statut'] as String? ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space3),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBg(statut.toLowerCase()),
                            borderRadius: AppRadius.fullAll,
                          ),
                          child: Text(
                            statut,
                            style: AppTextStyles.textSm.w600.withColor(
                              AppColors.badgeText(statut.toLowerCase()),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppFormatters.formatContratId(contrat['id'] as int),
                                style: AppTextStyles.textMd.w600,
                              ),
                              if (contrat['dateDebut'] != null)
                                Text(
                                  'Début: ${contrat['dateDebut']}',
                                  style: AppTextStyles.textSm.w400,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: AppSpacing.space4),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int variant;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.statVariants[variant % AppColors.statVariants.length];

    return Container(
      width: 130,
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border(
          left: BorderSide(color: colors.leftBorder, width: 3),
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8,
            color: AppColors.shadowColor,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.iconBg,
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(icon, size: 16, color: colors.leftBorder),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(value, style: AppTextStyles.textLg.w700.withColor(colors.numberColor)),
          Text(label, style: AppTextStyles.textSm.w400),
        ],
      ),
    );
  }
}
