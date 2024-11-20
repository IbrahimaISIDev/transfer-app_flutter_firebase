// app/modules/client/bindings/client_binding.dart
import 'package:get/get.dart';
import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';
import '../controllers/home_controller.dart';

class ClientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientHomeController>(() => ClientHomeController());
    Get.lazyPut<ClientTransactionController>(() => ClientTransactionController());
  }
}