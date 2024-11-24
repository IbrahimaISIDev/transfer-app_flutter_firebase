import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:money_transfer_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:money_transfer_app/app/modules/client/controllers/home_controller.dart';
import 'package:money_transfer_app/app/modules/client/views/home/widgets/balance_card_widget.dart';
import 'package:money_transfer_app/app/modules/client/views/home/widgets/recent_transactions_widget.dart';
import 'package:money_transfer_app/app/modules/client/views/home/widgets/transfer_options_widget.dart';
import 'package:money_transfer_app/app/modules/client/views/home/widgets/user_header_widget.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  final ClientHomeController controller = Get.find<ClientHomeController>();
  final AuthController authController = Get.find<AuthController>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Get.toNamed(AppRoutes.CLIENT_HOME);
        break;
      case 1:
        Get.toNamed('/transfer');
        break;
      case 2:
        Get.toNamed(AppRoutes.CLIENT_TRANSFER_HISTORY);
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: UserHeaderWidget(
                      controller: controller, authController: authController),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    BalanceCardWidget(controller: controller),
                    const TransferOptionsWidget(),
                    RecentTransactionsWidget(controller: controller)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor:
            Colors.blue, // Vous pouvez ajuster la couleur selon votre thème
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transfert',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
