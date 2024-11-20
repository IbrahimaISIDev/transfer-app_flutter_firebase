import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/core/utils/constants.dart';
import 'package:money_transfer_app/core/values/validators.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _agentCodeController = TextEditingController();
  
  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // En-tête
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
                      const SizedBox(height: 32),

                      // Type de compte
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: DropdownButtonFormField<UserType>(
                          value: controller.selectedUserType.value,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Type de compte',
                          ),
                          items: UserType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type == UserType.client ? 'Client' : 'Distributeur'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.selectedUserType.value = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Informations personnelles
                      TextFormField(
                        controller: _fullNameController,
                        decoration: AppStyles.inputDecoration.copyWith(
                          labelText: 'Nom complet',
                          prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                        ),
                        validator: (value) => value!.isEmpty ? 'Nom requis' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: AppStyles.inputDecoration.copyWith(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: AppColors.primary),
                        ),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: AppStyles.inputDecoration.copyWith(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: AppStyles.inputDecoration.copyWith(
                          labelText: 'Téléphone',
                          prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                        ),
                        validator: Validators.validatePhoneNumber,
                      ),
                      const SizedBox(height: 16),

                      // Code agent conditionnel
                      if (controller.selectedUserType.value == UserType.distributor)
                        Column(
                          children: [
                            TextFormField(
                              controller: _agentCodeController,
                              decoration: AppStyles.inputDecoration.copyWith(
                                labelText: 'Code Agent',
                                prefixIcon: const Icon(Icons.badge, color: AppColors.primary),
                              ),
                              validator: (value) => value!.isEmpty ? 'Code agent requis' : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // Bouton d'inscription
                      ElevatedButton(
                        onPressed: controller.isLoading.value 
                          ? null 
                          : () => _handleRegistration(),
                        style: AppStyles.elevatedButtonStyle,
                        child: Text(
                          'S\'INSCRIRE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: controller.isLoading.value ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      
                      // Lien vers la connexion
                      TextButton(
                        onPressed: () => Get.toNamed('/login'),
                        child: const Text(
                          'Déjà un compte ? Connectez-vous',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Indicateur de chargement
            if (controller.isLoading.value)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      )),
    );
  }

  void _handleRegistration() {
    if (_formKey.currentState!.validate()) {
      if (controller.selectedUserType.value == UserType.client) {
        // Inscription client
        controller.registerClient(
          UserModel(
            id: '', // Sera généré par Firebase
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            userType: UserType.client,
            fullName: _fullNameController.text.trim(),
          ),
          _passwordController.text.trim(),
        );
      } else {
        // Inscription distributeur
        controller.registerDistributor(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _phoneController.text.trim(),
          _agentCodeController.text.trim(),
        );
      }
    }
  }
}