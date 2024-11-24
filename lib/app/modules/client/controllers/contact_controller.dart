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

/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class ContactController extends GetxController {
  // Observables
  final allContacts = <Contact>[].obs;
  final RxList<FavoriteModel> favorites = <FavoriteModel>[].obs;
  final isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreFavorites = true.obs;

  // State variables
  Contact? selectedContact;
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 2;

  // Dependencies
  final FavoritesProvider _favoritesProvider = FavoritesProvider();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
    loadInitialFavorites();
  }

  // Contacts Loading Methods
  Future<void> loadContacts() async {
    try {
      isLoading.value = true;
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
        allContacts.value = contacts;
        update();
      } else {
        _showErrorSnackbar(
          'Permission refusée',
          'Permission d\'accès aux contacts refusée',
        );
      }
    } catch (e) {
      _showErrorSnackbar(
        'Erreur',
        'Impossible de charger les contacts: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Favorites Loading Methods
  Future<void> loadInitialFavorites() async {
    try {
      String currentUserId = getCurrentUserId();
      favorites.clear();
      _lastDocument = null;
      hasMoreFavorites.value = true;

      var querySnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        
        final initialFavorites = querySnapshot.docs
            .map((doc) => FavoriteModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
            
        favorites.assignAll(initialFavorites);
      }

      hasMoreFavorites.value = querySnapshot.docs.length >= _pageSize;
      update();
    } catch (e) {
      print('Erreur lors du chargement initial des favoris: $e');
      _showErrorSnackbar(
        'Erreur',
        'Impossible de charger les favoris: ${e.toString()}',
      );
    }
  }

  Future<void> loadMoreFavorites() async {
    if (!hasMoreFavorites.value || isLoadingMore.value || _lastDocument == null) {
      return;
    }

    try {
      isLoadingMore.value = true;
      String currentUserId = getCurrentUserId();

      var querySnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize)
          .startAfterDocument(_lastDocument!)
          .get();

      if (querySnapshot.docs.isEmpty) {
        hasMoreFavorites.value = false;
        return;
      }

      _lastDocument = querySnapshot.docs.last;

      final newFavorites = querySnapshot.docs
          .map((doc) => FavoriteModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      favorites.addAll(newFavorites);
      hasMoreFavorites.value = querySnapshot.docs.length >= _pageSize;
      update();
    } catch (e) {
      print('Erreur lors du chargement de plus de favoris: $e');
      _showErrorSnackbar(
        'Erreur',
        'Impossible de charger plus de favoris: ${e.toString()}',
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Contact Selection Methods
  Future<void> pickContact(TextEditingController phoneController) async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            selectedContact = fullContact;
            String formattedNumber = _formatPhoneNumber(fullContact.phones.first.number);
            phoneController.text = formattedNumber;

            _showAddToFavoritesDialog(fullContact);
            update();
          }
        }
      }
    } catch (e) {
      _showErrorSnackbar(
        'Erreur',
        'Impossible d\'accéder aux contacts',
      );
    }
  }

  void selectContact(Contact contact, TextEditingController phoneController) {
    selectedContact = contact;
    if (contact.phones.isNotEmpty) {
      String formattedNumber = _formatPhoneNumber(contact.phones.first.number);
      phoneController.text = formattedNumber;
    }
    Get.back();
    update();
  }

  void selectFavorite(FavoriteModel favorite, TextEditingController controller) {
    controller.text = favorite.recipientPhone;
    update();
  }

  // Favorites Management Methods
  Future<void> addContactToFavorites(Contact contact) async {
    try {
      if (contact.phones.isEmpty) return;

      String currentUserId = getCurrentUserId();
      String phoneNumber = _formatPhoneNumber(contact.phones.first.number);

      bool isAlreadyFavorite = await _favoritesProvider.isFavorite(
        currentUserId,
        phoneNumber,
      );

      if (!isAlreadyFavorite) {
        String favoriteId = _firestore.collection('favorites').doc().id;

        FavoriteModel newFavorite = FavoriteModel(
          id: favoriteId,
          userId: currentUserId,
          recipientPhone: phoneNumber,
          recipientFullName: contact.displayName,
          createdAt: DateTime.now(),
        );

        await _favoritesProvider.addToFavorites(newFavorite);
        await loadInitialFavorites();
        
        Get.snackbar(
          'Succès',
          'Contact ajouté aux favoris',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      }
    } catch (e) {
      _showErrorSnackbar(
        'Erreur',
        'Impossible d\'ajouter aux favoris: ${e.toString()}',
      );
    }
  }

  Future<void> removeFavorite(String favoriteId) async {
    try {
      String currentUserId = getCurrentUserId();
      await _favoritesProvider.removeFavorite(currentUserId, favoriteId);
      await loadInitialFavorites();
      
      Get.snackbar(
        'Succès',
        'Contact retiré des favoris',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      _showErrorSnackbar(
        'Erreur',
        'Impossible de supprimer le favori: ${e.toString()}',
      );
    }
  }

  // Utility Methods
  String getCurrentUserId() {
    try {
      return Get.find<FirebaseService>().getCurrentUserId();
    } catch (e) {
      throw Exception('FirebaseService n\'est pas correctement initialisé : $e');
    }
  }

  String _formatPhoneNumber(String number) {
    return number.replaceAll(RegExp(r'[^\d+]'), '');
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
    );
  }

  void _showAddToFavoritesDialog(Contact contact) {
    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter aux favoris?'),
        content: const Text('Voulez-vous ajouter ce contact à vos favoris?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () {
              addContactToFavorites(contact);
              Get.back();
            },
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }
} */