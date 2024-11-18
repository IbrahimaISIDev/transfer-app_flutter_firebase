import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/global_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Money Transfer App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      getPages: AppPages.routes,
      initialBinding: GlobalBindings(),
    );
  }
}