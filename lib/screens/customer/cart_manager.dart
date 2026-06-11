class CartManager {
  // Lưu trữ danh sách các thiết bị được chọn vào giỏ hàng
  static List<Map<String, dynamic>> cartItems = [];

  static bool contains(int id) {
    return cartItems.any((element) => element['id'] == id);
  }

  static bool addToCart(Map<String, dynamic> item) {
    if (contains(item['id'] as int)) return false;
    cartItems.add(item);
    return true;
  }

  static void removeFromCart(int id) {
    cartItems.removeWhere((element) => element['id'] == id);
  }

  static void clearCart() {
    cartItems.clear();
  }
}
