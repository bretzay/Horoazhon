import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../config/app_formatters.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state.dart';
import '../property_detail_screen.dart';
import 'admin_bien_form_screen.dart';
import 'admin_contrats_screen.dart';
import 'admin_personne_form_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _api = ApiService();

  int _bienCount = 0;
  int _contratCount = 0;
  int _personneCount = 0;
  int _agenceCount = 0;
  List<dynamic> _recentBiens = [];
  List<dynamic> _recentContrats = [];
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

      // Sequential calls — concurrent requests via 10.0.2.2 bridge stall on emulator
      final biensData = await _api.getBiens(size: 5);
      final contratsData = await _api.getContrats(size: 5);
      final personnes = await _api.getPersonnes();

      List<dynamic>? agences;
      if (auth.isSuperAdmin) {
        agences = await _api.getAgences();
      }

      if (mounted) {
        setState(() {
          _recentBiens = biensData['content'] as List? ?? [];
          _bienCount = biensData['totalElements'] as int? ?? _recentBiens.length;
          _recentContrats = contratsData['content'] as List? ?? [];
          _contratCount = contratsData['totalElements'] as int? ?? _recentContrats.length;
          _personneCount = personnes.length;
          if (agences != null) {
            _agenceCount = agences.length;
          }
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
          // Welcome header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bonjour, ${auth.prenom ?? ''}', style: AppTextStyles.textXl.w700),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      auth.agenceNom ?? 'Administration',
                      style: AppTextStyles.textMd.w400.withColor(AppColors.slate500),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  _roleLabel(auth.role),
                  style: AppTextStyles.textSm.w600.withColor(AppColors.white),
                ),
                backgroundColor: AppColors.roleColor(auth.role ?? ''),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space6),

          // Stat cards grid
          _buildStatGrid(auth),

          const SizedBox(height: AppSpacing.space6),

          // Quick actions
          Text('Actions rapides', style: AppTextStyles.textLg.w600),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              _QuickAction(icon: Icons.add_home_outlined, label: 'Nouveau bien', onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBienFormScreen()));
                _loadData();
              }),
              const SizedBox(width: AppSpacing.space3),
              _QuickAction(icon: Icons.description_outlined, label: 'Voir contrats', onTap: () {
                // Contracts are created from property detail — navigate to list instead
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminContratsScreen(showAppBar: true)));
              }),
              const SizedBox(width: AppSpacing.space3),
              _QuickAction(icon: Icons.person_add_outlined, label: 'Nouvelle personne', onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPersonneFormScreen()));
                _loadData();
              }),
            ],
          ),

          const SizedBox(height: AppSpacing.space8),

          // Recent properties
          Text('Biens récents', style: AppTextStyles.textLg.w600),
          const SizedBox(height: AppSpacing.space3),
          ..._recentBiens.map((b) {
            final bien = b as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: Card(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PropertyDetailScreen(bienId: bien['id'] as int)),
                  ),
                  borderRadius: AppRadius.lgAll,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space3),
                    child: Row(
                      children: [
                        Text(
                          AppFormatters.formatBienId(bien['id'] as int),
                          style: AppTextStyles.textSm.w600.withColor(AppColors.slate400),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Text(
                            '${bien['type'] ?? ''} - ${bien['ville'] ?? ''}',
                            style: AppTextStyles.textMd.w500,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 20, color: AppColors.slate400),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: AppSpacing.space6),

          // Recent contracts
          Text('Contrats récents', style: AppTextStyles.textLg.w600),
          const SizedBox(height: AppSpacing.space3),
          ..._recentContrats.map((c) {
            final contrat = c as Map<String, dynamic>;
            final statut = contrat['statut'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  child: Row(
                    children: [
                      Text(
                        AppFormatters.formatContratId(contrat['id'] as int),
                        style: AppTextStyles.textSm.w600.withColor(AppColors.slate400),
                      ),
                      const SizedBox(width: AppSpacing.space3),
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
                      const Spacer(),
                      if (contrat['dateCreation'] != null)
                        Text(contrat['dateCreation'], style: AppTextStyles.textSm.w400),
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

  Widget _buildStatGrid(AuthProvider auth) {
    final stats = <_StatData>[
      _StatData(Icons.apartment, 'Biens', _bienCount, 0),
      _StatData(Icons.description_outlined, 'Contrats', _contratCount, 1),
      _StatData(Icons.people_outlined, 'Personnes', _personneCount, 2),
      if (auth.isSuperAdmin)
        _StatData(Icons.business_outlined, 'Agences', _agenceCount, 3),
    ];

    return Wrap(
      spacing: AppSpacing.space3,
      runSpacing: AppSpacing.space3,
      children: stats.map((s) => SizedBox(
        width: (MediaQuery.of(context).size.width - AppSpacing.space4 * 2 - AppSpacing.space3) / 2,
        child: _StatCard(icon: s.icon, label: s.label, value: s.value, variant: s.variant),
      )).toList(),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'SUPER_ADMIN': return 'Super Admin';
      case 'ADMIN_AGENCY': return 'Admin';
      case 'AGENT': return 'Agent';
      default: return '';
    }
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final int value;
  final int variant;
  _StatData(this.icon, this.label, this.value, this.variant);
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
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
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border(left: BorderSide(color: colors.leftBorder, width: 3)),
        boxShadow: const [BoxShadow(offset: Offset(0, 2), blurRadius: 8, color: AppColors.shadowColor)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: colors.iconBg, borderRadius: AppRadius.mdAll),
            child: Icon(icon, size: 20, color: colors.leftBorder),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text('$value', style: AppTextStyles.textXl.w700.withColor(colors.numberColor)),
          Text(label, style: AppTextStyles.textSm.w400),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.blue100, borderRadius: AppRadius.mdAll),
                  child: Icon(icon, size: 20, color: AppColors.blue500),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(label, style: AppTextStyles.textSm.w500, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
