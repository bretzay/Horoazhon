import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../services/api_service.dart';

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

  String _selectedType = 'APPARTEMENT';
  bool _isLoading = false;
  bool _isLoadingData = false;

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
      _ecoScoreController.text = '${bien['scoreEco'] ?? ''}';
      _descriptionController.text = bien['description'] ?? '';
      _selectedType = bien['type'] ?? 'APPARTEMENT';
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de chargement')),
      );
    }
    if (mounted) setState(() => _isLoadingData = false);
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
      'scoreEco': double.tryParse(_ecoScoreController.text),
      'description': _descriptionController.text,
    };

    try {
      if (isEditing) {
        await _api.updateBien(widget.bienId!, data);
      } else {
        await _api.createBien(data);
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
                      value: _selectedType,
                      items: ['APPARTEMENT', 'MAISON', 'STUDIO', 'TERRAIN']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
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
                    _buildField('Score éco', _ecoScoreController, keyboardType: TextInputType.number),
                    const SizedBox(height: AppSpacing.formFieldGap),
                    _buildField('Description', _descriptionController, maxLines: 3),

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
