import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/operation_controller.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/withdrawal_operation_controller.dart';
import 'package:money_transfer_app/core/values/validators.dart';
import 'package:money_transfer_app/shared/widgets/operation_form.dart';
import 'package:money_transfer_app/shared/widgets/operation_input_methods.dart';
import 'package:money_transfer_app/shared/widgets/operation_scaffold.dart';
import 'package:money_transfer_app/shared/widgets/qr_scanner_modal.dart';

class WithdrawalView extends GetView<DistributorWithdrawalController> {
  final _formKey = GlobalKey<FormState>();
  final MobileScannerController scannerController = MobileScannerController();

  WithdrawalView({super.key});

  void _showQRScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QRScannerModal(
        controller: scannerController,
        onScanResult: (result) {
          controller.handleQRScanResult(result);
          Get.back();
        },
        onClose: () => Get.back(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OperationScaffold(
      title: 'Effectuer un Retrait',
      onBack: () => Get.back(),
      inputMethods: OperationInputMethods(
        onManualInput: () => controller.setInputMode(InputMode.manual),
        onQRScan: () => _showQRScanner(context),
      ),
      operationForm: OperationForm(
        title: 'Détails du Retrait',
        formKey: _formKey,
        phoneController: controller.phoneController,
        amountController: controller.amountController,
        amountLabel: 'Montant du retrait',
        onQRScan: () => _showQRScanner(context),
        onSubmit: () {
          if (_formKey.currentState!.validate()) {
            controller.performWithdrawal();
          }
        },
        submitButtonText: 'Confirmer le Retrait',
        phoneValidator: Validators.validatePhoneNumber,
        amountValidator: Validators.validateAmount,
      ),
    );
  }

  void dispose() {
    scannerController.dispose();
  }
}