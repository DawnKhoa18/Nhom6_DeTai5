import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_chat.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_user.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class ChatManagementScreen extends StatefulWidget {
  const ChatManagementScreen({super.key});

  @override
  State<ChatManagementScreen> createState() => _ChatManagementScreenState();
}

class _ChatManagementScreenState extends State<ChatManagementScreen> {
  final AdminApiService api = const AdminApiService();
  late Future<List<AdminChatConversation>> future;
  String status = 'all';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    future = api.getChats();
  }

  void reload() => setState(() => future = api.getChats());

  void openChat(AdminChatConversation chat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8FAFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ChatSheet(api: api, chat: chat, onChanged: reload),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Chat hỗ trợ'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      drawer: const AdminNavigationDrawer(currentSection: AdminSection.chats),
      body: FutureBuilder<List<AdminChatConversation>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(detail: snapshot.error.toString(), retry: reload);
          }
          final chats = snapshot.data ?? const [];
          final filtered = chats.where(matches).toList();
          return RefreshIndicator(
            onRefresh: () async => reload(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Header(
                  chats: chats,
                  status: status,
                  onStatus: (value) => setState(() => status = value),
                  onSearch: (value) => setState(() => keyword = value),
                ),
                const SizedBox(height: 18),
                Text(
                  'Cuộc trò chuyện (' + filtered.length.toString() + ')',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const _EmptyView()
                else
                  ...filtered.map(
                    (chat) => _ChatCard(
                      chat: chat,
                      onTap: () => openChat(chat),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool matches(AdminChatConversation chat) {
    final search = keyword.trim().toLowerCase();
    final textMatch = search.isEmpty ||
        chat.title.toLowerCase().contains(search) ||
        chat.customerName.toLowerCase().contains(search) ||
        chat.companyName.toLowerCase().contains(search);
    return textMatch && (status == 'all' || chat.status == status);
  }
}

class _ChatSheet extends StatefulWidget {
  final AdminApiService api;
  final AdminChatConversation chat;
  final VoidCallback onChanged;

  const _ChatSheet({
    required this.api,
    required this.chat,
    required this.onChanged,
  });

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final TextEditingController controller = TextEditingController();
  late Future<List<AdminChatMessage>> messages;
  late Future<List<AdminUser>> users;
  AdminUser? staff;
  late String currentStatus;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.chat.status;
    messages = widget.api.getChatMessages(widget.chat.id);
    users = widget.api.getUsers();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void reloadMessages() {
    setState(() => messages = widget.api.getChatMessages(widget.chat.id));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.88,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chat.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        widget.chat.customerName +
                            ' • ' +
                            widget.chat.companyName,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: updateStatus,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'dang_mo', child: Text('Mở lại')),
                    PopupMenuItem(
                      value: 'dang_xu_ly',
                      child: Text('Đang xử lý'),
                    ),
                    PopupMenuItem(
                      value: 'da_dong',
                      child: Text('Đóng cuộc trò chuyện'),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: FutureBuilder<List<AdminUser>>(
              future: users,
              builder: (context, snapshot) {
                final available = (snapshot.data ?? const [])
                    .where(
                      (user) =>
                          (user.role == 'admin' ||
                              user.role == 'nhan_vien') &&
                          user.status == 'hoat_dong',
                    )
                    .toList();
                if (staff == null && available.isNotEmpty) {
                  final assigned = available.where(
                    (user) => user.id == widget.chat.staffId,
                  );
                  staff = assigned.isNotEmpty ? assigned.first : available.first;
                }
                return DropdownButtonFormField<AdminUser>(
                  value: staff,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Nhân viên gửi/tiếp nhận',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: available
                      .map(
                        (user) => DropdownMenuItem(
                          value: user,
                          child: Text(user.fullName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => staff = value),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<AdminChatMessage>>(
              future: messages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? const [];
                if (items.isEmpty) {
                  return const Center(child: Text('Chưa có tin nhắn.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final message = items[index];
                    return _MessageBubble(
                      message: message,
                      fromStaff:
                          message.senderId != widget.chat.customerId,
                    );
                  },
                );
              },
            ),
          ),
          if (currentStatus == 'da_dong')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFE2E8F0),
              child: const Text(
                'Cuộc trò chuyện đã đóng. Mở lại để trả lời.',
                textAlign: TextAlign.center,
              ),
            )
          else
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Nhập nội dung trả lời',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Gửi tin nhắn',
                      onPressed: sending ? null : send,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty || staff == null) return;
    setState(() => sending = true);
    try {
      await widget.api.sendChatMessage(
        chatId: widget.chat.id,
        senderId: staff!.id,
        content: text,
      );
      controller.clear();
      currentStatus = 'dang_xu_ly';
      reloadMessages();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi thất bại: ' + error.toString())),
      );
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> updateStatus(String status) async {
    try {
      await widget.api.updateChat(
        chatId: widget.chat.id,
        status: status,
        staffId: staff?.id,
      );
      if (!mounted) return;
      setState(() => currentStatus = status);
      widget.onChanged();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: ' + error.toString())),
      );
    }
  }
}

class _Header extends StatelessWidget {
  final List<AdminChatConversation> chats;
  final String status;
  final ValueChanged<String> onStatus;
  final ValueChanged<String> onSearch;

  const _Header({
    required this.chats,
    required this.status,
    required this.onStatus,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trung tâm hỗ trợ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text('Tiếp nhận, phân công và trả lời khách hàng.'),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo tiêu đề, khách hàng hoặc đơn vị',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onSearch,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              _StatusChip(
                text: 'Tất cả ' + chats.length.toString(),
                selected: status == 'all',
                onTap: () => onStatus('all'),
              ),
              _StatusChip(
                text: 'Đang mở ' + count('dang_mo').toString(),
                selected: status == 'dang_mo',
                onTap: () => onStatus('dang_mo'),
              ),
              _StatusChip(
                text: 'Đang xử lý ' + count('dang_xu_ly').toString(),
                selected: status == 'dang_xu_ly',
                onTap: () => onStatus('dang_xu_ly'),
              ),
              _StatusChip(
                text: 'Đã đóng ' + count('da_dong').toString(),
                selected: status == 'da_dong',
                onTap: () => onStatus('da_dong'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int count(String value) =>
      chats.where((chat) => chat.status == value).length;
}

class _ChatCard extends StatelessWidget {
  final AdminChatConversation chat;
  final VoidCallback onTap;
  const _ChatCard({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(chat.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(Icons.support_agent_rounded, color: color),
        ),
        title: Text(
          chat.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          chat.customerName +
              ' • ' +
              chat.companyName +
              '\n' +
              (chat.lastMessage ?? 'Chưa có tin nhắn'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: chat.unreadCount > 0
            ? CircleAvatar(
                radius: 13,
                backgroundColor: const Color(0xFFDC2626),
                child: Text(
                  chat.unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AdminChatMessage message;
  final bool fromStaff;
  const _MessageBubble({required this.message, required this.fromStaff});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromStaff ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fromStaff ? const Color(0xFF1D4ED8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: TextStyle(
                color: fromStaff ? Colors.white70 : const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: fromStaff ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm dd/MM').format(message.sentAt),
              style: TextStyle(
                color: fromStaff ? Colors.white60 : const Color(0xFF94A3B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _StatusChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor:
          selected ? const Color(0xFFE0ECFF) : const Color(0xFFF1F5F9),
      label: Text(text),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String detail;
  final VoidCallback retry;
  const _ErrorView({required this.detail, required this.retry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Không tải được danh sách chat.'),
          Text(detail, textAlign: TextAlign.center),
          FilledButton(onPressed: retry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Chưa có cuộc trò chuyện phù hợp.'));
  }
}

Color _statusColor(String value) {
  if (value == 'dang_mo') return const Color(0xFFEA580C);
  if (value == 'dang_xu_ly') return const Color(0xFF2563EB);
  return const Color(0xFF64748B);
}
