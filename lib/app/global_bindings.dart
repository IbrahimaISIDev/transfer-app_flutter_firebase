import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';
import 'package:money_transfer_app/app/modules/auth/controllers/auth_controller.dart';

class GlobalBindings implements Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<FirebaseService>(() => FirebaseService());
    
    // Controllers
    Get.lazyPut<AuthController>(() => AuthController());
  }
}