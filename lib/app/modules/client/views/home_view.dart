// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:money_transfer_app/app/data/models/transaction_model.dart';
// import 'package:money_transfer_app/app/modules/auth/controllers/auth_controller.dart';
// import 'package:money_transfer_app/app/modules/client/controllers/home_controller.dart';
// import 'package:money_transfer_app/app/routes/app_routes.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:intl/intl.dart';

// class ClientHomeView extends StatefulWidget {
//   const ClientHomeView({super.key});

//   @override
//   State<ClientHomeView> createState() => _ClientHomeViewState();
// }

// class _ClientHomeViewState extends State<ClientHomeView> {
//   final ClientHomeController controller = Get.find<ClientHomeController>();
//   final AuthController authController = Get.find<AuthController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: controller.refreshData,
//           child: CustomScrollView(
//             slivers: [
//               _buildHeader(context),
//               SliverToBoxAdapter(child: _buildMainContent()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   SliverAppBar _buildHeader(BuildContext context) {
//     return SliverAppBar(
//       expandedHeight: 120,
//       floating: true,
//       pinned: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Bienvenue',
//                       style: GoogleFonts.poppins(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     Obx(() => Text(
//                           controller.userName,
//                           style: GoogleFonts.poppins(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )),
//                     Obx(() => Text(
//                           controller.userEmail,
//                           style: GoogleFonts.poppins(
//                             color: Colors.grey[500],
//                             fontSize: 12,
//                           ),
//                         )),
//                     Obx(() => Text(
//                           controller.userPhone,
//                           style: GoogleFonts.poppins(
//                             color: Colors.grey[500],
//                             fontSize: 14,
//                           ),
//                         )),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: [
//                   _buildActionButton(
//                     icon: Icons.qr_code,
//                     color: Colors.blue,
//                     onPressed: () => _showQRCode(context),
//                   ),
//                   const SizedBox(width: 12),
//                   _buildActionButton(
//                     icon: Icons.logout,
//                     color: Colors.red,
//                     onPressed: () => _showLogoutConfirmation(context),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return CircleAvatar(
//       radius: 20,
//       backgroundColor: color.withOpacity(0.1),
//       child: IconButton(
//         icon: Icon(icon, color: color),
//         onPressed: onPressed,
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     return Column(
//       children: [
//         _buildBalanceCard(),
//         _buildTransferOptions(),
//         _buildRecentTransactions(),
//       ],
//     );
//   }

//   Widget _buildBalanceCard() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue[700]!, Colors.blue[900]!],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.3),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(25),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Solde disponible',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white70,
//                       fontSize: 16,
//                     ),
//                   ),
//                   Obx(() => IconButton(
//                         icon: Icon(
//                           controller.isBalanceVisible.value
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: Colors.white,
//                         ),
//                         onPressed: controller.toggleBalanceVisibility,
//                       )),
//                 ],
//               ),
//               const SizedBox(height: 15),
//               Obx(() => Text(
//                     controller.isBalanceVisible.value
//                         ? '${NumberFormat.currency(locale: 'fr_FR', symbol: 'F CFA').format(controller.balance.value)}'
//                         : '• • • • • •',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTransferOptions() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Transferts',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 15),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildTransferButton(
//                 icon: Icons.send,
//                 label: 'Simple',
//                 color: Colors.blue,
//                 onTap: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_SIMPLE),
//               ),
//               _buildTransferButton(
//                 icon: Icons.group,
//                 label: 'Multiple',
//                 color: Colors.purple,
//                 onTap: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_MULTIPLE),
//               ),
//               _buildTransferButton(
//                 icon: Icons.schedule,
//                 label: 'Programmé',
//                 color: Colors.orange,
//                 onTap: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_SCHEDULED),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransferButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: 100,
//         padding: const EdgeInsets.symmetric(vertical: 15),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 30),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 color: color,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentTransactions() {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Transactions récentes',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_HISTORY),
//                 child: Text(
//                   'Voir tout',
//                   style: GoogleFonts.poppins(
//                     color: Colors.blue,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           Obx(() {
//             if (controller.recentTransactions.isEmpty) {
//               return _buildEmptyTransactions();
//             }
//             return _buildTransactionsList();
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyTransactions() {
//     return Center(
//       child: Column(
//         children: [
//           Icon(Icons.history, size: 50, color: Colors.grey[300]),
//           const SizedBox(height: 10),
//           Text(
//             'Aucune transaction récente',
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
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: controller.recentTransactions.length,
//       separatorBuilder: (context, index) => const Divider(),
//       itemBuilder: (context, index) {
//         final transaction = controller.recentTransactions[index];
//         return _buildTransactionItem(transaction);
//       },
//     );
//   }

//   Widget _buildTransactionItem(TransactionModel transaction) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Container(
//         width: 50,
//         height: 50,
//         decoration: BoxDecoration(
//           color: _getTransactionColor(transaction.type).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Icon(
//           _getTransactionIcon(transaction.type),
//           color: _getTransactionColor(transaction.type),
//         ),
//       ),
//       title: Text(
//         transaction.type.toString().split('.').last.capitalize ?? '',
//         style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
//       ),
//       subtitle: Text(
//         transaction.timestamp != null
//             ? DateFormat('dd/MM/yyyy HH:mm').format(transaction.timestamp!)
//             : 'Date inconnue',
//         style: GoogleFonts.poppins(
//           color: Colors.grey,
//           fontSize: 12,
//         ),
//       ),
//       trailing: Text(
//         '${transaction.amount.toStringAsFixed(2)} F CFA',
//         style: GoogleFonts.poppins(
//           color: _getTransactionColor(transaction.type),
//           fontWeight: FontWeight.bold,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

//   void _showQRCode(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Votre QR Code',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               QrImageView(
//                 data: controller.currentUser.value?.phoneNumber ?? '',
//                 version: QrVersions.auto,
//                 size: 200,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Scannez pour recevoir un paiement',
//                 style: GoogleFonts.poppins(
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showLogoutConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.logout,
//                 size: 50,
//                 color: Colors.red,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Déconnexion',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Voulez-vous vraiment vous déconnecter ?',
//                 style: GoogleFonts.poppins(
//                   color: Colors.grey[600],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text(
//                       'Annuler',
//                       style: GoogleFonts.poppins(
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 30,
//                         vertical: 12,
//                       ),
//                     ),
//                     onPressed: () async {
//                       Navigator.pop(context);
//                       await authController.logout();
//                     },
//                     child: Text(
//                       'Déconnexion',
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getTransactionColor(TransactionType type) {
//     switch (type) {
//       case TransactionType.transfer:
//         return Colors.blue;
//       case TransactionType.deposit:
//         return Colors.green;
//       case TransactionType.withdrawal:
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getTransactionIcon(TransactionType type) {
//     switch (type) {
//       case TransactionType.transfer:
//         return Icons.send;
//       case TransactionType.deposit:
//         return Icons.add;
//       case TransactionType.withdrawal:
//         return Icons.remove;
//       default:
//         return Icons.swap_horiz;
//     }
//   }
// }
