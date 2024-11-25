// widgets/transfer_info_section.dart
import 'package:flutter/material.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/widgets/custom_text_field.dart';

class TransferInfoSection extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController amountController;

  const TransferInfoSection({
    super.key,
    required this.phoneController,
    required this.amountController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations du transfert',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: phoneController,
          hintText: 'Numéro du destinataire',
          prefixIcon: Icons.phone_outlined,
          validator: (value) =>
              value!.isEmpty ? 'Numéro de téléphone requis' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: amountController,
          hintText: 'Montant à transférer',
          prefixIcon: Icons.account_balance_wallet_outlined,
          suffixText: 'FCFA',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Montant requis' : null,
        ),
      ],
    );
  }
}