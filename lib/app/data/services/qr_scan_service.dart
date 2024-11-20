import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class QRScanService extends GetxController {
  final MobileScannerController scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  void startScanning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scanner un QR Code'),
        content: SizedBox(
          height: 300,
          width: 300,
          child: MobileScanner(
            controller: scanController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _processQRCode(barcode.rawValue);
              }
            },
          ),
        ),
      ),
    );
  }

  void _processQRCode(String? qrCode) {
    if (qrCode == null) return;

    // Exemple de structure de QR code : "transfer|phonenumber|amount"
    List<String> parts = qrCode.split('|');

    if (parts.length == 3 && parts[0] == 'transfer') {
      String phoneNumber = parts[1];
      double amount = double.tryParse(parts[2]) ?? 0.0;

      // Appeler le service de transfert
      Get.find<FirebaseService>().createTransfer(phoneNumber, amount);
    }
  }

  String generateTransferQRCode(
      {required String phoneNumber, required double amount}) {
    return 'transfer|$phoneNumber|$amount';
  }

  @override
  void onClose() {
    scanController.dispose();
    super.onClose();
  }
}
