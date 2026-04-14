import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTimeRange? _selectedDateRange;
  final _formKey = GlobalKey<FormState>();

  // Mock data máy đã chọn
  List<Map<String, dynamic>> selectedItems = [
    {'id': '1', 'name': 'ThinkPad T14 Gen 3', 'price': 150000},
    {'id': '2', 'name': 'MacBook Pro M2', 'price': 250000},
  ];

  // Hàm mở bộ chọn ngày
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPerDay = selectedItems.fold(0, (sum, item) => sum + (item['price'] as int));
    int days = _selectedDateRange?.duration.inDays ?? 0;
    double expectedTotal = totalPerDay * (days == 0 ? 1 : days); // Tính tạm ít nhất 1 ngày

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gửi yêu cầu thuê', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Section 1: Máy đã chọn ---
              const Text('Thiết bị đã chọn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (selectedItems.isEmpty)
                const Text('Chưa có thiết bị nào trong giỏ', style: TextStyle(color: Colors.grey))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];
                    return Dismissible(
                      key: Key(item['id']),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          selectedItems.removeAt(index);
                        });
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.laptop_mac),
                          ),
                          title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${NumberFormat.decimalPattern('vi').format(item['price'])} đ/ngày'),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // --- Section 2: Thời gian ---
              const Text('Thời gian dự kiến', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDateRange(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.teal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectedDateRange == null
                            ? const Text('Chọn ngày nhận và ngày trả')
                            : Text(
                                '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Section 3: Thông tin đơn vị ---
              const Text('Thông tin người đại diện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tên người đại diện',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phòng ban / Đơn vị',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mục đích sử dụng',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 80), // Padding cho BottomBar
            ],
          ),
        ),
      ),
      // --- Bottom Bar: Tổng tiền & Nút Gửi ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          // ignore: deprecated_member_use
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng dự kiến:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    '${NumberFormat.decimalPattern('vi').format(expectedTotal)} đ',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: selectedItems.isEmpty ? null : () {
                  // Xử lý gửi form
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Gửi Yêu Cầu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}