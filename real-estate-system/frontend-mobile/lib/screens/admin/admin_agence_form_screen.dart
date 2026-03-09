import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../services/api_service.dart';

class AdminAgenceFormScreen extends StatefulWidget {
  final int? agenceId;

  const AdminAgenceFormScreen({super.key, this.agenceId});

  @override
  State<AdminAgenceFormScreen> createState() => _AdminAgenceFormScreenState();
}

class _AdminAgenceFormScreenState extends State<AdminAgenceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _nomController = TextEditingController();
  final _siretController = TextEditingController();
  final _tvaController = TextEditingController();
  final _rueController = TextEditingController();
  final _villeController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _logoController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingData = false;

  bool get isEditing => widget.agenceId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadAgence();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _siretController.dispose();
    _tvaController.dispose();
    _rueController.dispose();
    _villeController.dispose();
    _codePostalController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _loadAgence() async {
    setState(() => _isLoadingData = true);
    try {
      final a = await _api.getAgenceById(widget.agenceId!);
      _nomController.text = a['nom'] ?? '';
      _siretController.text = a['siret'] ?? '';
      _tvaController.text = a['numeroTva'] ?? '';
      _rueController.text = a['rue'] ?? '';
      _villeController.text = a['ville'] ?? '';
      _codePostalController.text = a['codePostal'] ?? '';
      _telephoneController.text = a['telephone'] ?? '';
      _emailController.text = a['email'] ?? '';
      _descriptionController.text = a['description'] ?? '';
      _logoController.text = a['logo'] ?? '';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'nom': _nomController.text,
      'siret': _siretController.text,
      'numeroTva': _tvaController.text,
      'rue': _rueController.text,
      'ville': _villeController.text,
      'codePostal': _codePostalController.text,
      'telephone': _telephoneController.text,
      'email': _emailController.text,
      'description': _descriptionController.text,
      'logo': _logoController.text.isNotEmpty ? _logoController.text : null,
    };

    try {
      if (isEditing) {
        await _api.updateAgence(widget.agenceId!, data);
      } else {
        await _api.createAgence(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Agence mise à jour' : 'Agence créée')),
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
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Modifier l\'agence' : 'Nouvelle agence')),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildField('Nom', _nomController, required: true),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('SIRET', _siretController),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('N° TVA', _tvaController),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Rue', _rueController),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Ville', _villeController),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Code postal', _codePostalController),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Téléphone', _telephoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Description', _descriptionController, maxLines: 3),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Logo (URL)', _logoController),
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
