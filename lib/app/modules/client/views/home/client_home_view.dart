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

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  final ClientHomeController controller = Get.find<ClientHomeController>();
  final AuthController authController = Get.find<AuthController>();

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
                    controller: controller, 
                    authController: authController
                  ),
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
    );
  }
}