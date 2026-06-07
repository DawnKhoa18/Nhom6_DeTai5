class AdminComputerLine {
  final int id;
  final String name;
  final String brand;
  final String? description;
  final int deviceCount;

  const AdminComputerLine({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.deviceCount,
  });

  factory AdminComputerLine.fromJson(Map<String, dynamic> json) {
    return AdminComputerLine(
      id: json['id'] as int? ?? 0,
      name: json['tenDong'] as String? ?? '',
      brand: json['hang'] as String? ?? '',
      description: json['moTa'] as String?,
      deviceCount: json['soLuongMay'] as int? ?? 0,
    );
  }
}
