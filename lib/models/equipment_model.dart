class EquipmentModel {
  final String name;
  final double price;
  final String cpu;
  final String ram;
  final String ssd;
  final String display;
  final String gpu;
  final String imagePath;
  final bool isAvailable; // Quản lý trạng thái Sẵn sàng / Hết hàng

  EquipmentModel({
    required this.name,
    required this.price,
    required this.cpu,
    required this.ram,
    required this.ssd,
    required this.display,
    required this.gpu,
    required this.imagePath,
    this.isAvailable = true, // Mặc định là có sẵn
  });
}