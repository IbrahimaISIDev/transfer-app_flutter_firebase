// Mise à jour de scheduled_transfer_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import '../../../controllers/transaction_controller.dart';
import 'widgets/transfer_info_section.dart';
import 'widgets/datetime_section.dart';
import 'widgets/security_note.dart';
import 'widgets/confirmation_dialog.dart';
import 'widgets/frequency_selector.dart';

// ignore: must_be_immutable
class ClientScheduledTransferView extends GetView<ClientTransactionController> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  ClientScheduledTransferView({super.key});

  // Ajouter une variable pour stocker la fréquence sélectionnée
  TransferFrequency _selectedFrequency = TransferFrequency.monthly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
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
                  TransferInfoSection(
                    phoneController: _phoneController,
                    amountController: _amountController,
                  ),
                  const SizedBox(height: 32),
                  DateTimeSection(
                    dateTimeController: _dateController,
                  ),
                  const SizedBox(height: 32),
                  FrequencySelector(
                    initialFrequency: _selectedFrequency,
                    onFrequencyChanged: (frequency) {
                      _selectedFrequency = frequency;
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                  const SecurityNote(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3142)),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Transfert Programmé',
        style: TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitScheduledTransfer,
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
            Icon(Icons.schedule),
            SizedBox(width: 8),
            Text(
              'Programmer le transfert',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitScheduledTransfer() {
    if (_formKey.currentState!.validate()) {
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      final scheduledDateTime = dateFormat.parse(
        '${_dateController.text} ${_timeController.text}',
      );

      controller.createScheduledTransfer(
        _phoneController.text.trim(),
        double.parse(_amountController.text.trim()),
        scheduledDateTime,
        frequency: _selectedFrequency, // Ajouter la fréquence
      );

      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    final String frequencyText = switch (_selectedFrequency) {
      TransferFrequency.daily => 'quotidiennement',
      TransferFrequency.weekly => 'hebdomadairement',
      TransferFrequency.monthly => 'mensuellement',
      // TODO: Handle this case.
      TransferFrequency.once => throw UnimplementedError(),
    };

    Get.dialog(
      ConfirmationDialog(
        amount: _amountController.text,
        date: _dateController.text,
        time: _timeController.text,
        frequency: frequencyText,
      ),
    );
  }
}
