class CartManager {
  // Lưu trữ danh sách các thiết bị được chọn vào giỏ hàng
  static List<Map<String, dynamic>> cartItems = [];

  static void addToCart(Map<String, dynamic> item) {
    if (!cartItems.any((element) => element['id'] == item['id'])) {
      cartItems.add(item);
    }
  }

  static void removeFromCart(int id) {
    cartItems.removeWhere((element) => element['id'] == id);
  }

  static void clearCart() {
    cartItems.clear();
  }
}