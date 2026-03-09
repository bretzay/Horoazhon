import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../config/app_formatters.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/error_state.dart';
import 'admin/admin_bien_form_screen.dart';
import 'admin/admin_contrat_form_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int bienId;

  const PropertyDetailScreen({super.key, required this.bienId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _bien;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.getBienById(widget.bienId);
      if (mounted) setState(() { _bien = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur de chargement'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.hasAdminNav;

    return Scaffold(
      appBar: AppBar(
        title: Text(_bien != null ? AppFormatters.formatBienId(widget.bienId) : 'Bien'),
        actions: [
          if (isAdmin && _bien != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminBienFormScreen(bienId: widget.bienId)),
                );
                _loadData();
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _loadData);
    }
    if (_bien == null) return const SizedBox.shrink();

    final bien = _bien!;
    final photos = bien['photos'] as List? ?? [];
    final caracs = bien['caracteristiques'] as List? ?? [];
    final lieux = bien['lieux'] as List? ?? [];
    final isForSale = bien['availableForSale'] == true;
    final isForRent = bien['availableForRent'] == true;
    final prixVente = bien['salePrice'];
    final loyerMensuel = bien['monthlyRent'];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          // Photo carousel
          if (photos.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 250,
                viewportFraction: 1.0,
                enableInfiniteScroll: photos.length > 1,
              ),
              items: photos.map<Widget>((photo) {
                final p = photo as Map<String, dynamic>;
                return Image.network(
                  p['chemin'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.slate100,
                    child: const Center(child: Icon(Icons.image_outlined, size: 48, color: AppColors.slate400)),
                  ),
                );
              }).toList(),
            )
          else
            Container(
              height: 200,
              color: AppColors.slate100,
              child: const Center(child: Icon(Icons.image_outlined, size: 48, color: AppColors.slate400)),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge + ID
                Row(
                  children: [
                    if (isForSale)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(color: AppColors.blue500, borderRadius: AppRadius.fullAll),
                        child: Text('Vente', style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
                      ),
                    if (isForRent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(color: AppColors.slate900, borderRadius: AppRadius.fullAll),
                        child: Text('Location', style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
                      ),
                    const SizedBox(width: AppSpacing.space1),
                    Text(
                      bien['type'] ?? '',
                      style: AppTextStyles.textSm.w500.withColor(AppColors.slate500),
                    ),
                    const Spacer(),
                    Text(
                      AppFormatters.formatBienId(widget.bienId),
                      style: AppTextStyles.textSm.w500.withColor(AppColors.slate400),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.space4),

                // Price
                if (prixVente != null)
                  Text(
                    AppFormatters.formatCurrency((prixVente as num).toDouble()),
                    style: AppTextStyles.textXl.w700.withColor(AppColors.slate900),
                  ),
                if (loyerMensuel != null)
                  Text(
                    AppFormatters.formatRent((loyerMensuel as num).toDouble()),
                    style: AppTextStyles.textXl.w700.withColor(AppColors.slate900),
                  ),

                const SizedBox(height: AppSpacing.space4),

                // Location + area
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: AppColors.slate500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${bien['rue'] ?? ''}, ${bien['codePostal'] ?? ''} ${bien['ville'] ?? ''}'.trim(),
                        style: AppTextStyles.textMd.w400.withColor(AppColors.slate700),
                      ),
                    ),
                  ],
                ),
                if (bien['superficie'] != null) ...[
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    children: [
                      const Icon(Icons.square_foot, size: 18, color: AppColors.slate500),
                      const SizedBox(width: 4),
                      Text(
                        AppFormatters.formatArea((bien['superficie'] as num).toDouble()),
                        style: AppTextStyles.textMd.w400,
                      ),
                    ],
                  ),
                ],
                if (bien['ecoScore'] != null) ...[
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    children: [
                      const Icon(Icons.eco, size: 18, color: AppColors.slate500),
                      const SizedBox(width: 4),
                      Text(
                        'Score éco: ${bien['ecoScore']}',
                        style: AppTextStyles.textMd.w400,
                      ),
                    ],
                  ),
                ],

                // Description
                if (bien['description'] != null && (bien['description'] as String).isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space6),
                  Text('Description', style: AppTextStyles.textLg.w600),
                  const SizedBox(height: AppSpacing.space2),
                  Text(bien['description'], style: AppTextStyles.textMd.w400),
                ],

                // Characteristics
                if (caracs.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space6),
                  Text('Caractéristiques', style: AppTextStyles.textLg.w600),
                  const SizedBox(height: AppSpacing.space2),
                  ...caracs.map<Widget>((c) {
                    final carac = c as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(carac['lib'] ?? '', style: AppTextStyles.textMd.w400),
                          Text('${carac['valeur'] ?? ''}', style: AppTextStyles.textMd.w600),
                        ],
                      ),
                    );
                  }),
                ],

                // Proximity
                if (lieux.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space6),
                  Text('Proximité', style: AppTextStyles.textLg.w600),
                  const SizedBox(height: AppSpacing.space2),
                  ...lieux.map<Widget>((l) {
                    final lieu = l as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(lieu['lib'] ?? '', style: AppTextStyles.textMd.w400)),
                          Text(
                            '${lieu['minutes'] ?? ''} min',
                            style: AppTextStyles.textMd.w500.withColor(AppColors.blue500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _locomotionLabel(lieu['typeLocomotion'] as String? ?? ''),
                            style: AppTextStyles.textSm.w400,
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Agency card
                if (bien['agence'] != null) ...[
                  const SizedBox(height: AppSpacing.space6),
                  Text('Agence', style: AppTextStyles.textLg.w600),
                  const SizedBox(height: AppSpacing.space2),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.blue100,
                              borderRadius: AppRadius.mdAll,
                            ),
                            child: const Icon(Icons.business_outlined, color: AppColors.blue500),
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (bien['agence'] as Map<String, dynamic>)['nom'] ?? '',
                                  style: AppTextStyles.textMd.w600,
                                ),
                                if ((bien['agence'] as Map<String, dynamic>)['telephone'] != null)
                                  Text(
                                    (bien['agence'] as Map<String, dynamic>)['telephone'],
                                    style: AppTextStyles.textSm.w400,
                                  ),
                              ],
                            ),
                          ),
                          if ((bien['agence'] as Map<String, dynamic>)['telephone'] != null)
                            IconButton(
                              icon: const Icon(Icons.phone_outlined, color: AppColors.blue500),
                              onPressed: () {
                                final phone = (bien['agence'] as Map<String, dynamic>)['telephone'];
                                launchUrl(Uri.parse('tel:$phone'));
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Create contract button (admin/agent only)
                if (context.read<AuthProvider>().hasAdminNav && (isForSale || isForRent)) ...[
                  const SizedBox(height: AppSpacing.space6),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminContratFormScreen(
                              bienId: widget.bienId,
                              isForSale: isForSale,
                              isForRent: isForRent,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      },
                      icon: const Icon(Icons.note_add_outlined),
                      label: const Text('Créer un contrat'),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.space8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _locomotionLabel(String loco) {
    switch (loco) {
      case 'A_PIED': return 'à pied';
      case 'VELO': return 'vélo';
      case 'TRANSPORT_PUBLIC': return 'transport';
      case 'VOITURE': return 'voiture';
      default: return loco;
    }
  }
}
