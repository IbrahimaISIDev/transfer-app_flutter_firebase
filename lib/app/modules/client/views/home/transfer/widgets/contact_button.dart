import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/modules/client/controllers/contact_controller.dart';

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
          ...controller.favorites.isNotEmpty
              ? [
                  _buildFavoritesHeader(),
                  ...controller.favorites
                      .map((favorite) => _buildFavoriteItem(favorite, controller)),
                ]
              : [_buildNoFavoritesItem()],
        ],
        onSelected: (dynamic selected) {
          if (selected is FavoriteModel) {
            controller.selectFavorite(selected, phoneController);
          }
        },
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

  PopupMenuItem _buildFavoritesHeader() {
    return const PopupMenuItem(
      enabled: false,
      child: Text(
        'Contacts favoris',
        style: TextStyle(
          color: Color(0xFF2D3142),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  PopupMenuItem _buildFavoriteItem(
      FavoriteModel favorite, ContactController controller) {
    return PopupMenuItem(
      value: favorite,
      child: ListTile(
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
      ),
    );
  }

  PopupMenuItem _buildNoFavoritesItem() {
    return const PopupMenuItem(
      enabled: false,
      child: ListTile(
        title: Text(
          'Aucun contact favori',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
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
      Get.back();
    }
  }
}