import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist_model.dart';

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<Wishlist>>((ref) {
  return WishlistNotifier();
});

class WishlistNotifier extends StateNotifier<List<Wishlist>> {
  WishlistNotifier() : super([]) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('wishListProducts');
    if (data != null) {
      state = Wishlist.decode(data);
    }
  }

  Future<void> addWishlist(Wishlist item) async {
    // Check if item already exists
    if (!state.any((element) => element.id == item.id)) {
      state = [...state, item];
      await _saveWishlist();
    }
  }

  Future<void> removeWishlist(int id) async {
    state = state.where((element) => element.id != id).toList();
    await _saveWishlist();
  }
  
  Future<void> clearWishlist() async {
    state = [];
    await _saveWishlist();
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedData = Wishlist.encode(state);
    prefs.setString('wishListProducts', encodedData);
  }

  bool isInWishlist(int id) {
    return state.any((element) => element.id == id);
  }
}
