import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/modules/auth/controllers/dispose_controller.dart';
import 'package:money_transfer_app/core/utils/constants.dart';
import 'package:money_transfer_app/core/values/validators.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  RegisterView({super.key});

  // Utilisation de late final pour les contrôleurs
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController = TextEditingController();
  late final TextEditingController _confirmPasswordController = TextEditingController();
  late final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _fullNameController = TextEditingController();
  late final TextEditingController _agentCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // État local observable pour le masquage du mot de passe
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isConfirmPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    // Dispose des contrôleurs quand la vue est détruite
    Get.put(DisposableController(
      onDispose: () {
        _emailController.dispose();
        _passwordController.dispose();
        _confirmPasswordController.dispose();
        _phoneController.dispose();
        _fullNameController.dispose();
        _agentCodeController.dispose();
      },
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() => SafeArea(
        child: Stack(
          children: [
            _buildForm(context),
            _buildLoadingIndicator(),
          ],
        ),
      )),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Inscription',
        style: TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildUserTypeDropdown(),
              const SizedBox(height: 16),
              _buildPersonalInfoFields(),
              const SizedBox(height: 24),
              _buildRegisterButton(),
              const SizedBox(height: 16),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Créer un compte',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Remplissez vos informations pour commencer',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<UserType>(
        value: controller.selectedUserType.value,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
          labelText: 'Type de compte',
        ),
        items: UserType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type == UserType.client ? 'Client' : 'Distributeur'),
          );
        }).toList(),
        onChanged: (value) => controller.selectedUserType.value = value!,
      ),
    );
  }

  Widget _buildPersonalInfoFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _fullNameController,
          label: 'Nom complet',
          icon: Icons.person,
          validator: (value) => value!.isEmpty ? 'Nom requis' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildConfirmPasswordField(),
        const SizedBox(height: 16),
        _buildPhoneField(),
        if (controller.selectedUserType.value == UserType.distributor) ...[
          const SizedBox(height: 16),
          _buildAgentCodeField(),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    VoidCallback? onVisibilityToggle,
    bool showVisibilityToggle = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: AppStyles.inputDecoration.copyWith(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: showVisibilityToggle
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.primary,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => _buildTextField(
      controller: _passwordController,
      label: 'Mot de passe',
      icon: Icons.lock,
      obscureText: !_isPasswordVisible.value,
      showVisibilityToggle: true,
      onVisibilityToggle: () => _isPasswordVisible.toggle(),
      validator: (value) {
        final passwordError = Validators.validatePassword(value);
        if (passwordError != null) return passwordError;
        
        if (_confirmPasswordController.text.isNotEmpty &&
            value != _confirmPasswordController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    ));
  }

  Widget _buildConfirmPasswordField() {
    return Obx(() => _buildTextField(
      controller: _confirmPasswordController,
      label: 'Confirmer le mot de passe',
      icon: Icons.lock,
      obscureText: !_isConfirmPasswordVisible.value,
      showVisibilityToggle: true,
      onVisibilityToggle: () => _isConfirmPasswordVisible.toggle(),
      validator: (value) {
        if (value!.isEmpty) return 'Veuillez confirmer votre mot de passe';
        if (value != _passwordController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    ));
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'Téléphone',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      validator: Validators.validatePhoneNumber,
    );
  }

  Widget _buildAgentCodeField() {
    return _buildTextField(
      controller: _agentCodeController,
      label: 'Code Agent',
      icon: Icons.badge,
      validator: (value) {
        if (value!.isEmpty) return 'Code agent requis';
        if (value.length < 6) return 'Le code agent doit contenir au moins 6 caractères';
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : _handleRegistration,
      style: AppStyles.elevatedButtonStyle.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey;
          }
          return AppColors.primary;
        }),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'S\'INSCRIRE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: controller.isLoading.value ? Colors.grey : Colors.white,
          ),
        ),
      ),
    ));
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Get.toNamed('/login'),
      child: const Text(
        'Déjà un compte ? Connectez-vous',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Obx(() => controller.isLoading.value
        ? Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          )
        : const SizedBox.shrink());
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      try {
        controller.isLoading.value = true;

        if (controller.selectedUserType.value == UserType.client) {
          await controller.registerClient(
            UserModel(
              id: '',
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              userType: UserType.client,
              fullName: _fullNameController.text.trim(),
            ),
            _passwordController.text.trim(),
          );
          
          Get.offAllNamed('/client/home');
        } else {
          await controller.registerDistributor(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _phoneController.text.trim(),
            _agentCodeController.text.trim(),
          );
          
          Get.offAllNamed('/distributor/home');
        }
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Une erreur est survenue lors de l\'inscription: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(16),
        );
      } finally {
        controller.isLoading.value = false;
      }
    }
  }
}