// import 'package:flutter/material.dart';
// import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:money_transfer_app/app/modules/client/controllers/home_controller.dart';
// import 'package:money_transfer_app/app/modules/client/views/home/widgets/transaction_item_widget.dart';

// class TransactionHistoryWidget extends StatelessWidget {
//   final ClientHomeController controller;

//   const TransactionHistoryWidget({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Obx(() {
//             if (controller.transactions.isEmpty) {
//               return _buildEmptyTransactions();
//             }
//             return _buildTransactionsList();
//           }),
//         ),
//         _buildPaginationControls(),
//       ],
//     );
//   }

//   Widget _buildEmptyTransactions() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.history, size: 50, color: Colors.grey[300]),
//           const SizedBox(height: 10),
//           Text(
//             'Aucune transaction',
//             style: GoogleFonts.poppins(
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionsList() {
//     return ListView.separated(
//       padding: const EdgeInsets.all(20),
//       itemCount: controller.paginatedTransactions.length,
//       separatorBuilder: (context, index) => const Divider(),
//       itemBuilder: (context, index) {
//         final transaction = controller.paginatedTransactions[index];
//         return TransactionItemWidget(transaction: transaction);
//       },
//     );
//   }

//   Widget _buildPaginationControls() {
//     return Obx(() => Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back_ios),
//             onPressed: controller.hasPreviousPage
//                 ? () => controller.previousPage()
//                 : null,
//           ),
//           Text(
//             'Page ${controller.currentPage.value + 1}',
//             style: GoogleFonts.poppins(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.arrow_forward_ios),
//             onPressed: controller.hasNextPage
//                 ? () => controller.nextPage()
//                 : null,
//           ),
//         ],
//       ),
//     ));
//   }
// }