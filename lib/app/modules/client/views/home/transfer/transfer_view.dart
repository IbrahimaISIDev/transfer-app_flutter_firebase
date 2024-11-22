import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/modules/client/controllers/contact_controller.dart';
import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';

// Vue principale de transfert
class ClientTransferView extends GetView<ClientTransactionController> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final contactController = Get.put(ContactController());

  ClientTransferView({super.key});

  Widget _buildContactButton() {
    return GetBuilder<ContactController>(
      builder: (controller) => PopupMenuButton<Contact>(
        icon: const Icon(
          Icons.contacts_outlined,
          color: Color(0xFF4C6FFF),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        itemBuilder: (context) => [
          // Menu item for selecting a contact
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(
                Icons.contact_phone,
                color: Color(0xFF4C6FFF),
              ),
              title: const Text(
                'Sélectionner un contact',
                style: TextStyle(
                  color: Color(0xFF2D3142),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.pickContact(_phoneController);
              },
            ),
          ),
          const PopupMenuItem(
            child: Divider(),
          ),
          // Display recent contacts if available
          if (controller.favorites.isNotEmpty) ...[
            const PopupMenuItem(
              enabled: false,
              child: Text(
                'Contacts récents',
                style: TextStyle(
                  color: Color(0xFF2D3142),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Display the recent contacts list
            ...controller.favorites.take(5).map((contact) => PopupMenuItem(
                  value: contact,
                  child: ListTile(
                    leading: contact.photo != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(contact.photo!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(
                      contact.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      contact.phones.isNotEmpty
                          ? contact.phones.first.number
                          : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )),
          ],
        ],
        onSelected: (Contact contact) {
          controller.selectContact(contact, _phoneController);
        },
      ),
    );
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
                      const Text(
                        'Destinataire',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Numéro de téléphone',
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: Color(0xFF4C6FFF),
                          ),
                          suffixIcon: _buildContactButton(),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF4C6FFF),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Numéro de téléphone requis';
                          }
                          // Validation basique du format de numéro
                          if (!value
                              .trim()
                              .replaceAll(RegExp(r'[^\d+]'), '')
                              .startsWith('+')) {
                            return 'Format de numéro invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Montant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Montant à envoyer',
                          suffixText: 'FCFA',
                          prefixIcon: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Color(0xFF4C6FFF),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF4C6FFF),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Montant requis';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
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
                      ),
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

  void _submitTransfer() {
    if (_formKey.currentState!.validate()) {
      // Formatter le numéro de téléphone avant l'envoi
      final phoneNumber =
          _phoneController.text.trim().replaceAll(RegExp(r'[^\d+]'), '');
      final amount = double.parse(_amountController.text.trim());

      controller.createTransfer(
        phoneNumber,
        amount,
      );

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
                  'Transfert réussi !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre transfert de ${_amountController.text} FCFA a été effectué avec succès.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // Réinitialiser les champs après le transfert
                      _phoneController.clear();
                      _amountController.clear();
                    },
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
