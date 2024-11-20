// Nouvelle vue pour la vérification OTP
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:money_transfer_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:money_transfer_app/core/utils/constants.dart';

class OtpVerificationView extends GetView<AuthController> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  
  OtpVerificationView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification du code')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Entrez le code reçu par SMS',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _otpController,
                decoration: AppStyles.inputDecoration.copyWith(
                  labelText: 'Code de vérification',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Code requis';
                  }
                  if (value.length != 6) {
                    return 'Le code doit contenir 6 chiffres';
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
                          controller.verifyOTP(_otpController.text.trim());
                        }
                      },
                style: AppStyles.elevatedButtonStyle,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('VÉRIFIER'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}