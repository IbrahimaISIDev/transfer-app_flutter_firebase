// favorites_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';

class FavoritesProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isFavorite(String userId, String recipientPhone) async {
    final QuerySnapshot result = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('recipientPhone', isEqualTo: recipientPhone)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> addToFavorites(FavoriteModel favorite) async {
    await _firestore
        .collection('favorites')
        .doc(favorite.id)
        .set(favorite.toJson());
  }

  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
            (doc) => FavoriteModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> removeFavorite(String userId, String favoriteId) async {
    await _firestore.collection('favorites').doc(favoriteId).delete();
  }

  Future<void> clearAllFavorites(String userId) async {
    var favorites = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .get();

    WriteBatch batch = _firestore.batch();
    for (var doc in favorites.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
