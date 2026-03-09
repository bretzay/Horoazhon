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
  final double? salePrice;
  final double? monthlyRent;
  final double? caution;
  final int? dureeMois;
  final String? dateDispo;

  const AdminContratFormScreen({
    super.key,
    required this.bienId,
    required this.isForSale,
    required this.isForRent,
    this.salePrice,
    this.monthlyRent,
    this.caution,
    this.dureeMois,
    this.dateDispo,
  });

  @override
  State<AdminContratFormScreen> createState() => _AdminContratFormScreenState();
}

class _AdminContratFormScreenState extends State<AdminContratFormScreen> {
  final _api = ApiService();

  int _currentStep = 0;

  late String _typeContrat;

  // Cosigners
  List<dynamic> _personnes = [];
  bool _isLoadingPersonnes = true;
  final List<_CosignerEntry> _cosigners = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isForRent && !widget.isForSale) {
      _typeContrat = 'LOCATION';
    } else {
      _typeContrat = 'ACHAT';
    }
    _loadPersonnes();
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
      if (mounted) setState(() => _isLoadingPersonnes = false);
    }
  }

  void _addCosigner() {
    setState(() {
      _cosigners.add(_CosignerEntry(
        personneId: null,
        typeSignataire: _typeContrat == 'ACHAT' ? 'BUYER' : 'RENTER',
      ));
    });
  }

  void _removeCosigner(int index) {
    setState(() => _cosigners.removeAt(index));
  }

  bool _validateStep1() {
    // Step 1 is type selection + preview — always valid if type is chosen
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
      final contratData = <String, dynamic>{
        'bienId': widget.bienId,
        'typeContrat': _typeContrat,
        'cosigners': _cosigners.map((c) => {
          'personneId': c.personneId,
          'typeSignataire': c.typeSignataire,
        }).toList(),
      };

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
      body: Stepper(
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
            title: const Text('Type et offre'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildTypeAndPreviewStep(),
          ),
          Step(
            title: const Text('Cosignataires'),
            isActive: _currentStep >= 1,
            content: _buildCosignersStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeAndPreviewStep() {
    final canChooseType = widget.isForSale && widget.isForRent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              color: _typeContrat == 'ACHAT' ? AppColors.blue100 : AppColors.slate100,
              borderRadius: AppRadius.mdAll,
            ),
            child: Text(
              _typeContrat == 'ACHAT' ? 'Achat' : 'Location',
              style: AppTextStyles.textMd.w600,
            ),
          ),

        const SizedBox(height: AppSpacing.formFieldGap),

        // Read-only offer preview
        Text('Valeurs de l\'offre (lecture seule)', style: AppTextStyles.textMd.w500),
        const SizedBox(height: AppSpacing.space2),

        Card(
          color: AppColors.slate50,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space3),
            child: _typeContrat == 'ACHAT'
                ? _buildAchatPreview()
                : _buildLocationPreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchatPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewRow(
          'Prix',
          widget.salePrice != null
              ? AppFormatters.formatCurrencyShort(widget.salePrice!)
              : 'Non renseigné',
        ),
        if (widget.dateDispo != null)
          _PreviewRow('Date disponibilité', widget.dateDispo!),
      ],
    );
  }

  Widget _buildLocationPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewRow(
          'Mensualité',
          widget.monthlyRent != null
              ? AppFormatters.formatRent(widget.monthlyRent!)
              : 'Non renseigné',
        ),
        _PreviewRow(
          'Caution',
          widget.caution != null
              ? AppFormatters.formatCurrencyShort(widget.caution!)
              : 'Non renseigné',
        ),
        _PreviewRow(
          'Durée',
          widget.dureeMois != null ? '${widget.dureeMois} mois' : 'Non renseigné',
        ),
        if (widget.dateDispo != null)
          _PreviewRow('Date disponibilité', widget.dateDispo!),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget _TypeChip(String label, String value) {
    final selected = _typeContrat == value;
    final enabled = value == 'ACHAT' ? widget.isForSale : widget.isForRent;

    return GestureDetector(
      onTap: enabled
          ? () => setState(() => _typeContrat = value)
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
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

                    DropdownButtonFormField<String>(
                      value: cosigner.typeSignataire,
                      isExpanded: true,
                      items: _typeContrat == 'ACHAT'
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
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _PreviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.textMd.w400.withColor(AppColors.slate500)),
          Text(value, style: AppTextStyles.textMd.w600),
        ],
      ),
    );
  }
}

class _CosignerEntry {
  int? personneId;
  String typeSignataire;

  _CosignerEntry({this.personneId, required this.typeSignataire});
}
