import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/modules/client/controllers/contact_controller.dart';
import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';
import 'widgets/form_field_title.dart';
import 'widgets/success_dialog.dart';
import 'widgets/amount_form_field.dart';
import 'widgets/phone_form_field.dart';

class ClientTransferView extends StatefulWidget {
  const ClientTransferView({super.key});

  @override
  _ClientTransferViewState createState() => _ClientTransferViewState();
}

class _ClientTransferViewState extends State<ClientTransferView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  late ClientTransactionController _controller;
  late ContactController _contactController;
  late FavoritesProvider _favoritesProvider;

  bool _userPaidFee = false;
  Map<String, double> _transferAmounts = {
    'totalAmount': 0.0,
    'receivableAmount': 0.0,
    'feeAmount': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ClientTransactionController>();
    _contactController = Get.find<ContactController>();
    _favoritesProvider = Get.find<FavoritesProvider>();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _calculateTransferAmounts() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _transferAmounts = _controller.previewTransferAmounts(
        amount,
        userPaidFee: _userPaidFee,
      );
    });
  }

  void _submitTransfer() {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vérifier les informations')),
      );
      return;
    }

    final phoneNumber = _phoneController.text.trim().replaceAll(RegExp(r'[^\d+]'), '');
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone invalide')),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }

    try {
      _controller.createTransfer(
        phoneNumber, 
        amount, 
        userPaidFee: _userPaidFee
      );

      showDialog(
        context: context,
        builder: (context) => SuccessDialog(
          amount: _amountController.text,
          onClose: () {
            Navigator.of(context).pop();
            _phoneController.clear();
            _amountController.clear();
            setState(() {
              _transferAmounts = {
                'totalAmount': 0.0,
                'receivableAmount': 0.0,
                'feeAmount': 0.0,
              };
            });
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du transfert : ${e.toString()}')),
      );
    }
  }

  Widget _buildFeeSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résumé des frais :',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Montant à envoyer : ${_transferAmounts['totalAmount']?.toStringAsFixed(2) ?? '0.00'} FCFA',
          style: TextStyle(color: Colors.grey[700]),
        ),
        Text(
          'Montant reçu : ${_transferAmounts['receivableAmount']?.toStringAsFixed(2) ?? '0.00'} FCFA',
          style: TextStyle(color: Colors.grey[700]),
        ),
        Text(
          'Frais de transfert : ${_transferAmounts['feeAmount']?.toStringAsFixed(2) ?? '0.00'} FCFA',
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const FormFieldTitle(title: 'Destinataire'),
                  PhoneFormField(
                    controller: _phoneController,
                    contactController: _contactController,
                    favoritesProvider: _favoritesProvider,
                  ),
                  const SizedBox(height: 24),
                  const FormFieldTitle(title: 'Montant'),
                  AmountFormField(
                    controller: _amountController,
                    onChanged: (_) => _calculateTransferAmounts(),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Payer les frais de transfert'),
                    value: _userPaidFee,
                    onChanged: (value) {
                      setState(() {
                        _userPaidFee = value;
                        _calculateTransferAmounts();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFeeSummary(),
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
          ),
        ),
      ),
    );
  }
}