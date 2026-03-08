import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../services/api_service.dart';

class AdminPersonneFormScreen extends StatefulWidget {
  final int? personneId;

  const AdminPersonneFormScreen({super.key, this.personneId});

  @override
  State<AdminPersonneFormScreen> createState() => _AdminPersonneFormScreenState();
}

class _AdminPersonneFormScreenState extends State<AdminPersonneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _rueController = TextEditingController();
  final _villeController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _ribController = TextEditingController();

  DateTime? _dateNais;
  bool _isLoading = false;
  bool _isLoadingData = false;
  Map<String, dynamic>? _accountStatus;

  bool get isEditing => widget.personneId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _rueController.dispose();
    _villeController.dispose();
    _codePostalController.dispose();
    _ribController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      final results = await Future.wait([
        _api.getPersonneById(widget.personneId!),
        _api.getPersonneAccountStatus(widget.personneId!).catchError((_) => <String, dynamic>{}),
      ]);
      final p = results[0] as Map<String, dynamic>;
      _nomController.text = p['nom'] ?? '';
      _prenomController.text = p['prenom'] ?? '';
      _rueController.text = p['rue'] ?? '';
      _villeController.text = p['ville'] ?? '';
      _codePostalController.text = p['codePostal'] ?? '';
      _ribController.text = p['rib'] ?? '';
      if (p['dateNais'] != null) _dateNais = DateTime.tryParse(p['dateNais']);
      _accountStatus = results[1] as Map<String, dynamic>?;
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de chargement')),
      );
    }
    if (mounted) setState(() => _isLoadingData = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateNais == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date de naissance')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final data = {
      'nom': _nomController.text,
      'prenom': _prenomController.text,
      'dateNais': '${_dateNais!.year}-${_dateNais!.month.toString().padLeft(2, '0')}-${_dateNais!.day.toString().padLeft(2, '0')}',
      'rue': _rueController.text,
      'ville': _villeController.text,
      'codePostal': _codePostalController.text,
      'rib': _ribController.text.isNotEmpty ? _ribController.text : null,
    };

    try {
      if (isEditing) {
        await _api.updatePersonne(widget.personneId!, data);
      } else {
        await _api.createPersonne(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Personne mise à jour' : 'Personne créée')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateNais ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _dateNais = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Modifier la personne' : 'Nouvelle personne')),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Account status
                    if (isEditing && _accountStatus != null && (_accountStatus!['hasAccount'] == true)) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.space3),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.blue500),
                              const SizedBox(width: AppSpacing.space2),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Compte actif', style: AppTextStyles.textMd.w600),
                                    Text(_accountStatus!['email'] ?? '', style: AppTextStyles.textSm.w400),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                    ],

                    _buildField('Nom', _nomController, required: true),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Prénom', _prenomController, required: true),
                    const SizedBox(height: AppSpacing.formFieldGap),

                    // Date picker
                    Text('Date de naissance', style: AppTextStyles.textMd.w500),
                    const SizedBox(height: AppSpacing.labelInputGap),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(),
                        child: Text(
                          _dateNais != null
                              ? '${_dateNais!.day.toString().padLeft(2, '0')}/${_dateNais!.month.toString().padLeft(2, '0')}/${_dateNais!.year}'
                              : 'Sélectionner...',
                          style: _dateNais != null
                              ? AppTextStyles.textMd.w400
                              : AppTextStyles.textMd.w400.withColor(AppColors.slate400),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Rue', _rueController),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Ville', _villeController),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Code postal', _codePostalController),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('RIB', _ribController),

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

  Widget _buildField(String label, TextEditingController controller, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.textMd.w500),
        const SizedBox(height: AppSpacing.labelInputGap),
        TextFormField(
          controller: controller,
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null : null,
        ),
      ],
    );
  }
}
