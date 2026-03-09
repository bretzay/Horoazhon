import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../config/app_formatters.dart';
import '../../services/api_service.dart';
import '../../widgets/error_state.dart';
import 'admin_personne_form_screen.dart';

class AdminContratDetailScreen extends StatefulWidget {
  final int contratId;

  const AdminContratDetailScreen({super.key, required this.contratId});

  @override
  State<AdminContratDetailScreen> createState() => _AdminContratDetailScreenState();
}

class _AdminContratDetailScreenState extends State<AdminContratDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _contrat;
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
      final data = await _api.getContratById(widget.contratId);
      if (mounted) setState(() { _contrat = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppFormatters.formatContratId(widget.contratId)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_contrat == null) return const SizedBox.shrink();

    final contrat = _contrat!;
    final statut = contrat['statut'] as String? ?? '';
    final type = contrat['type'] as String? ?? '';
    final cosigners = contrat['cosigners'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                children: [
                  Text(AppFormatters.formatContratId(widget.contratId),
                      style: AppTextStyles.textXl.w700),
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBg(statut.toLowerCase()),
                          borderRadius: AppRadius.fullAll,
                        ),
                        child: Text(statut,
                            style: AppTextStyles.textSm.w600.withColor(AppColors.badgeText(statut.toLowerCase()))),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: type == 'ACHAT' ? AppColors.blue500 : AppColors.slate900,
                          borderRadius: AppRadius.fullAll,
                        ),
                        child: Text(type, style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space4),

          // Dates
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dates', style: AppTextStyles.textMd.w600),
                  const SizedBox(height: AppSpacing.space2),
                  if (contrat['dateCreation'] != null)
                    _InfoRow('Création', AppFormatters.formatDateString(contrat['dateCreation'] as String?)),
                  if (contrat['dateModification'] != null)
                    _InfoRow('Modification', AppFormatters.formatDateString(contrat['dateModification'] as String?)),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space4),

          // Cosigners
          Text('Cosignataires (${cosigners.length})', style: AppTextStyles.textLg.w600),
          const SizedBox(height: AppSpacing.space2),
          ...cosigners.map((c) {
            final cos = c as Map<String, dynamic>;
            final personneId = cos['personneId'] as int?;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: Card(
                child: InkWell(
                  onTap: personneId != null
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminPersonneFormScreen(personneId: personneId),
                            ),
                          )
                      : null,
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
                              Text('${cos['prenom'] ?? ''} ${cos['nom'] ?? ''}',
                                  style: AppTextStyles.textMd.w500),
                              Text(_signatairLabel(cos['typeSignataire'] as String? ?? ''),
                                  style: AppTextStyles.textSm.w400.withColor(AppColors.slate500)),
                            ],
                          ),
                        ),
                        if (personneId != null)
                          const Icon(Icons.chevron_right, size: 20, color: AppColors.slate400),
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

  String _signatairLabel(String type) {
    switch (type) {
      case 'BUYER': return 'Acheteur';
      case 'SELLER': return 'Vendeur';
      case 'RENTER': return 'Locataire';
      case 'OWNER': return 'Propriétaire';
      default: return type;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.textMd.w400),
          Text(value, style: AppTextStyles.textMd.w600),
        ],
      ),
    );
  }
}
