// RecentTransactionsWidget
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_transfer_app/app/modules/client/controllers/home_controller.dart';
import 'package:money_transfer_app/app/modules/client/views/home/widgets/transaction_item_widget.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final ClientHomeController controller;

  const RecentTransactionsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_HISTORY),
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.poppins(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Obx(() {
            if (controller.transactions.isEmpty) {
              return _buildEmptyTransactions();
            }
            return _buildTransactionsList();
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.history, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            'Aucune transaction récente',
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactions = controller.recentTransactions;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionItemWidget(transaction: transaction);
      },
    );
  }
}


/* 
// RecentTransactionsWidget
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_transfer_app/app/modules/client/controllers/home_controller.dart';
import 'package:money_transfer_app/app/modules/client/views/home/widgets/transaction_item_widget.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';

class RecentTransactionsWidget extends StatefulWidget {
  final ClientHomeController controller;

  const RecentTransactionsWidget({super.key, required this.controller});

  @override
  State<RecentTransactionsWidget> createState() => _RecentTransactionsWidgetState();
}

class _RecentTransactionsWidgetState extends State<RecentTransactionsWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.controller.loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_HISTORY),
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.poppins(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Obx(() {
            if (widget.controller.transactions.isEmpty &&
                !widget.controller.isLoading.value) {
              return _buildEmptyTransactions();
            }
            return _buildTransactionsList();
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.history, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            'Aucune transaction récente',
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      children: [
        ListView.separated(
          controller: _scrollController,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.controller.transactions.length + 1,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            if (index < widget.controller.transactions.length) {
              return TransactionItemWidget(
                transaction: widget.controller.transactions[index],
              );
            } else {
              return Obx(() {
                if (widget.controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!widget.controller.hasMoreData.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Plus de transactions à charger',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              });
            }
          },
        ),
      ],
    );
  }
} */