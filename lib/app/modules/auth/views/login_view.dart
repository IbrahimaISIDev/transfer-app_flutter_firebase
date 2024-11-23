import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/core/utils/constants.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = true.obs;

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Back Button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.primary,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  //const SizedBox(height: 24),                  
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/samaxaalis.jpeg',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Welcome Text
                  Text(
                    'Ravi de vous revoir !',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 28),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          validator: (value) =>
                              value!.isEmpty ? 'Email requis' : null,
                        ),

                        const SizedBox(height: 20),

                        Obx(() => _buildTextField(
                              controller: _passwordController,
                              hintText: 'Mot de passe',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword.value,
                              validator: (value) => value!.length < 6
                                  ? 'Mot de passe trop court'
                                  : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => _obscurePassword.value =
                                    !_obscurePassword.value,
                              ),
                            )),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Get.toNamed('/forgot-password'),
                            child: const Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Obx(() => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 2,
                                ),
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    : const Text(
                                        'Se connecter',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              )),
                        ),

                        // Social Login Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                    color: Colors.grey[300], thickness: 1),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'ou connectez-vous avec',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                    color: Colors.grey[300], thickness: 1),
                              ),
                            ],
                          ),
                        ),

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              icon: Icons.g_mobiledata,
                              color: Colors.red,
                              onPressed: () => controller.signInWithGoogle(),
                            ),
                            const SizedBox(width: 20),
                            _buildSocialButton(
                              icon: Icons.facebook,
                              color: const Color(0xFF1877F2),
                              onPressed: () => controller.signInWithFacebook(),
                            ),
                            const SizedBox(width: 20),
                            _buildSocialButton(
                              icon: Icons.phone_outlined,
                              color: Colors.green,
                              onPressed: () => Get.toNamed('/phone-login'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Register Link
                        TextButton(
                          onPressed: () => Get.toNamed('/register'),
                          child: RichText(
                            text: TextSpan(
                              text: 'Pas de compte ? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Créer un compte',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.grey[600]),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(prefixIcon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      elevation: 0,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      controller.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }
}