import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;

  const ResetPasswordScreen({super.key, this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isCheckingToken = false;
  bool _isResetting = false;
  bool _obscurePassword = true;
  bool _tokenValid = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _tokenController.text = widget.token!;
      _checkToken();
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _checkToken() async {
    if (_tokenController.text.trim().isEmpty) return;
    setState(() { _isCheckingToken = true; _errorMessage = null; });
    try {
      final result = await _api.checkResetStatus(_tokenController.text.trim());
      if (mounted) {
        setState(() {
          _tokenValid = result['valid'] == true;
          if (!_tokenValid) _errorMessage = 'Lien de réinitialisation invalide ou expiré';
          _isCheckingToken = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lien de réinitialisation invalide ou expiré';
          _tokenValid = false;
          _isCheckingToken = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() { _isResetting = true; _errorMessage = null; });
    try {
      await _api.resetPassword(_tokenController.text.trim(), _passwordController.text);
      if (mounted) {
        setState(() {
          _successMessage = 'Mot de passe réinitialisé avec succès !';
          _isResetting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la réinitialisation';
          _isResetting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réinitialisation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: AppRadius.lgAll),
              child: const Icon(Icons.lock_reset, size: 32, color: AppColors.white),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text('Nouveau mot de passe', style: AppTextStyles.textXl.w700),
            const SizedBox(height: AppSpacing.space8),

            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: AppColors.successBg, borderRadius: AppRadius.mdAll,
                  border: Border.all(color: AppColors.successBorder),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.blue500, size: 48),
                    const SizedBox(height: AppSpacing.space3),
                    Text(_successMessage!, style: AppTextStyles.textMd.w400, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.space4),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Retour à la connexion'),
                    ),
                  ],
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space6),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space3),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg, borderRadius: AppRadius.mdAll,
                              border: Border.all(color: AppColors.errorBorder),
                            ),
                            child: Text(_errorMessage!, style: AppTextStyles.textMd.w400.withColor(AppColors.errorText)),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                        ],

                        Text('Token de réinitialisation', style: AppTextStyles.textMd.w500),
                        const SizedBox(height: AppSpacing.labelInputGap),
                        TextFormField(
                          controller: _tokenController,
                          decoration: InputDecoration(
                            hintText: 'Collez votre token',
                            suffixIcon: IconButton(icon: const Icon(Icons.check), onPressed: _checkToken),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Token requis' : null,
                        ),

                        if (_isCheckingToken) ...[
                          const SizedBox(height: AppSpacing.space3),
                          const Center(child: CircularProgressIndicator()),
                        ],

                        if (_tokenValid) ...[
                          const SizedBox(height: AppSpacing.space4),
                          Text('Nouveau mot de passe', style: AppTextStyles.textMd.w500),
                          const SizedBox(height: AppSpacing.labelInputGap),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
                          ),

                          const SizedBox(height: AppSpacing.formFieldGap),
                          Text('Confirmer', style: AppTextStyles.textMd.w500),
                          const SizedBox(height: AppSpacing.labelInputGap),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: true,
                            validator: (v) => (v == null || v.isEmpty) ? 'Confirmation requise' : null,
                          ),

                          const SizedBox(height: AppSpacing.space6),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isResetting ? null : _resetPassword,
                              child: _isResetting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                                  : const Text('Réinitialiser'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
