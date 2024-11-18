import 'package:get/get.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/client/views/home_view.dart';
import '../modules/client/bindings/client_binding.dart';
import '../modules/distributor/views/home_view.dart';
import '../modules/distributor/bindings/distributor_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: '/login', 
      page: () => LoginView(),
      binding: AuthBinding()
    ),
    GetPage(
      name: '/register', 
      page: () => RegisterView(),
      binding: AuthBinding()
    ),
    GetPage(
      name: '/client/home', 
      page: () => ClientHomeView(),
      binding: ClientBinding()
    ),
    GetPage(
      name: '/distributor/home', 
      page: () => DistributorHomeView(),
      binding: DistributorBinding()
    ),
  ];
}