// ClientMultipleTransferView
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';

class ClientMultipleTransferView extends GetView<ClientTransactionController> {
  final _transfers = <Map<String, dynamic>>[].obs;

  void _addTransferRow() {
    _transfers.add({
      'phoneNumber': TextEditingController(),
      'amount': TextEditingController()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transferts Multiples')),
      body: Column(
        children: [
          Obx(() => ListView.builder(
            shrinkWrap: true,
            itemCount: _transfers.length,
            itemBuilder: (context, index) => Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _transfers[index]['phoneNumber'],
                    decoration: const InputDecoration(hintText: 'Numéro'),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _transfers[index]['amount'],
                    decoration: const InputDecoration(hintText: 'Montant'),
                  ),
                ),
              ],
            ),
          )),
          ElevatedButton(
            onPressed: _addTransferRow,
            child: const Text('Ajouter un transfert'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.createMultipleTransfers(_transfers);
            },
            child: const Text('Effectuer les transferts'),
          )
        ],
      ),
    );
  }
}