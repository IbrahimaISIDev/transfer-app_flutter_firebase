import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class ContactController extends GetxController {
  final allContacts = <Contact>[].obs;
  Contact? selectedContact;
  final isLoading = true.obs;
  final FavoritesProvider _favoritesProvider = FavoritesProvider();
  RxList<FavoriteModel> favorites = <FavoriteModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
    loadFavorites();
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

        // On ne convertit plus les contacts en favoris ici
        // La liste des favoris est maintenant gérée séparément via loadFavorites()

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

  // Nouvelle méthode pour ajouter un contact aux favoris
  Future<void> addContactToFavorites(Contact contact) async {
    try {
      if (contact.phones.isEmpty) return;

      String currentUserId = getCurrentUserId();
      String phoneNumber =
          contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');

      // Vérifier si ce contact est déjà dans les favoris
      bool isAlreadyFavorite = await _favoritesProvider.isFavorite(
        currentUserId,
        phoneNumber,
      );

      if (!isAlreadyFavorite) {
        String favoriteId =
            FirebaseFirestore.instance.collection('favorites').doc().id;

        FavoriteModel newFavorite = FavoriteModel(
          id: favoriteId,
          userId: currentUserId,
          recipientPhone: phoneNumber,
          recipientFullName: '${contact.displayName}',
          createdAt: DateTime.now(),
        );

        await _favoritesProvider.addToFavorites(newFavorite);
        await loadFavorites(); // Recharger la liste des favoris
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter aux favoris: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
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

            // Option d'ajouter aux favoris
            Get.dialog(
              AlertDialog(
                title: const Text('Ajouter aux favoris?'),
                content:
                    const Text('Voulez-vous ajouter ce contact à vos favoris?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Non'),
                  ),
                  TextButton(
                    onPressed: () {
                      addContactToFavorites(fullContact);
                      Get.back();
                    },
                    child: const Text('Oui'),
                  ),
                ],
              ),
            );

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

  Future<void> loadFavorites() async {
    try {
      String currentUserId = getCurrentUserId();
      var userFavorites =
          await _favoritesProvider.getUserFavorites(currentUserId);
      favorites.value = userFavorites;
      update();
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
    }
  }

  void selectFavorite(
      FavoriteModel favorite, TextEditingController controller) {
    controller.text = favorite.recipientPhone;
    update();
  }

  String getCurrentUserId() {
    try {
      return Get.find<FirebaseService>().getCurrentUserId();
    } catch (e) {
      throw Exception(
          'FirebaseService n\'est pas correctement initialisé : $e');
    }
  }
}
