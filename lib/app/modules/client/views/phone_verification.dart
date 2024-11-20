// Nouvelle vue pour la connexion par téléphone
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:money_transfer_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:money_transfer_app/core/utils/constants.dart';

class PhoneLoginView extends GetView<AuthController> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  PhoneLoginView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion par téléphone')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: AppStyles.inputDecoration.copyWith(
                  labelText: 'Numéro de téléphone',
                  hintText: '+221 XX XXX XX XX',
                  prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Numéro de téléphone requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          controller.sendVerificationCode(_phoneController.text.trim());
                        }
                      },
                style: AppStyles.elevatedButtonStyle,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('ENVOYER LE CODE'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}