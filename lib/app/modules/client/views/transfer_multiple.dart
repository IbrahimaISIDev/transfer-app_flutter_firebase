import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';

class ClientMultipleTransferView extends GetView<ClientTransactionController> {
  final _formKey = GlobalKey<FormState>();
  final _transfers = <Map<String, dynamic>>[].obs;
  final _totalAmount = 0.0.obs;

  ClientMultipleTransferView({super.key});

  void _addTransferRow() {
    _transfers.add({
      'phoneNumber': TextEditingController(),
      'amount': TextEditingController(),
    });
  }

  void _removeTransferRow(int index) {
    final amountText = _transfers[index]['amount'].text;
    if (amountText.isNotEmpty) {
      _totalAmount.value -= double.tryParse(amountText) ?? 0;
    }
    _transfers.removeAt(index);
  }

  void _updateTotalAmount() {
    double total = 0;
    for (var transfer in _transfers) {
      final amountText = transfer['amount'].text;
      if (amountText.isNotEmpty) {
        total += double.tryParse(amountText) ?? 0;
      }
    }
    _totalAmount.value = total;
  }

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
          'Transferts Multiples',
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // En-tête avec montant total
                  Obx(() => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4C6FFF), Color(0xFF6B8CFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4C6FFF).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Transferts multiples',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Montant total',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${_totalAmount.value.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 24),

                  // Liste des transferts
                  Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _transfers.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transfert ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                color: Colors.red.shade400,
                                onPressed: () => _removeTransferRow(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _transfers[index]['phoneNumber'],
                            decoration: InputDecoration(
                              hintText: 'Numéro du destinataire',
                              prefixIcon: const Icon(
                                Icons.phone_outlined,
                                color: Color(0xFF4C6FFF),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Numéro requis' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _transfers[index]['amount'],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Montant à transférer',
                              prefixIcon: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Color(0xFF4C6FFF),
                              ),
                              suffixText: 'FCFA',
                              filled: true,
                              fillColor: const Color(0xFFF5F7FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Montant requis' : null,
                            onChanged: (value) => _updateTotalAmount(),
                          ),
                        ],
                      ),
                    ),
                  )),

                  const SizedBox(height: 16),

                  // Bouton Ajouter un transfert
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _addTransferRow,
                      icon: const Icon(Icons.add, color: Color(0xFF4C6FFF)),
                      label: const Text(
                        'Ajouter un transfert',
                        style: TextStyle(
                          color: Color(0xFF4C6FFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4C6FFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bouton de validation
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitTransfers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C6FFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:  [
                          Icon(Icons.send_rounded),
                          SizedBox(width: 8),
                          Text(
                            'Effectuer les transferts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Note de sécurité
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Row(
                      children:  [
                        Icon(
                          Icons.security,
                          color: Color(0xFF4C6FFF),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vos transferts multiples sont sécurisés et seront traités simultanément',
                            style: TextStyle(
                              color: Color(0xFF2D3142),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitTransfers() {
    if (_formKey.currentState!.validate()) {
      controller.createMultipleTransfers(_transfers);

      // Afficher le dialogue de confirmation
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4C6FFF),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transferts réussis !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_transfers.length} transferts ont été effectués avec succès pour un montant total de ${_totalAmount.value.toStringAsFixed(0)} FCFA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6FFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Fermer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}