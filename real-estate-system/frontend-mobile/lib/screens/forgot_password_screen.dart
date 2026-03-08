import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; _successMessage = null; });
    try {
      await _api.forgotPassword(_emailController.text.trim());
      if (mounted) {
        setState(() {
          _successMessage = 'Un email de réinitialisation a été envoyé';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de l\'envoi';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: AppRadius.lgAll),
              child: const Icon(Icons.email_outlined, size: 32, color: AppColors.white),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text('Réinitialisation', style: AppTextStyles.textXl.w700),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Saisissez votre email pour recevoir un lien de réinitialisation',
              style: AppTextStyles.textMd.w400.withColor(AppColors.slate500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_successMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.space3),
                          decoration: BoxDecoration(
                            color: AppColors.successBg, borderRadius: AppRadius.mdAll,
                            border: Border.all(color: AppColors.successBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.blue500, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_successMessage!, style: AppTextStyles.textMd.w400.withColor(AppColors.successText))),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space4),
                      ],

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

                      Text('Email', style: AppTextStyles.textMd.w500),
                      const SizedBox(height: AppSpacing.labelInputGap),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'votre@email.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Email requis' : null,
                      ),

                      const SizedBox(height: AppSpacing.space6),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                              : const Text('Envoyer le lien'),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.space3),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Retour à la connexion'),
                        ),
                      ),
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
