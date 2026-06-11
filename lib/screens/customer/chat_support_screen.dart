import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nhom6_detai5_doancuoiki/services/api_config.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({super.key});
  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  final _controller = TextEditingController();
  List<dynamic> _messages = [];
  int? _chatId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _openChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openChat() async {
    try {
      final session = await http.get(Uri.parse(
        '${ApiConfig.baseUrl}/api/user/UserChat/session/${SessionManager.userId}',
      ));
      if (session.statusCode != 200) throw Exception(session.body);
      _chatId = (jsonDecode(session.body) as Map<String, dynamic>)['chatId'] as int?;
      await _loadMessages();
    } catch (error) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMessages() async {
    if (_chatId == null) return;
    final response = await http.get(Uri.parse(
      '${ApiConfig.baseUrl}/api/user/UserChat/messages/$_chatId',
    ));
    if (response.statusCode == 200 && mounted) {
      setState(() {
        _messages = jsonDecode(response.body) as List<dynamic>;
        _loading = false;
      });
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _chatId == null) return;
    _controller.clear();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/user/UserChat/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cuocTroChuyenId': _chatId,
        'nguoiGuiId': SessionManager.userId,
        'noiDung': text,
        'loaiTinNhan': 'text',
      }),
    );
    if (response.statusCode == 200) await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ trực tuyến'),
        actions: [IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(child: Text('Hãy gửi câu hỏi để bắt đầu trò chuyện.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index] as Map<String, dynamic>;
                            final mine = message['nguoiGuiId'] == SessionManager.userId;
                            return Align(
                              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: mine ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(message['noiDung'] ?? '', style: TextStyle(color: mine ? Colors.white : const Color(0xFF0F172A))),
                              ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Nhập nội dung hỗ trợ...', border: OutlineInputBorder()))),
                        IconButton(onPressed: _send, icon: const Icon(Icons.send_rounded)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
