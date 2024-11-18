import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/core/values/validators.dart';
import '../controllers/operation_controller.dart';

class WithdrawalView extends GetView<DistributorOperationController> {
  final _formKey = GlobalKey<FormState>();

  WithdrawalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Effectuer un Retrait'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: controller.phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validatePhoneNumber,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant du retrait',
                  border: OutlineInputBorder(),
                  suffixText: '€',
                ),
                validator: Validators.validateAmount,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.performWithdrawal();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Confirmer le Retrait'),
              )
            ],
          ),
        ),
      ),
    );
  }
}