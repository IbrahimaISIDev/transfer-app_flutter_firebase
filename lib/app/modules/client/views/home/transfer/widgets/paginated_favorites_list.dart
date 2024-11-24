import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';

class PaginatedFavoritesList extends StatefulWidget {
  final String userId;
  final Function(FavoriteModel) onFavoriteSelected;
  final Function(FavoriteModel) onFavoriteDeleted;

  const PaginatedFavoritesList({
    Key? key,
    required this.userId,
    required this.onFavoriteSelected,
    required this.onFavoriteDeleted,
  }) : super(key: key);

  @override
  State<PaginatedFavoritesList> createState() => _PaginatedFavoritesListState();
}

class _PaginatedFavoritesListState extends State<PaginatedFavoritesList> {
  final ScrollController _scrollController = ScrollController();
  final FavoritesProvider _favoritesProvider = FavoritesProvider();
  final List<FavoriteModel> _favorites = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadMoreFavorites();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreFavorites();
    }
  }

  Future<void> _loadMoreFavorites() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newFavorites = await _favoritesProvider.getUserFavorites(
        widget.userId,
        lastDocument: _lastDocument,
      );

      if (newFavorites.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      // Obtenir le dernier document de manière asynchrone
      final lastDoc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(newFavorites.last.id)
          .get();

      // Une fois que nous avons toutes les données, mettre à jour l'état
      setState(() {
        _favorites.addAll(newFavorites);
        _lastDocument = lastDoc;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      Get.snackbar(
        'Erreur',
        'Impossible de charger les favoris: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: _favorites.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _favorites.length) {
          return _buildLoadingIndicator();
        }

        final favorite = _favorites[index];
        return _buildFavoriteItem(favorite);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildFavoriteItem(FavoriteModel favorite) {
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
        onPressed: () => widget.onFavoriteDeleted(favorite),
      ),
      onTap: () => widget.onFavoriteSelected(favorite),
    );
  }
}

/* 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';

class PaginatedFavoritesList extends StatefulWidget {
  final String userId;
  final Function(FavoriteModel) onFavoriteSelected;
  final Function(FavoriteModel) onFavoriteDeleted;

  const PaginatedFavoritesList({
    Key? key,
    required this.userId,
    required this.onFavoriteSelected,
    required this.onFavoriteDeleted,
  }) : super(key: key);

  @override
  State<PaginatedFavoritesList> createState() => _PaginatedFavoritesListState();
}

class _PaginatedFavoritesListState extends State<PaginatedFavoritesList> {
  final ScrollController _scrollController = ScrollController();
  final FavoritesProvider _favoritesProvider = FavoritesProvider();
  final List<FavoriteModel> _favorites = [];
  bool _isLoading = false;
  bool _isInitialLoading = true; // Nouveau flag pour le chargement initial
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadMoreFavorites();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreFavorites();
    }
  }

  Future<void> _loadMoreFavorites() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newFavorites = await _favoritesProvider.getUserFavorites(
        widget.userId,
        lastDocument: _lastDocument,
      );

      if (newFavorites.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
          _isInitialLoading = false;
        });
        return;
      }

      final lastDoc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(newFavorites.last.id)
          .get();

      setState(() {
        _favorites.addAll(newFavorites);
        _lastDocument = lastDoc;
        _isLoading = false;
        _isInitialLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isInitialLoading = false;
      });
      
      Get.snackbar(
        'Erreur',
        'Impossible de charger les favoris: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_favorites.isEmpty) {
      return const Center(
        child: Text(
          'Aucun contact favori',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: _favorites.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _favorites.length) {
              return _buildLoadingIndicator();
            }

            final favorite = _favorites[index];
            return _buildFavoriteItem(favorite);
          },
        ),
        if (_isLoading && !_isInitialLoading)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(FavoriteModel favorite) {
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
        onPressed: () => widget.onFavoriteDeleted(favorite),
      ),
      onTap: () => widget.onFavoriteSelected(favorite),
    );
  }
} */