class AdminDamageLevel {
  final int id;
  final String name;
  final String? description;
  final double compensationPercent;

  const AdminDamageLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.compensationPercent,
  });

  factory AdminDamageLevel.fromJson(Map<String, dynamic> json) {
    return AdminDamageLevel(
      id: json['id'] as int? ?? 0,
      name: json['tenMucDo'] as String? ?? '',
      description: json['moTa'] as String?,
      compensationPercent: _toDouble(json['phanTramDenBu']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
