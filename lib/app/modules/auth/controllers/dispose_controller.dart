// Controller pour gérer la disposition des contrôleurs
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DisposableController extends GetxController {
  final Function onDispose;

  DisposableController({required this.onDispose});

  @override
  void onClose() {
    onDispose();
    super.onClose();
  }
}