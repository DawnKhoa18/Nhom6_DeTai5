class AdminChatConversation {
  final int id;
  final String companyName;
  final int customerId;
  final String customerName;
  final int? staffId;
  final String? staffName;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;
  final String? lastMessage;

  const AdminChatConversation({
    required this.id,
    required this.companyName,
    required this.customerId,
    required this.customerName,
    required this.staffId,
    required this.staffName,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
    required this.lastMessage,
  });

  factory AdminChatConversation.fromJson(Map<String, dynamic> json) {
    return AdminChatConversation(
      id: json['id'] as int? ?? 0,
      companyName: json['tenDonVi'] as String? ?? 'Không rõ đơn vị',
      customerId: json['khachHangId'] as int? ?? 0,
      customerName: json['tenKhachHang'] as String? ?? 'Khách hàng',
      staffId: json['nhanVienPhuTrachId'] as int?,
      staffName: json['tenNhanVien'] as String?,
      title: json['tieuDe'] as String? ?? 'Yêu cầu hỗ trợ',
      status: json['trangThai'] as String? ?? '',
      createdAt: DateTime.tryParse(json['ngayTao']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['ngayCapNhat']?.toString() ?? '') ??
          DateTime.now(),
      unreadCount: json['soTinChuaDoc'] as int? ?? 0,
      lastMessage: json['tinNhanCuoi'] as String?,
    );
  }
}

class AdminChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String content;
  final String type;
  final bool isRead;
  final DateTime sentAt;

  const AdminChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.isRead,
    required this.sentAt,
  });

  factory AdminChatMessage.fromJson(Map<String, dynamic> json) {
    return AdminChatMessage(
      id: json['id'] as int? ?? 0,
      conversationId: json['cuocTroChuyenId'] as int? ?? 0,
      senderId: json['nguoiGuiId'] as int? ?? 0,
      senderName: json['tenNguoiGui'] as String? ?? 'Người dùng',
      content: json['noiDung'] as String? ?? '',
      type: json['loaiTinNhan'] as String? ?? 'text',
      isRead: json['daDoc'] as bool? ?? false,
      sentAt: DateTime.tryParse(json['ngayGui']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
