class AdminDeviceImage {
  final int id;
  final int deviceId;
  final String path;
  final bool isPrimary;

  const AdminDeviceImage({
    required this.id,
    required this.deviceId,
    required this.path,
    required this.isPrimary,
  });

  factory AdminDeviceImage.fromJson(Map<String, dynamic> json) {
    return AdminDeviceImage(
      id: json['id'] as int? ?? 0,
      deviceId: json['mayTinhId'] as int? ?? 0,
      path: json['duongDanAnh'] as String? ?? '',
      isPrimary: json['laAnhDaiDien'] as bool? ?? false,
    );
  }
}
