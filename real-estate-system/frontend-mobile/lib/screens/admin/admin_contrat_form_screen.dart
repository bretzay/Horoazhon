import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';
import '../../config/app_radius.dart';
import '../../config/app_formatters.dart';
import '../../services/api_service.dart';

class AdminContratFormScreen extends StatefulWidget {
  final int bienId;
  final bool isForSale;
  final bool isForRent;

  const AdminContratFormScreen({
    super.key,
    required this.bienId,
    required this.isForSale,
    required this.isForRent,
  });

  @override
  State<AdminContratFormScreen> createState() => _AdminContratFormScreenState();
}

class _AdminContratFormScreenState extends State<AdminContratFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  // Step tracking
  int _currentStep = 0;

  // Step 1: Offer type and details
  late String _offerType; // 'LOCATION' or 'ACHAT'

  // Location fields
  final _cautionController = TextEditingController();
  final _mensualiteController = TextEditingController();
  final _dureeMoisController = TextEditingController();

  // Achat fields
  final _prixController = TextEditingController();

  // Shared
  DateTime? _dateDispo;

  // Step 2: Cosigners
  List<dynamic> _personnes = [];
  bool _isLoadingPersonnes = true;
  final List<_CosignerEntry> _cosigners = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default to the available type
    if (widget.isForRent && !widget.isForSale) {
      _offerType = 'LOCATION';
    } else {
      _offerType = 'ACHAT';
    }
    _loadPersonnes();
  }

  @override
  void dispose() {
    _cautionController.dispose();
    _mensualiteController.dispose();
    _dureeMoisController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonnes() async {
    try {
      final data = await _api.getPersonnes();
      if (mounted) {
        setState(() {
          _personnes = data;
          _isLoadingPersonnes = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingPersonnes = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateDispo ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      setState(() => _dateDispo = picked);
    }
  }

  void _addCosigner() {
    setState(() {
      _cosigners.add(_CosignerEntry(
        personneId: null,
        typeSignataire: _offerType == 'ACHAT' ? 'BUYER' : 'RENTER',
      ));
    });
  }

  void _removeCosigner(int index) {
    setState(() => _cosigners.removeAt(index));
  }

  bool _validateStep1() {
    if (!_formKey.currentState!.validate()) return false;
    if (_dateDispo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date de disponibilité')),
      );
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_cosigners.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Au moins 2 cosignataires sont requis')),
      );
      return false;
    }
    for (final c in _cosigners) {
      if (c.personneId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une personne pour chaque cosignataire')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validateStep2()) return;
    setState(() => _isSubmitting = true);

    try {
      final dateDispoStr = _dateDispo!.toIso8601String().split('T').first;

      // Step 1: Create the Location or Achat offer
      Map<String, dynamic> offer;
      if (_offerType == 'LOCATION') {
        offer = await _api.createLocation({
          'bienId': widget.bienId,
          'caution': double.tryParse(_cautionController.text) ?? 0,
          'mensualite': double.tryParse(_mensualiteController.text) ?? 0,
          'dureeMois': int.tryParse(_dureeMoisController.text) ?? 12,
          'dateDispo': dateDispoStr,
        });
      } else {
        offer = await _api.createAchat({
          'bienId': widget.bienId,
          'prix': double.tryParse(_prixController.text) ?? 0,
          'dateDispo': dateDispoStr,
        });
      }

      // Step 2: Create the Contrat linked to the offer
      final contratData = <String, dynamic>{
        'cosigners': _cosigners.map((c) => {
          'personneId': c.personneId,
          'typeSignataire': c.typeSignataire,
        }).toList(),
      };

      if (_offerType == 'LOCATION') {
        contratData['locationId'] = offer['id'];
      } else {
        contratData['achatId'] = offer['id'];
      }

      await _api.createContrat(contratData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contrat créé avec succès')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contrat — ${AppFormatters.formatBienId(widget.bienId)}'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0) {
              if (_validateStep1()) {
                setState(() => _currentStep = 1);
              }
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep = 0);
            } else {
              Navigator.pop(context);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space4),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : details.onStepContinue,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : Text(_currentStep == 0 ? 'Suivant' : 'Créer le contrat'),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(_currentStep == 0 ? 'Annuler' : 'Retour'),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Offre'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildOfferStep(),
            ),
            Step(
              title: const Text('Cosignataires'),
              isActive: _currentStep >= 1,
              content: _buildCosignersStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferStep() {
    final canChooseType = widget.isForSale && widget.isForRent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type selector
        Text('Type de contrat', style: AppTextStyles.textMd.w500),
        const SizedBox(height: AppSpacing.labelInputGap),
        if (canChooseType)
          Row(
            children: [
              _TypeChip('Achat', 'ACHAT'),
              const SizedBox(width: AppSpacing.space2),
              _TypeChip('Location', 'LOCATION'),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _offerType == 'ACHAT' ? AppColors.blue100 : AppColors.slate100,
              borderRadius: AppRadius.mdAll,
            ),
            child: Text(
              _offerType == 'ACHAT' ? 'Achat' : 'Location',
              style: AppTextStyles.textMd.w600,
            ),
          ),

        const SizedBox(height: AppSpacing.formFieldGap),

        // Offer-specific fields
        if (_offerType == 'ACHAT') ...[
          _buildField('Prix (EUR)', _prixController, keyboardType: TextInputType.number, required: true),
        ] else ...[
          _buildField('Mensualité (EUR)', _mensualiteController, keyboardType: TextInputType.number, required: true),
          const SizedBox(height: AppSpacing.formFieldGap),
          _buildField('Caution (EUR)', _cautionController, keyboardType: TextInputType.number, required: true),
          const SizedBox(height: AppSpacing.formFieldGap),
          _buildField('Durée (mois)', _dureeMoisController, keyboardType: TextInputType.number, required: true),
        ],

        const SizedBox(height: AppSpacing.formFieldGap),

        // Date de disponibilité
        Text('Date de disponibilité', style: AppTextStyles.textMd.w500),
        const SizedBox(height: AppSpacing.labelInputGap),
        InkWell(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.slate200),
              borderRadius: AppRadius.mdAll,
            ),
            child: Text(
              _dateDispo != null
                  ? '${_dateDispo!.day.toString().padLeft(2, '0')}/${_dateDispo!.month.toString().padLeft(2, '0')}/${_dateDispo!.year}'
                  : 'Sélectionner une date',
              style: AppTextStyles.textMd.w400.withColor(
                _dateDispo != null ? AppColors.slate900 : AppColors.slate400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget _TypeChip(String label, String value) {
    final selected = _offerType == value;
    return GestureDetector(
      onTap: () => setState(() => _offerType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue500 : AppColors.white,
          border: Border.all(color: selected ? AppColors.blue500 : AppColors.slate200),
          borderRadius: AppRadius.fullAll,
        ),
        child: Text(
          label,
          style: AppTextStyles.textMd.w600.withColor(selected ? AppColors.white : AppColors.slate700),
        ),
      ),
    );
  }

  Widget _buildCosignersStep() {
    if (_isLoadingPersonnes) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélectionnez au moins 2 cosignataires',
          style: AppTextStyles.textMd.w400.withColor(AppColors.slate500),
        ),
        const SizedBox(height: AppSpacing.space3),

        ..._cosigners.asMap().entries.map((entry) {
          final idx = entry.key;
          final cosigner = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Cosignataire ${idx + 1}', style: AppTextStyles.textMd.w600),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => _removeCosigner(idx),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space2),

                    // Personne dropdown
                    DropdownButtonFormField<int>(
                      value: cosigner.personneId,
                      hint: const Text('Sélectionner une personne'),
                      isExpanded: true,
                      items: _personnes.map<DropdownMenuItem<int>>((p) {
                        final pers = p as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: pers['id'] as int,
                          child: Text('${pers['prenom'] ?? ''} ${pers['nom'] ?? ''}'),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => _cosigners[idx].personneId = v);
                      },
                    ),
                    const SizedBox(height: AppSpacing.space2),

                    // Role dropdown
                    DropdownButtonFormField<String>(
                      value: cosigner.typeSignataire,
                      isExpanded: true,
                      items: _offerType == 'ACHAT'
                          ? const [
                              DropdownMenuItem(value: 'BUYER', child: Text('Acheteur')),
                              DropdownMenuItem(value: 'SELLER', child: Text('Vendeur')),
                            ]
                          : const [
                              DropdownMenuItem(value: 'RENTER', child: Text('Locataire')),
                              DropdownMenuItem(value: 'OWNER', child: Text('Propriétaire')),
                            ],
                      onChanged: (v) {
                        setState(() => _cosigners[idx].typeSignataire = v!);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: AppSpacing.space2),
        OutlinedButton.icon(
          onPressed: _addCosigner,
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Ajouter un cosignataire'),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.textMd.w500),
        const SizedBox(height: AppSpacing.labelInputGap),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null : null,
        ),
      ],
    );
  }
}

class _CosignerEntry {
  int? personneId;
  String typeSignataire;

  _CosignerEntry({this.personneId, required this.typeSignataire});
}
