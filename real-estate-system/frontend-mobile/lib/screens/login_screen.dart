import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/app_radius.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      setState(() {
        if (e.toString().contains('DioException') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('Connection')) {
          _errorMessage = 'Erreur de connexion au serveur';
        } else {
          _errorMessage = 'Identifiants invalides';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.space10),

          // Branding
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: AppRadius.lgAll,
            ),
            child: const Icon(
              Icons.apartment,
              size: 32,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            'Horoazhon',
            style: AppTextStyles.textXl.w800.withColor(AppColors.blue500),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Connectez-vous à votre compte',
            style: AppTextStyles.textMd.w400.withColor(AppColors.slate500),
          ),

          const SizedBox(height: AppSpacing.space8),

          // Login form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space6),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: AppRadius.mdAll,
                          border: Border.all(color: AppColors.errorBorder),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.textMd.w400.withColor(AppColors.errorText),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                    ],

                    // Email field
                    Text('Email', style: AppTextStyles.textMd.w500),
                    const SizedBox(height: AppSpacing.labelInputGap),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'votre@email.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir votre email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.formFieldGap),

                    // Password field
                    Text('Mot de passe', style: AppTextStyles.textMd.w500),
                    const SizedBox(height: AppSpacing.labelInputGap),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        hintText: 'Votre mot de passe',
                        prefixIcon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir votre mot de passe';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.space6),

                    // Login button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Se connecter'),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.space4),

                    // Forgot password link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to forgot password screen
                        },
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
