import 'package:get/get.dart';
import 'package:money_transfer_app/app/modules/client/views/home/client_home_view.dart';
import 'package:money_transfer_app/app/modules/client/views/transaction_history.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/transfer_multiple.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/transfer_schedule.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/transfer_view.dart';
import 'package:money_transfer_app/app/modules/distributor/views/deplafonnement_view.dart';
import 'package:money_transfer_app/app/modules/distributor/views/deposit_view.dart';
import 'package:money_transfer_app/app/modules/distributor/views/home/distributor_home_view.dart';
import 'package:money_transfer_app/app/modules/distributor/views/withdrawal_view.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';
import '../modules/home/welcome_home_screen.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/client/bindings/client_binding.dart';
import '../modules/distributor/bindings/distributor_binding.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.INITIAL, page: () => const WelcomeView()),
    GetPage(
        name: AppRoutes.LOGIN, page: () => LoginView(), binding: AuthBinding()),
    GetPage(
        name: AppRoutes.REGISTER,
        page: () => RegisterView(),
        binding: AuthBinding()),
    GetPage(
        name: AppRoutes.CLIENT_HOME,
        page: () => const ClientHomeView(),
        binding: ClientBinding()),
    GetPage(
        name: AppRoutes.DISTRIBUTOR_HOME,
        page: () => DistributorHomeView(),
        binding: DistributorBinding()),
    GetPage(
        name: AppRoutes.DISTRIBUTOR_UNLIMIT_VIEW,
        page: () => UnlimitView(),
        binding: DistributorBinding()),
    GetPage(
        name: AppRoutes.DISTRIBUTOR_DEPOSIT,
        page: () => DistributorDepositView(),
        binding: DistributorBinding()),
    GetPage(
        name: AppRoutes.DISTRIBUTOR_WITHDRAWAL,
        page: () => WithdrawalView(),
        binding: DistributorBinding()),
    GetPage(
      name: AppRoutes.CLIENT_TRANSFER_SIMPLE,
      page: () => ClientTransferView(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: AppRoutes.CLIENT_TRANSFER_MULTIPLE,
      page: () => ClientMultipleTransferView(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: AppRoutes.CLIENT_TRANSFER_SCHEDULED,
      page: () => ClientScheduledTransferView(),
      binding: ClientBinding(),
    ),
    GetPage(
        name: AppRoutes.CLIENT_TRANSFER_HISTORY,
        page: () => const TransactionHistoryView(),
        binding: ClientBinding())
  ];
}

/* import 'package:get/get.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';
import 'package:money_transfer_app/core/values/middleware.dart';
import '../modules/home/welcome_home_screen.dart';
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
      name: AppRoutes.INITIAL,
      page: () => const WelcomeView(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.CLIENT_HOME,
      page: () => const ClientHomeView(),
      binding: ClientBinding(),
      middlewares: [AuthMiddleware()], // Ajout du middleware
    ),
    GetPage(
      name: AppRoutes.DISTRIBUTOR_HOME,
      page: () => DistributorHomeView(),
      binding: DistributorBinding(),
      middlewares: [AuthMiddleware()], // Ajout du middleware
    ),
  ];
}
 */