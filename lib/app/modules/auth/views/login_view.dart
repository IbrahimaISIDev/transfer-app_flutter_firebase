import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/core/utils/constants.dart';
import '../controllers/auth_controller.dart';

// login_view.dart
class LoginView extends GetView<AuthController> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  // Logo ou Image
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenue',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous pour continuer',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Boutons de connexion sociale
                  SocialLoginButton(
                    text: 'Continuer avec Google',
                    icon: Icons
                        .g_mobiledata, // Ou utilisez un asset image pour le logo Google
                    onPressed: () => controller.signInWithGoogle(),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),

                  SocialLoginButton(
                    text: 'Continuer avec Facebook',
                    icon: Icons.facebook,
                    onPressed: () => controller.signInWithFacebook(),
                    backgroundColor: const Color(0xFF1877F2),
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  // Ajouter après les autres boutons de connexion sociale
                  SocialLoginButton(
                    text: 'Continuer avec Téléphone',
                    icon: Icons.phone,
                    onPressed: () => Get.toNamed('/phone-login'),
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  ),

                  // SocialLoginButton(
                  //   text: 'Continuer avec GitHub',
                  //   icon: Icons.code,
                  //   onPressed: () => controller.signInWithGithub(),
                  //   backgroundColor: const Color(0xFF24292E),
                  //   textColor: Colors.white,
                  // ),

                  // const SizedBox(height: 24),

                  // Séparateur
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Formulaire de connexion classique
                  TextFormField(
                    controller: _emailController,
                    decoration: AppStyles.inputDecoration.copyWith(
                      labelText: 'Email',
                      prefixIcon:
                          const Icon(Icons.email, color: AppColors.primary),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Email requis' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: AppStyles.inputDecoration.copyWith(
                      labelText: 'Mot de passe',
                      prefixIcon:
                          const Icon(Icons.lock, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.visibility_off),
                        onPressed: () {
                          // Ajouter la logique pour afficher/masquer le mot de passe
                        },
                      ),
                    ),
                    validator: (value) =>
                        value!.length < 6 ? 'Mot de passe trop court' : null,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.toNamed('/forgot-password'),
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  controller.login(_emailController.text.trim(),
                                      _passwordController.text.trim());
                                }
                              },
                        style: AppStyles.elevatedButtonStyle,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'SE CONNECTER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Get.toNamed('/register'),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Pas encore de compte ? ',
                        children: [
                          TextSpan(
                            text: 'Inscrivez-vous',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
