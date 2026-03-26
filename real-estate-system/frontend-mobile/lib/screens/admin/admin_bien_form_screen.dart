import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_formatters.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../services/api_service.dart';
import 'admin_personne_form_screen.dart';

class AdminBienFormScreen extends StatefulWidget {
  final int? bienId;

  const AdminBienFormScreen({super.key, this.bienId});

  @override
  State<AdminBienFormScreen> createState() => _AdminBienFormScreenState();
}

class _AdminBienFormScreenState extends State<AdminBienFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _rueController = TextEditingController();
  final _villeController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _superficieController = TextEditingController();
  final _ecoScoreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ownerSearchController = TextEditingController();

  String _selectedType = 'APPARTEMENT';
  bool _isLoading = false;
  bool _isLoadingData = false;

  // Owner state
  Map<String, dynamic>? _selectedOwner; // {id, nom, prenom}
  List<dynamic> _ownerSearchResults = [];
  bool _isSearchingOwners = false;
  bool _showOwnerSearch = false;

  bool get isEditing => widget.bienId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadBien();
  }

  @override
  void dispose() {
    _rueController.dispose();
    _villeController.dispose();
    _codePostalController.dispose();
    _superficieController.dispose();
    _ecoScoreController.dispose();
    _descriptionController.dispose();
    _ownerSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadBien() async {
    setState(() => _isLoadingData = true);
    try {
      final bien = await _api.getBienById(widget.bienId!);
      _rueController.text = bien['rue'] ?? '';
      _villeController.text = bien['ville'] ?? '';
      _codePostalController.text = bien['codePostal'] ?? '';
      _superficieController.text = '${bien['superficie'] ?? ''}';
      _ecoScoreController.text = '${bien['ecoScore'] ?? ''}';
      _descriptionController.text = bien['description'] ?? '';
      _selectedType = bien['type'] ?? 'APPARTEMENT';

      // Load current owner
      final proprietaires = bien['proprietaires'] as List? ?? [];
      if (proprietaires.isNotEmpty) {
        final owner = proprietaires.first as Map<String, dynamic>;
        _selectedOwner = {
          'id': owner['personneId'],
          'nom': owner['nom'],
          'prenom': owner['prenom'],
        };
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de chargement')),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _searchOwners(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _ownerSearchResults = []; _isSearchingOwners = false; });
      return;
    }
    setState(() => _isSearchingOwners = true);
    try {
      final results = await _api.searchPersonnes(query.trim());
      if (mounted) {
        setState(() {
          _ownerSearchResults = results;
          _isSearchingOwners = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearchingOwners = false);
    }
  }

  void _selectOwner(Map<String, dynamic> personne) {
    setState(() {
      _selectedOwner = {
        'id': personne['id'],
        'nom': personne['nom'],
        'prenom': personne['prenom'],
      };
      _showOwnerSearch = false;
      _ownerSearchController.clear();
      _ownerSearchResults = [];
    });
  }

  void _clearOwner() {
    setState(() {
      _selectedOwner = null;
    });
  }

  Future<void> _createAndSelectOwner() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AdminPersonneFormScreen()),
    );
    // If the personne form returns data, select it
    // Otherwise, reload personnes list in case one was created
    if (result != null) {
      _selectOwner(result);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'rue': _rueController.text,
      'ville': _villeController.text,
      'codePostal': _codePostalController.text,
      'type': _selectedType,
      'superficie': double.tryParse(_superficieController.text),
      'ecoScore': int.tryParse(_ecoScoreController.text),
      'description': _descriptionController.text,
    };

    try {
      int bienId;
      if (isEditing) {
        await _api.updateBien(widget.bienId!, data);
        bienId = widget.bienId!;
      } else {
        final created = await _api.createBien(data);
        bienId = created['id'] as int;
      }

      // Set or remove owner
      if (_selectedOwner != null) {
        await _api.setBienProprietaire(bienId, _selectedOwner!['id'] as int);
      } else if (isEditing) {
        // Only remove owner on edit (new bien has no owner to remove)
        try {
          await _api.removeBienProprietaire(bienId);
        } catch (_) {
          // Ignore if no owner was set
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Bien mis à jour' : 'Bien créé')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le bien' : 'Nouveau bien'),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Type
                    Text('Type', style: AppTextStyles.textMd.w500),
                    const SizedBox(height: AppSpacing.labelInputGap),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      items: AppFormatters.typeKeys
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Row(
                                  children: [
                                    Icon(AppFormatters.typeIcon(t), size: 20, color: AppColors.slate700),
                                    const SizedBox(width: 10),
                                    Text(AppFormatters.typeLabel(t)),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                      decoration: const InputDecoration(),
                    ),

                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Rue', _rueController, required: true),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Ville', _villeController, required: true),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Code postal', _codePostalController, required: true),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Superficie (m²)', _superficieController, keyboardType: TextInputType.number),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    // Eco Score (1-10)
                    Row(
                      children: [
                        Text('Score éco', style: AppTextStyles.textMd.w500),
                        const Spacer(),
                        Text(
                          _ecoScoreController.text.isNotEmpty ? _ecoScoreController.text : '—',
                          style: AppTextStyles.textLg.w600.withColor(AppColors.blue500),
                        ),
                      ],
                    ),
                    Slider(
                      value: (int.tryParse(_ecoScoreController.text) ?? 0).toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: _ecoScoreController.text.isNotEmpty ? _ecoScoreController.text : null,
                      activeColor: AppColors.blue500,
                      inactiveColor: AppColors.slate200,
                      onChanged: (v) {
                        final intVal = v.round();
                        setState(() {
                          _ecoScoreController.text = intVal > 0 ? '$intVal' : '';
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Description', _descriptionController, maxLines: 3),

                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildOwnerSection(),

                    const SizedBox(height: AppSpacing.space8),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : Text(isEditing ? 'Enregistrer' : 'Créer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOwnerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Propriétaire', style: AppTextStyles.textMd.w500),
        const SizedBox(height: AppSpacing.labelInputGap),

        if (_selectedOwner != null) ...[
          // Show selected owner chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.blue50,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.blue100),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.blue500,
                  child: Text(
                    '${(_selectedOwner!['prenom'] as String? ?? '').isNotEmpty ? (_selectedOwner!['prenom'] as String).substring(0, 1).toUpperCase() : ''}${(_selectedOwner!['nom'] as String? ?? '').isNotEmpty ? (_selectedOwner!['nom'] as String).substring(0, 1).toUpperCase() : ''}',
                    style: AppTextStyles.textSm.w600.withColor(AppColors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_selectedOwner!['prenom'] ?? ''} ${_selectedOwner!['nom'] ?? ''}'.trim(),
                    style: AppTextStyles.textMd.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _clearOwner,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.slate400,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          GestureDetector(
            onTap: () => setState(() {
              _selectedOwner = null;
              _showOwnerSearch = true;
            }),
            child: Text(
              'Changer de propriétaire',
              style: AppTextStyles.textSm.w500.withColor(AppColors.blue500),
            ),
          ),
        ] else ...[
          // Search field
          TextFormField(
            controller: _ownerSearchController,
            decoration: InputDecoration(
              hintText: 'Rechercher une personne...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _ownerSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _ownerSearchController.clear();
                        setState(() { _ownerSearchResults = []; });
                      },
                    )
                  : null,
            ),
            onChanged: (v) => _searchOwners(v),
            onTap: () => setState(() => _showOwnerSearch = true),
          ),

          if (_showOwnerSearch) ...[
            const SizedBox(height: AppSpacing.space2),

            // Create new personne button
            OutlinedButton.icon(
              onPressed: _createAndSelectOwner,
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Créer une nouvelle personne'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue500,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),

            // Search results
            if (_isSearchingOwners)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.space3),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            else if (_ownerSearchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                margin: const EdgeInsets.only(top: AppSpacing.space2),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.slate200),
                  borderRadius: AppRadius.mdAll,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _ownerSearchResults.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = _ownerSearchResults[index] as Map<String, dynamic>;
                    final nom = p['nom'] ?? '';
                    final prenom = p['prenom'] ?? '';
                    final ville = p['ville'] as String?;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.slate200,
                        child: Text(
                          '${prenom.isNotEmpty ? prenom.substring(0, 1).toUpperCase() : ''}${nom.isNotEmpty ? nom.substring(0, 1).toUpperCase() : ''}',
                          style: AppTextStyles.textSm.w600.withColor(AppColors.slate700),
                        ),
                      ),
                      title: Text('$prenom $nom'.trim(), style: AppTextStyles.textMd.w400),
                      subtitle: ville != null && ville.isNotEmpty ? Text(ville, style: AppTextStyles.textSm.w400.withColor(AppColors.slate400)) : null,
                      onTap: () => _selectOwner(p),
                    );
                  },
                ),
              )
            else if (_ownerSearchController.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                child: Text(
                  'Aucune personne trouvée',
                  style: AppTextStyles.textSm.w400.withColor(AppColors.slate400),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ],
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.textMd.w500),
        const SizedBox(height: AppSpacing.labelInputGap),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null : null,
        ),
      ],
    );
  }
}
