import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';

class ClientTransferView extends GetView<ClientTransactionController> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nouveau Transfert')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro du destinataire',
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
                onPressed: _submitTransfer,
                child: Text('Transférer'),
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

  void _submitTransfer() {
    if (_formKey.currentState!.validate()) {
      controller.createTransfer(
        _phoneController.text.trim(), 
        double.parse(_amountController.text.trim())
      );
    }
  }
}