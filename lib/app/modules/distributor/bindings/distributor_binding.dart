import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/operation_controller.dart';

class DistributorBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DistributorHomeController>(() => DistributorHomeController());
    Get.lazyPut<DistributorOperationController>(() => DistributorOperationController());
  }
}