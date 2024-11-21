// ClientScheduledTransferView
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';

class ClientScheduledTransferView extends GetView<ClientTransactionController> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfert Programmé')),
      body: Column(
        children: [
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(hintText: 'Numéro'),
          ),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(hintText: 'Montant'),
          ),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(hintText: 'Date'),
            onTap: () async {
              var pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2025)
              );
              if (pickedDate != null) {
                _dateController.text = pickedDate.toString();
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              controller.createScheduledTransfer(
                _phoneController.text,
                double.parse(_amountController.text),
                DateTime.parse(_dateController.text)
              );
            },
            child: const Text('Programmer le transfert'),
          )
        ],
      ),
    );
  }
}