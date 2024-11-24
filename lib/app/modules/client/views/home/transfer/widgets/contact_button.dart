import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/modules/client/controllers/contact_controller.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/widgets/paginated_favorites_list.dart';

class ContactButton extends StatelessWidget {
  final TextEditingController phoneController;
  final ContactController contactController;
  final FavoritesProvider favoritesProvider;

  const ContactButton({
    super.key,
    required this.phoneController,
    required this.contactController,
    required this.favoritesProvider,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactController>(
      builder: (controller) => PopupMenuButton<dynamic>(
        icon: const Icon(
          Icons.contacts_outlined,
          color: Color(0xFF4C6FFF),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        itemBuilder: (context) => [
          _buildSelectContactItem(context, controller),
          const PopupMenuItem(child: Divider()),
          PopupMenuItem(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Contacts favoris',
                      style: TextStyle(
                        color: Color(0xFF2D3142),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PaginatedFavoritesList(
                      userId: controller.getCurrentUserId(),
                      onFavoriteSelected: (favorite) {
                        controller.selectFavorite(favorite, phoneController);
                        Navigator.pop(context);
                      },
                      onFavoriteDeleted: (favorite) =>
                          _handleDeleteFavorite(favorite, controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem _buildSelectContactItem(
      BuildContext context, ContactController controller) {
    return PopupMenuItem(
      child: ListTile(
        leading: const Icon(Icons.contact_phone, color: Color(0xFF4C6FFF)),
        title: const Text(
          'Sélectionner un contact',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          controller.pickContact(phoneController);
        },
      ),
    );
  }

  Future<void> _handleDeleteFavorite(
      FavoriteModel favorite, ContactController controller) async {
    bool confirm = await Get.dialog(
          AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Voulez-vous supprimer ce contact des favoris ?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await favoritesProvider.removeFavorite(
        controller.getCurrentUserId(),
        favorite.id,
      );
      controller.loadFavorites();
    }
  }
}

/* 
// contact_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/modules/client/controllers/contact_controller.dart';

class ContactButton extends StatelessWidget {
  final TextEditingController phoneController;
  final ContactController contactController;
  final FavoritesProvider favoritesProvider;
  final ScrollController _scrollController = ScrollController();

  ContactButton({
    super.key,
    required this.phoneController,
    required this.contactController,
    required this.favoritesProvider,
  }) {
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      contactController.loadMoreFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactController>(
      builder: (controller) => PopupMenuButton<dynamic>(
        icon: const Icon(
          Icons.contacts_outlined,
          color: Color(0xFF4C6FFF),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'select_contact',
            child: _buildSelectContactItem(context, controller),
          ),
          const PopupMenuItem(
            enabled: false,
            child: Divider(),
          ),
          PopupMenuItem(
            enabled: false,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Scrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  children: [
                    if (controller.favorites.isNotEmpty) ...[
                      _buildFavoritesHeader(),
                      ...controller.favorites.map(
                        (favorite) => _buildFavoriteItem(favorite, controller),
                      ),
                      if (controller.hasMoreFavorites.value)
                        _buildLoadMoreItem(controller),
                    ] else
                      _buildNoFavoritesItem(),
                  ],
                ),
              ),
            ),
          ),
        ],
        onSelected: (dynamic selected) {
          if (selected == 'select_contact') {
            controller.pickContact(phoneController);
          } else if (selected is FavoriteModel) {
            controller.selectFavorite(selected, phoneController);
          }
        },
      ),
    );
  }

  Widget _buildSelectContactItem(
      BuildContext context, ContactController controller) {
    return ListTile(
      leading: const Icon(Icons.contact_phone, color: Color(0xFF4C6FFF)),
      title: const Text(
        'Sélectionner un contact',
        style: TextStyle(
          color: Color(0xFF2D3142),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        controller.pickContact(phoneController);
      },
    );
  }

  Widget _buildFavoritesHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Contacts favoris',
        style: TextStyle(
          color: Color(0xFF2D3142),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(
      FavoriteModel favorite, ContactController controller) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF4C6FFF).withOpacity(0.1),
        child: const Icon(Icons.star, color: Color(0xFF4C6FFF)),
      ),
      title: Text(
        favorite.recipientFullName ?? 'Sans nom',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        favorite.recipientPhone,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: Colors.red[300]),
        onPressed: () => _handleDeleteFavorite(favorite, controller),
      ),
      onTap: () {
        controller.selectFavorite(favorite, phoneController);
        Navigator.pop(Get.context!);
      },
    );
  }

  Widget _buildNoFavoritesItem() {
    return const ListTile(
      title: Text(
        'Aucun contact favori',
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadMoreItem(ContactController controller) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: controller.isLoadingMore.value
              ? const CircularProgressIndicator()
              : controller.hasMoreFavorites.value
                  ? TextButton(
                      onPressed: () => controller.loadMoreFavorites(),
                      child: const Text('Charger plus'),
                    )
                  : const Text(
                      'Fin de la liste',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteFavorite(
    FavoriteModel favorite,
    ContactController controller,
  ) async {
    final bool confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Confirmation'),
            content:
                const Text('Voulez-vous supprimer ce contact des favoris ?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await favoritesProvider.removeFavorite(
          controller.getCurrentUserId(),
          favorite.id,
        );
        await controller.loadInitialFavorites();
        Get.back();
        Get.snackbar(
          'Succès',
          'Contact supprimé des favoris',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de supprimer le contact',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
  }
}
 */