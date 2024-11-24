// lib/app/shared/widgets/operation_form.dart
import 'package:flutter/material.dart';

class OperationForm extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController amountController;
  final String amountLabel;
  final VoidCallback onQRScan;
  final VoidCallback onSubmit;
  final String submitButtonText;
  final String? Function(String?)? phoneValidator;
  final String? Function(String?)? amountValidator;

  const OperationForm({
    Key? key,
    required this.title,
    required this.formKey,
    required this.phoneController,
    required this.amountController,
    required this.amountLabel,
    required this.onQRScan,
    required this.onSubmit,
    required this.submitButtonText,
    this.phoneValidator,
    this.amountValidator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFffffff).withOpacity(0.5),
            const Color(0xFFffffff).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 20),
              _buildPhoneField(context),
              const SizedBox(height: 15),
              _buildAmountField(context),
              const SizedBox(height: 30),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return TextFormField(
      controller: phoneController,
      decoration: InputDecoration(
        labelText: 'Numéro de téléphone',
        prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
        suffixIcon: IconButton(
          icon: Icon(Icons.qr_code, color: Theme.of(context).primaryColor),
          onPressed: onQRScan,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: phoneValidator,
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return TextFormField(
      controller: amountController,
      decoration: InputDecoration(
        labelText: amountLabel,
        prefixIcon: Icon(Icons.monetization_on, color: Theme.of(context).primaryColor),
        suffixText: 'F CFA',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: amountValidator,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 5,
      ),
      child: Text(
        submitButtonText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
