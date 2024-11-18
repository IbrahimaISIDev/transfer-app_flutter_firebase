import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class ClientHomeView extends GetView<ClientHomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accueil Client')),
      body: Obx(() => Column(
        children: [
          // Affichage solde
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.isBalanceVisible.value 
                ? '${controller.balance} €' 
                : '******'),
              IconButton(
                icon: Icon(Icons.remove_red_eye),
                onPressed: controller.toggleBalanceVisibility,
              )
            ],
          ),
          // Liste transactions
          Expanded(
            child: ListView.builder(
              itemCount: controller.transactions.length,
              itemBuilder: (context, index) {
                var transaction = controller.transactions[index];
                return ListTile(
                  title: Text('${transaction.amount} €'),
                  subtitle: Text(transaction.type.toString()),
                );
              },
            ),
          )
        ],
      )),
    );
  }
}