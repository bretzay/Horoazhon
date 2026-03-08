import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../config/app_formatters.dart';
import '../services/api_service.dart';
import '../widgets/error_state.dart';
import 'property_detail_screen.dart';

class AgencyDetailScreen extends StatefulWidget {
  final int agenceId;

  const AgencyDetailScreen({super.key, required this.agenceId});

  @override
  State<AgencyDetailScreen> createState() => _AgencyDetailScreenState();
}

class _AgencyDetailScreenState extends State<AgencyDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _agence;
  List<dynamic> _biens = [];
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
        _api.getAgenceById(widget.agenceId),
        _api.getAgenceBiens(widget.agenceId, size: 20),
      ]);
      if (mounted) {
        setState(() {
          _agence = results[0] as Map<String, dynamic>;
          _biens = (results[1] as Map<String, dynamic>)['content'] as List? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_agence?['nom'] ?? 'Agence'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_agence == null) return const SizedBox.shrink();

    final agence = _agence!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.blue100,
                      borderRadius: AppRadius.lgAll,
                    ),
                    child: agence['logo'] != null
                        ? ClipRRect(
                            borderRadius: AppRadius.lgAll,
                            child: Image.network(agence['logo'], fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.business_outlined, size: 32, color: AppColors.blue500)),
                          )
                        : const Icon(Icons.business_outlined, size: 32, color: AppColors.blue500),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Text(agence['nom'] ?? '', style: AppTextStyles.textLg.w700, textAlign: TextAlign.center),
                  if (agence['description'] != null && (agence['description'] as String).isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space2),
                    Text(agence['description'], style: AppTextStyles.textMd.w400, textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space4),

          // Contact info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact', style: AppTextStyles.textMd.w600),
                  const SizedBox(height: AppSpacing.space3),
                  if (agence['adresse'] != null)
                    _InfoRow(Icons.location_on_outlined, agence['adresse']),
                  if (agence['ville'] != null)
                    _InfoRow(Icons.location_city, '${agence['codePostal'] ?? ''} ${agence['ville']}'),
                  if (agence['telephone'] != null)
                    _InfoRow(Icons.phone_outlined, agence['telephone'], onTap: () {
                      launchUrl(Uri.parse('tel:${agence['telephone']}'));
                    }),
                  if (agence['email'] != null)
                    _InfoRow(Icons.email_outlined, agence['email'], onTap: () {
                      launchUrl(Uri.parse('mailto:${agence['email']}'));
                    }),
                  if (agence['siret'] != null)
                    _InfoRow(Icons.badge_outlined, 'SIRET: ${agence['siret']}'),
                  if (agence['tva'] != null)
                    _InfoRow(Icons.receipt_outlined, 'TVA: ${agence['tva']}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space6),

          // Agency properties
          Text('Biens de l\'agence (${_biens.length})', style: AppTextStyles.textLg.w600),
          const SizedBox(height: AppSpacing.space3),

          if (_biens.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Center(
                  child: Text(
                    'Aucun bien pour cette agence',
                    style: AppTextStyles.textMd.w400.withColor(AppColors.slate400),
                  ),
                ),
              ),
            )
          else
            ..._biens.map((b) {
              final bien = b as Map<String, dynamic>;
              final prix = bien['prixVente'] ?? bien['loyerMensuel'];
              final isForSale = bien['prixVente'] != null;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(bienId: bien['id'] as int),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space3),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isForSale ? AppColors.blue500 : AppColors.slate900,
                              borderRadius: AppRadius.fullAll,
                            ),
                            child: Text(
                              isForSale ? 'V' : 'L',
                              style: AppTextStyles.textSm.w600.withColor(AppColors.white),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${bien['type'] ?? ''} - ${bien['ville'] ?? ''}',
                                  style: AppTextStyles.textMd.w500,
                                ),
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
                          const Icon(Icons.chevron_right, color: AppColors.slate400),
                        ],
                      ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _InfoRow(this.icon, this.text, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.slate500),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textMd.w400.withColor(
                onTap != null ? AppColors.blue500 : AppColors.slate700,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }
    return content;
  }
}
