import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientMultipleTransferView extends StatelessWidget {
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
      appBar: AppBar(
        title: const Text(
          'Transferts Multiples',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => ListView.builder(
                  shrinkWrap: true,
                  itemCount: _transfers.length,
                  itemBuilder: (context, index) => Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _transfers[index]['phoneNumber'],
                              decoration: InputDecoration(
                                labelText: 'Numéro',
                                labelStyle: const TextStyle(fontSize: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _transfers[index]['amount'],
                              decoration: InputDecoration(
                                labelText: 'Montant',
                                labelStyle: const TextStyle(fontSize: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addTransferRow,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter un transfert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Ajouter logique pour effectuer les transferts
              },
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Effectuer les transferts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
