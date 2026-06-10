import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({super.key});

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  List<dynamic> messages = [];
  final _controller = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      // Gọi mã phòng chat ID = 1 có sẵn từ dữ liệu mẫu SQL
      final response = await http.get(Uri.parse('http://10.0.2.2:5135/api/user/UserChat/messages/1'));
      if (response.statusCode == 200) {
        setState(() {
          messages = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text;
    _controller.clear();

    final Map<String, dynamic> msgDto = {
      "cuocTroChuyenId": 1,
      "nguoiGuiId": 3, // Khách hàng Nguyễn Văn An gửi
      "noiDung": text,
      "loaiTinNhan": "text"
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5135/api/user/UserChat/send'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(msgDto),
      );
      if (response.statusCode == 200) {
        fetchMessages(); // Tải lại tin nhắn mới
      }
    } catch (e) {
      print("Lỗi gửi tin nhắn: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hỗ trợ trực tuyến')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      bool isMe = m['nguoiGuiId'] == 3;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.teal : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(m['noiDung'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Nhập câu hỏi cần hỗ trợ kỹ thuật...', border: InputBorder.none),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.send, color: Colors.teal), onPressed: sendMessage),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}