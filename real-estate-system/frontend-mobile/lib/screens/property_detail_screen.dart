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
    if (!mounted) return;
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

  Future<void> _toggleArchive() async {
    if (_bien == null) return;
    final isActif = _bien!['actif'] as bool? ?? true;
    try {
      if (isActif) {
        await _api.archiveBien(widget.bienId);
      } else {
        await _api.unarchiveBien(widget.bienId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isActif ? 'Bien archivé' : 'Bien désarchivé')),
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
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.hasAdminNav;

    return Scaffold(
      appBar: AppBar(
        title: Text(_bien != null ? AppFormatters.formatBienId(widget.bienId) : 'Bien'),
        actions: [
          if (isAdmin && _bien != null) ...[
            IconButton(
              icon: Icon(
                (_bien!['actif'] as bool? ?? true) ? Icons.archive_outlined : Icons.unarchive_outlined,
              ),
              tooltip: (_bien!['actif'] as bool? ?? true) ? 'Archiver' : 'Désarchiver',
              onPressed: () => _toggleArchive(),
            ),
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
    final isAdmin = context.read<AuthProvider>().hasAdminNav;
    final location = bien['location'] as Map<String, dynamic>?;
    final achat = bien['achat'] as Map<String, dynamic>?;
    final isActif = bien['actif'] as bool? ?? true;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          // Archive status banner
          if (!isActif)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
              color: AppColors.slate100,
              child: Row(
                children: [
                  const Icon(Icons.archive_outlined, size: 16, color: AppColors.slate700),
                  const SizedBox(width: AppSpacing.space2),
                  Text('Ce bien est archivé', style: AppTextStyles.textSm.w600.withColor(AppColors.slate700)),
                ],
              ),
            ),

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
                        'Éco-score : ${bien['ecoScore']}',
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

                // Offers section (Location / Achat) — admin editable
                const SizedBox(height: AppSpacing.space6),
                _sectionHeader('Offres', isAdmin ? () => _showEditOfferSheet(bien) : null, editIcon: true),
                const SizedBox(height: AppSpacing.space2),
                if (!isForSale && !isForRent)
                  Text('Aucune offre active', style: AppTextStyles.textMd.w400.withColor(AppColors.slate400))
                else ...[
                  if (achat != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.blue500, borderRadius: AppRadius.fullAll),
                              child: Text('Vente', style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
                            ),
                            const Spacer(),
                            Text(
                              AppFormatters.formatCurrency((achat['prix'] as num?)?.toDouble() ?? 0),
                              style: AppTextStyles.textMd.w700.withColor(AppColors.slate900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (location != null) ...[
                    if (achat != null) const SizedBox(height: AppSpacing.space2),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.slate900, borderRadius: AppRadius.fullAll),
                                  child: Text('Location', style: AppTextStyles.textSm.w600.withColor(AppColors.white)),
                                ),
                                const Spacer(),
                                Text(
                                  AppFormatters.formatCurrency((location['mensualite'] as num?)?.toDouble() ?? 0),
                                  style: AppTextStyles.textMd.w700.withColor(AppColors.slate900),
                                ),
                                Text('/mois', style: AppTextStyles.textSm.w400.withColor(AppColors.slate500)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            Row(
                              children: [
                                Text('Caution ', style: AppTextStyles.textSm.w400.withColor(AppColors.slate500)),
                                Text(
                                  AppFormatters.formatCurrency((location['caution'] as num?)?.toDouble() ?? 0),
                                  style: AppTextStyles.textSm.w600,
                                ),
                                const Spacer(),
                                Text('Durée ', style: AppTextStyles.textSm.w400.withColor(AppColors.slate500)),
                                Text('${location['dureeMois'] ?? '-'} mois', style: AppTextStyles.textSm.w600),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],

                // Characteristics — admin editable
                const SizedBox(height: AppSpacing.space6),
                _sectionHeader(
                  'Caractéristiques${caracs.isNotEmpty ? ' (${caracs.length})' : ''}',
                  isAdmin ? () => _showAddCaracteristiqueSheet() : null,
                ),
                const SizedBox(height: AppSpacing.space2),
                if (caracs.isEmpty)
                  Text('Aucune caractéristique', style: AppTextStyles.textMd.w400.withColor(AppColors.slate400))
                else
                  ...caracs.map<Widget>((c) {
                    final carac = c as Map<String, dynamic>;
                    return InkWell(
                      onTap: isAdmin ? () => _showEditCaracteristiqueSheet(carac) : null,
                      borderRadius: AppRadius.mdAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(carac['lib'] ?? '', style: AppTextStyles.textMd.w400),
                                  Text(
                                    '${carac['valeur'] ?? ''}${carac['unite'] != null ? ' ${carac['unite']}' : ''}',
                                    style: AppTextStyles.textMd.w600,
                                  ),
                                ],
                              ),
                            ),
                            if (isAdmin)
                              const Icon(Icons.chevron_right, size: 18, color: AppColors.slate400),
                          ],
                        ),
                      ),
                    );
                  }),

                // Proximity — admin editable
                const SizedBox(height: AppSpacing.space6),
                _sectionHeader(
                  'Proximité${lieux.isNotEmpty ? ' (${lieux.length})' : ''}',
                  isAdmin ? () => _showAddLieuSheet() : null,
                ),
                const SizedBox(height: AppSpacing.space2),
                if (lieux.isEmpty)
                  Text('Aucun lieu de proximité', style: AppTextStyles.textMd.w400.withColor(AppColors.slate400))
                else
                  ...lieux.map<Widget>((l) {
                    final lieu = l as Map<String, dynamic>;
                    return InkWell(
                      onTap: isAdmin ? () => _showEditLieuSheet(lieu) : null,
                      borderRadius: AppRadius.mdAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
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
                            ),
                            if (isAdmin)
                              const Icon(Icons.chevron_right, size: 18, color: AppColors.slate400),
                          ],
                        ),
                      ),
                    );
                  }),

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
                if (isAdmin && (isForSale || isForRent)) ...[
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
                              salePrice: prixVente != null ? (prixVente as num).toDouble() : null,
                              monthlyRent: loyerMensuel != null ? (loyerMensuel as num).toDouble() : null,
                              caution: location != null ? (location['caution'] as num?)?.toDouble() : null,
                              dureeMois: location != null ? location['dureeMois'] as int? : null,
                              dateDispo: (achat?['dateDispo'] ?? location?['dateDispo']) as String?,
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

  // --- Section header with optional edit button ---

  Widget _sectionHeader(String title, VoidCallback? onEdit, {bool editIcon = false}) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.textLg.w600)),
        if (onEdit != null)
          IconButton(
            icon: Icon(
              editIcon ? Icons.edit_outlined : Icons.add_circle_outline,
              size: 22,
              color: AppColors.blue500,
            ),
            visualDensity: VisualDensity.compact,
            tooltip: editIcon ? 'Modifier' : 'Ajouter',
            onPressed: onEdit,
          ),
      ],
    );
  }

  Widget _offerRow(String label, String value) {
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

  // --- Remove caractéristique ---

  Future<void> _removeCaracteristique(int caracId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Retirer cette caractéristique du bien ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.removeBienCaracteristique(widget.bienId, caracId);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  // --- Remove lieu ---

  Future<void> _removeLieu(int lieuId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Retirer ce lieu de proximité du bien ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.removeBienLieu(widget.bienId, lieuId);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  // --- Add caractéristique bottom sheet ---

  Future<void> _showAddCaracteristiqueSheet() async {
    List<dynamic>? allCaracs;
    try {
      allCaracs = await _api.getCaracteristiques();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de charger les caractéristiques')),
        );
      }
      return;
    }

    // Filter out already-added ones
    final existingIds = (_bien!['caracteristiques'] as List? ?? [])
        .map((c) => (c as Map<String, dynamic>)['caracteristiqueId'] as int)
        .toSet();
    final available = allCaracs!.where((c) => !existingIds.contains((c as Map<String, dynamic>)['id'])).toList();

    if (!mounted) return;

    int? selectedId;
    final valeurCtrl = TextEditingController();
    final uniteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final isValid = selectedId != null && valeurCtrl.text.trim().isNotEmpty;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.space4, AppSpacing.space4, AppSpacing.space4,
              MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.space4,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ajouter une caractéristique', style: AppTextStyles.textLg.w600),
                  const SizedBox(height: AppSpacing.space4),
                  if (available.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
                      child: Text(
                        'Toutes les caractéristiques sont déjà ajoutées',
                        style: AppTextStyles.textMd.w400.withColor(AppColors.slate500),
                      ),
                    )
                  else ...[
                    DropdownButtonFormField<int>(
                      value: selectedId,
                      hint: const Text('Sélectionner'),
                      isExpanded: true,
                      validator: (v) => v == null ? 'Champ requis' : null,
                      items: available.map<DropdownMenuItem<int>>((c) {
                        final carac = c as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: carac['id'] as int,
                          child: Text(carac['lib'] ?? carac['nom'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (v) => setSheetState(() => selectedId = v),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    TextFormField(
                      controller: valeurCtrl,
                      decoration: const InputDecoration(labelText: 'Valeur *'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    TextFormField(
                      controller: uniteCtrl,
                      decoration: const InputDecoration(labelText: 'Unité (optionnel)'),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: !isValid
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) return;
                                final id = selectedId!;
                                final valeur = valeurCtrl.text.trim();
                                final unite = uniteCtrl.text.trim().isEmpty ? null : uniteCtrl.text.trim();
                                Navigator.pop(ctx);
                                WidgetsBinding.instance.addPostFrameCallback((_) => _doAddCaracteristique(id, valeur, unite));
                              },
                        child: const Text('Ajouter'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        });
      },
    );
    valeurCtrl.dispose();
    uniteCtrl.dispose();
  }

  // --- Add lieu bottom sheet ---

  Future<void> _showAddLieuSheet() async {
    List<dynamic>? allLieux;
    try {
      allLieux = await _api.getLieux();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de charger les lieux')),
        );
      }
      return;
    }

    // Filter out already-added ones
    final existingIds = (_bien!['lieux'] as List? ?? [])
        .map((l) => (l as Map<String, dynamic>)['lieuId'] as int)
        .toSet();
    final available = allLieux!.where((l) => !existingIds.contains((l as Map<String, dynamic>)['id'])).toList();

    if (!mounted) return;

    int? selectedId;
    final minutesCtrl = TextEditingController();
    String locomotion = 'A_PIED';
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final isValid = selectedId != null && minutesCtrl.text.trim().isNotEmpty;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.space4, AppSpacing.space4, AppSpacing.space4,
              MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.space4,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ajouter un lieu de proximité', style: AppTextStyles.textLg.w600),
                  const SizedBox(height: AppSpacing.space4),
                  if (available.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
                      child: Text(
                        'Tous les lieux sont déjà ajoutés',
                        style: AppTextStyles.textMd.w400.withColor(AppColors.slate500),
                      ),
                    )
                  else ...[
                    DropdownButtonFormField<int>(
                      value: selectedId,
                      hint: const Text('Sélectionner un lieu'),
                      isExpanded: true,
                      validator: (v) => v == null ? 'Champ requis' : null,
                      items: available.map<DropdownMenuItem<int>>((l) {
                        final lieu = l as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: lieu['id'] as int,
                          child: Text(lieu['lib'] ?? lieu['nom'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (v) => setSheetState(() => selectedId = v),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    TextFormField(
                      controller: minutesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Minutes *'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Champ requis';
                        if (int.tryParse(v.trim()) == null) return 'Nombre invalide';
                        return null;
                      },
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    DropdownButtonFormField<String>(
                      value: locomotion,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Type de locomotion'),
                      items: const [
                        DropdownMenuItem(value: 'A_PIED', child: Text('À pied')),
                        DropdownMenuItem(value: 'VELO', child: Text('Vélo')),
                        DropdownMenuItem(value: 'TRANSPORT_PUBLIC', child: Text('Transport public')),
                        DropdownMenuItem(value: 'VOITURE', child: Text('Voiture')),
                      ],
                      onChanged: (v) => setSheetState(() => locomotion = v!),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: !isValid
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) return;
                                final id = selectedId!;
                                final mins = int.tryParse(minutesCtrl.text.trim()) ?? 0;
                                final loco = locomotion;
                                Navigator.pop(ctx);
                                WidgetsBinding.instance.addPostFrameCallback((_) => _doAddLieu(id, mins, loco));
                              },
                        child: const Text('Ajouter'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        });
      },
    );
    minutesCtrl.dispose();
  }

  // --- Edit offer bottom sheet ---

  Future<void> _showEditOfferSheet(Map<String, dynamic> bien) async {
    final achat = bien['achat'] as Map<String, dynamic>?;
    final location = bien['location'] as Map<String, dynamic>?;

    bool saleOn = bien['availableForSale'] == true;
    bool rentOn = bien['availableForRent'] == true;

    final prixCtrl = TextEditingController(text: achat != null ? '${achat['prix'] ?? ''}' : '');
    final mensualiteCtrl = TextEditingController(text: location != null ? '${location['mensualite'] ?? ''}' : '');
    final cautionCtrl = TextEditingController(text: location != null ? '${location['caution'] ?? ''}' : '');
    final dureeCtrl = TextEditingController(text: location != null ? '${location['dureeMois'] ?? ''}' : '');

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.space4, AppSpacing.space4, AppSpacing.space4,
              MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.space4,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gérer les offres', style: AppTextStyles.textLg.w600),
                  const SizedBox(height: AppSpacing.space4),

                  // --- Vente ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: saleOn ? AppColors.blue500 : AppColors.slate200,
                          borderRadius: AppRadius.fullAll,
                        ),
                        child: Text('Vente', style: AppTextStyles.textSm.w600.withColor(saleOn ? AppColors.white : AppColors.slate500)),
                      ),
                      const Spacer(),
                      Switch(
                        value: saleOn,
                        onChanged: (v) => setSheetState(() => saleOn = v),
                        activeColor: AppColors.blue500,
                      ),
                    ],
                  ),
                  if (saleOn) ...[
                    const SizedBox(height: AppSpacing.space2),
                    TextFormField(
                      controller: prixCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Prix (EUR) *'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Champ requis';
                        if (double.tryParse(v.trim()) == null) return 'Montant invalide';
                        return null;
                      },
                      onChanged: (_) => setSheetState(() {}),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.space4),

                  // --- Location ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: rentOn ? AppColors.slate900 : AppColors.slate200,
                          borderRadius: AppRadius.fullAll,
                        ),
                        child: Text('Location', style: AppTextStyles.textSm.w600.withColor(rentOn ? AppColors.white : AppColors.slate500)),
                      ),
                      const Spacer(),
                      Switch(
                        value: rentOn,
                        onChanged: (v) => setSheetState(() => rentOn = v),
                        activeColor: AppColors.slate900,
                      ),
                    ],
                  ),
                  if (rentOn) ...[
                    const SizedBox(height: AppSpacing.space2),
                    TextFormField(
                      controller: mensualiteCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Mensualité (EUR) *'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Champ requis';
                        if (double.tryParse(v.trim()) == null) return 'Montant invalide';
                        return null;
                      },
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: cautionCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Caution (EUR) *'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Requis';
                              if (double.tryParse(v.trim()) == null) return 'Invalide';
                              return null;
                            },
                            onChanged: (_) => setSheetState(() {}),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: TextFormField(
                            controller: dureeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Durée (mois) *'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Requis';
                              if (int.tryParse(v.trim()) == null) return 'Invalide';
                              return null;
                            },
                            onChanged: (_) => setSheetState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSpacing.space4),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!saleOn && !rentOn)
                          ? () {
                              final data = _OfferSheetResult(
                                saleOn: false, rentOn: false,
                                prix: null, mensualite: null, caution: null, dureeMois: null,
                                existingAchatId: achat?['id'] as int?,
                                existingLocationId: location?['id'] as int?,
                              );
                              Navigator.pop(ctx);
                              WidgetsBinding.instance.addPostFrameCallback((_) => _doUpdateOffers(data));
                            }
                          : () {
                              if (!formKey.currentState!.validate()) return;
                              final data = _OfferSheetResult(
                                saleOn: saleOn,
                                rentOn: rentOn,
                                prix: double.tryParse(prixCtrl.text.trim()),
                                mensualite: double.tryParse(mensualiteCtrl.text.trim()),
                                caution: double.tryParse(cautionCtrl.text.trim()),
                                dureeMois: int.tryParse(dureeCtrl.text.trim()),
                                existingAchatId: achat?['id'] as int?,
                                existingLocationId: location?['id'] as int?,
                              );
                              Navigator.pop(ctx);
                              WidgetsBinding.instance.addPostFrameCallback((_) => _doUpdateOffers(data));
                            },
                      child: const Text('Enregistrer'),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
    prixCtrl.dispose();
    mensualiteCtrl.dispose();
    cautionCtrl.dispose();
    dureeCtrl.dispose();
  }

  // --- Edit caractéristique bottom sheet ---

  Future<void> _showEditCaracteristiqueSheet(Map<String, dynamic> carac) async {
    final caracId = carac['caracteristiqueId'] as int;
    final valeurCtrl = TextEditingController(text: '${carac['valeur'] ?? ''}');
    final uniteCtrl = TextEditingController(text: carac['unite'] as String? ?? '');
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final isValid = valeurCtrl.text.trim().isNotEmpty;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.space4, AppSpacing.space4, AppSpacing.space4,
              MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.space4,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(carac['lib'] ?? 'Caractéristique', style: AppTextStyles.textLg.w600),
                  const SizedBox(height: AppSpacing.space4),
                  TextFormField(
                    controller: valeurCtrl,
                    decoration: const InputDecoration(labelText: 'Valeur *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  TextFormField(
                    controller: uniteCtrl,
                    decoration: const InputDecoration(labelText: 'Unité (optionnel)'),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            WidgetsBinding.instance.addPostFrameCallback((_) => _removeCaracteristique(caracId));
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.slate500),
                          child: const Text('Supprimer'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: !isValid
                              ? null
                              : () {
                                  if (!formKey.currentState!.validate()) return;
                                  final valeur = valeurCtrl.text.trim();
                                  final unite = uniteCtrl.text.trim().isEmpty ? null : uniteCtrl.text.trim();
                                  Navigator.pop(ctx);
                                  WidgetsBinding.instance.addPostFrameCallback((_) => _doEditCaracteristique(caracId, valeur, unite));
                                },
                          child: const Text('Enregistrer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
    valeurCtrl.dispose();
    uniteCtrl.dispose();
  }

  // --- Edit lieu bottom sheet ---

  Future<void> _showEditLieuSheet(Map<String, dynamic> lieu) async {
    final lieuId = lieu['lieuId'] as int;
    final minutesCtrl = TextEditingController(text: '${lieu['minutes'] ?? ''}');
    String locomotion = lieu['typeLocomotion'] as String? ?? 'A_PIED';
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final isValid = minutesCtrl.text.trim().isNotEmpty;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.space4, AppSpacing.space4, AppSpacing.space4,
              MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.space4,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lieu['lib'] ?? 'Lieu', style: AppTextStyles.textLg.w600),
                  const SizedBox(height: AppSpacing.space4),
                  TextFormField(
                    controller: minutesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Minutes *'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Champ requis';
                      if (int.tryParse(v.trim()) == null) return 'Nombre invalide';
                      return null;
                    },
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  DropdownButtonFormField<String>(
                    value: locomotion,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Type de locomotion'),
                    items: const [
                      DropdownMenuItem(value: 'A_PIED', child: Text('À pied')),
                      DropdownMenuItem(value: 'VELO', child: Text('Vélo')),
                      DropdownMenuItem(value: 'TRANSPORT_PUBLIC', child: Text('Transport public')),
                      DropdownMenuItem(value: 'VOITURE', child: Text('Voiture')),
                    ],
                    onChanged: (v) => setSheetState(() => locomotion = v!),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            WidgetsBinding.instance.addPostFrameCallback((_) => _removeLieu(lieuId));
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.slate500),
                          child: const Text('Supprimer'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: !isValid
                              ? null
                              : () {
                                  if (!formKey.currentState!.validate()) return;
                                  final mins = int.tryParse(minutesCtrl.text.trim()) ?? 0;
                                  final loco = locomotion;
                                  Navigator.pop(ctx);
                                  WidgetsBinding.instance.addPostFrameCallback((_) => _doEditLieu(lieuId, mins, loco));
                                },
                          child: const Text('Enregistrer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
    minutesCtrl.dispose();
  }

  // --- Async edit helpers (remove + re-add) ---

  Future<void> _doEditCaracteristique(int caracId, String valeur, String? unite) async {
    try {
      await _api.removeBienCaracteristique(widget.bienId, caracId);
      await _api.addBienCaracteristique(widget.bienId, caracId, valeur, unite: unite);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _doEditLieu(int lieuId, int minutes, String locomotion) async {
    try {
      await _api.removeBienLieu(widget.bienId, lieuId);
      await _api.addBienLieu(widget.bienId, lieuId, minutes, typeLocomotion: locomotion);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _doAddCaracteristique(int caracId, String valeur, String? unite) async {
    try {
      await _api.addBienCaracteristique(widget.bienId, caracId, valeur, unite: unite);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _doAddLieu(int lieuId, int minutes, String locomotion) async {
    try {
      await _api.addBienLieu(widget.bienId, lieuId, minutes, typeLocomotion: locomotion);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _doUpdateOffers(_OfferSheetResult r) async {
    try {
      // Reload fresh data to get current offer IDs
      final fresh = await _api.getBienById(widget.bienId);
      final currentAchat = fresh['achat'] as Map<String, dynamic>?;
      final currentLocation = fresh['location'] as Map<String, dynamic>?;
      final currentAchatId = currentAchat?['id'] as int?;
      final currentLocationId = currentLocation?['id'] as int?;

      // Sale: create, update, or delete
      if (r.saleOn) {
        if (currentAchatId != null) {
          await _api.updateAchat(currentAchatId, {
            'bienId': widget.bienId,
            'prix': r.prix ?? 0,
          });
        } else {
          await _api.createAchat({
            'bienId': widget.bienId,
            'prix': r.prix ?? 0,
            'dateDispo': DateTime.now().toIso8601String().substring(0, 10),
          });
        }
      } else if (currentAchatId != null) {
        await _api.deleteAchat(currentAchatId);
      }

      // Rent: create, update, or delete
      if (r.rentOn) {
        if (currentLocationId != null) {
          await _api.updateLocation(currentLocationId, {
            'bienId': widget.bienId,
            'mensualite': r.mensualite ?? 0,
            'caution': r.caution ?? 0,
            'dureeMois': r.dureeMois ?? 12,
          });
        } else {
          await _api.createLocation({
            'bienId': widget.bienId,
            'mensualite': r.mensualite ?? 0,
            'caution': r.caution ?? 0,
            'dureeMois': r.dureeMois ?? 12,
            'dateDispo': DateTime.now().toIso8601String().substring(0, 10),
          });
        }
      } else if (currentLocationId != null) {
        await _api.deleteLocation(currentLocationId);
      }

      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offres mises à jour')),
        );
      }
    } catch (e) {
      _loadData();
      if (mounted) {
        final msg = e.toString();
        final userMsg = msg.contains('contrats')
            ? 'Impossible de supprimer : des contrats sont liés à cette offre'
            : 'Erreur: ${msg.replaceAll('Exception: ', '')}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userMsg)));
      }
    }
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

class _OfferSheetResult {
  final bool saleOn;
  final bool rentOn;
  final double? prix;
  final double? mensualite;
  final double? caution;
  final int? dureeMois;
  final int? existingAchatId;
  final int? existingLocationId;

  _OfferSheetResult({
    required this.saleOn,
    required this.rentOn,
    this.prix,
    this.mensualite,
    this.caution,
    this.dureeMois,
    this.existingAchatId,
    this.existingLocationId,
  });
}
