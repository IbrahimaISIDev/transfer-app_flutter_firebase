import 'package:get/get.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/deposit_operation_controller.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/withdrawal_operation_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/operation_controller.dart';

class DistributorBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DistributorHomeController>(() => DistributorHomeController());
    Get.lazyPut<DistributorOperationController>(() => DistributorOperationController());
    Get.lazyPut<DistributorDepositController>(() => DistributorDepositController());
    Get.lazyPut<DistributorWithdrawalController>(() => DistributorWithdrawalController());
  }
}