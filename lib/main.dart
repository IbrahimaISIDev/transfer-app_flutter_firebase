import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/global_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

    // Initialiser AuthController immédiatement
  Get.put(AuthController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Money Transfer App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.INITIAL, // Changez pour la route initiale
      getPages: AppPages.routes,
      initialBinding: GlobalBindings(),
    );
  }
}