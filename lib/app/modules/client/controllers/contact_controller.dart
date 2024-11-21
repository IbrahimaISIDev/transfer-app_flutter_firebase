import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

// Contact Controller
class ContactController extends GetxController {
  final favorites = <Contact>[].obs;
  final allContacts = <Contact>[].obs;
  Contact? selectedContact;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      isLoading.value = true;
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
        allContacts.value = contacts;
        favorites.value = contacts
            .where((contact) =>
                    contact.phones.isNotEmpty &&
                    contact.phones.first.number
                        .isNotEmpty // Supprimer contact.favorite
                )
            .toList();

        update();
      } else {
        Get.snackbar(
          'Erreur',
          'Permission d\'accès aux contacts refusée',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les contacts: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickContact(TextEditingController phoneController) async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            selectedContact = fullContact;
            String formattedNumber = fullContact.phones.first.number
                .replaceAll(RegExp(r'[^\d+]'), '');
            phoneController.text = formattedNumber;
            update();
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'accéder aux contacts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void selectContact(Contact contact, TextEditingController phoneController) {
    selectedContact = contact;
    if (contact.phones.isNotEmpty) {
      String formattedNumber =
          contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');
      phoneController.text = formattedNumber;
    }
    Get.back();
    update();
  }
}
