import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class ClientBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientHomeController>(() => ClientHomeController());
  }
}