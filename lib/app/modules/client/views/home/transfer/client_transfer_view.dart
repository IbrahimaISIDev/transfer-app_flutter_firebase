// Vue principale de transfert refactorisée
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/modules/client/controllers/contact_controller.dart';
import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/widgets/amount_form_field.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/widgets/phone_form_field.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/widgets/success_dialog.dart';
import 'widgets/form_field_title.dart';

class ClientTransferView extends GetView<ClientTransactionController> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final contactController = Get.put(ContactController());
  final FavoritesProvider _favoritesProvider = FavoritesProvider();

  ClientTransferView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3142)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Transfert d\'argent',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormFieldTitle(title: 'Destinataire'),
                      PhoneFormField(
                        controller: _phoneController,
                        contactController: contactController,
                        favoritesProvider: _favoritesProvider,
                      ),
                      const SizedBox(height: 24),
                      const FormFieldTitle(title: 'Montant'),
                      AmountFormField(controller: _amountController),
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitTransfer,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C6FFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded),
            SizedBox(width: 8),
            Text(
              'Envoyer maintenant',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTransfer() {
    if (_formKey.currentState!.validate()) {
      final phoneNumber =
          _phoneController.text.trim().replaceAll(RegExp(r'[^\d+]'), '');
      final amount = double.parse(_amountController.text.trim());

      controller.createTransfer(phoneNumber, amount);

      Get.dialog(
        SuccessDialog(
          amount: _amountController.text,
          onClose: () {
            Get.back();
            _phoneController.clear();
            _amountController.clear();
          },
        ),
      );
    }
  }
}