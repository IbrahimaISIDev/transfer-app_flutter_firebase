import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/operation_controller.dart';

class DistributorDepositView extends GetView<DistributorOperationController> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Effectuer un Dépôt')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone)
                ),
                validator: (value) => 
                  value!.isEmpty ? 'Numéro requis' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: Icon(Icons.money),
                  suffixText: '€'
                ),
                keyboardType: TextInputType.number,
                validator: (value) => 
                  value!.isEmpty ? 'Montant requis' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitDeposit,
                child: Text('Confirmer le Dépôt'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submitDeposit() {
    if (_formKey.currentState!.validate()) {
      controller.makeDeposit(
        _phoneController.text.trim(), 
        double.parse(_amountController.text.trim())
      );
    }
  }
}