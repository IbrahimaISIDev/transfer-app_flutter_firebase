import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/operation_controller.dart';

class DistributorDepositView extends GetView<DistributorOperationController> {
  final _formKey = GlobalKey<FormState>();
  final MobileScannerController scannerController = MobileScannerController();
  
  DistributorDepositView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildInputMethods(context),
              const SizedBox(height: 20),
              _buildDepositForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          Text(
            'Effectuer un Dépôt',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildInputMethods(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.phone_android, color: Colors.white),
              label: const Text(
                'Saisie Manuelle',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => controller.setInputMode(InputMode.manual),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text(
                'Scanner QR',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _showQRScanner(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    'Scanner le QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: ValueListenableBuilder(
                      valueListenable: scannerController.torchState,
                      builder: (context, state, child) {
                        switch (state) {
                          case TorchState.off:
                            return const Icon(Icons.flash_off, color: Colors.white);
                          case TorchState.on:
                            return const Icon(Icons.flash_on, color: Colors.white);
                        }
                      },
                    ),
                    onPressed: () => scannerController.toggleTorch(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                controller: scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      controller.handleQRScanResult(barcode.rawValue);
                      Get.back();
                      break;
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositForm(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 500,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFffffff).withOpacity(0.1),
          const Color(0xFFffffff).withOpacity(0.05),
        ],
        stops: const [0.1, 1],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFffffff).withOpacity(0.5),
          const Color((0xFFffffff)).withOpacity(0.5),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails du Dépôt',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 20),
              _buildPhoneField(context),
              const SizedBox(height: 15),
              _buildAmountField(context),
              const SizedBox(height: 30),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return TextFormField(
      controller: controller.phoneController,
      decoration: InputDecoration(
        labelText: 'Numéro de téléphone',
        prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
        suffixIcon: IconButton(
          icon: Icon(Icons.qr_code, color: Theme.of(context).primaryColor),
          onPressed: () => _showQRScanner(context),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Numéro requis' : null,
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return TextFormField(
      controller: controller.amountController,
      decoration: InputDecoration(
        labelText: 'Montant',
        prefixIcon: Icon(
          Icons.monetization_on,
          color: Theme.of(context).primaryColor,
        ),
        suffixText: 'F CFA',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) => value!.isEmpty ? 'Montant requis' : null,
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          controller.performDeposit();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 5,
      ),
      child: const Text(
        'Confirmer le Dépôt',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:glassmorphism/glassmorphism.dart';
// import '../controllers/operation_controller.dart';

// class DistributorDepositView extends GetView<DistributorOperationController> {
//   final _formKey = GlobalKey<FormState>();

//   DistributorDepositView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(context),
//               const SizedBox(height: 20),
//               _buildDepositForm(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 10,
//           )
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//             onPressed: () => Get.back(),
//           ),
//           Text(
//             'Effectuer un Dépôt',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//           const SizedBox(width: 50), // Pour centrer le titre
//         ],
//       ),
//     );
//   }

//   Widget _buildDepositForm(BuildContext context) {
//     return GlassmorphicContainer(
//       width: double.infinity,
//       height: 500,
//       borderRadius: 20,
//       blur: 20,
//       alignment: Alignment.bottomCenter,
//       border: 2,
//       linearGradient: LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           const Color(0xFFffffff).withOpacity(0.1),
//           const Color(0xFFffffff).withOpacity(0.05),
//         ],
//         stops: const [0.1, 1],
//       ),
//       borderGradient: LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           const Color(0xFFffffff).withOpacity(0.5),
//           const Color((0xFFffffff)).withOpacity(0.5),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Détails du Dépôt',
//                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//               ),
//               const SizedBox(height: 20),
//               _buildPhoneField(context),
//               const SizedBox(height: 15),
//               _buildAmountField(context),
//               const SizedBox(height: 30),
//               _buildSubmitButton(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPhoneField(BuildContext context) {
//     return TextFormField(
//       controller: controller.phoneController,
//       decoration: InputDecoration(
//         labelText: 'Numéro de téléphone',
//         prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide.none,
//         ),
//       ),
//       validator: (value) => value!.isEmpty ? 'Numéro requis' : null,
//       keyboardType: TextInputType.phone,
//     );
//   }

//   Widget _buildAmountField(BuildContext context) {
//     return TextFormField(
//       controller: controller.amountController,
//       decoration: InputDecoration(
//         labelText: 'Montant',
//         prefixIcon:
//             Icon(Icons.monetization_on, color: Theme.of(context).primaryColor),
//         suffixText: 'F CFA',
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide.none,
//         ),
//       ),
//       keyboardType: TextInputType.number,
//       validator: (value) => value!.isEmpty ? 'Montant requis' : null,
//     );
//   }

//   Widget _buildSubmitButton(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         if (_formKey.currentState!.validate()) {
//           controller.makeDeposit(
//             controller.phoneController.text.trim(),
//             double.parse(controller.amountController.text.trim()),
//           );
//         }
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Theme.of(context).primaryColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         minimumSize: const Size(double.infinity, 60),
//         elevation: 5,
//       ),
//       child: const Text(
//         'Confirmer le Dépôt',
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
