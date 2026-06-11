import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/services/api_config.dart';

import 'cart_manager.dart';
import 'cart_screen.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final int deviceId;

  const EquipmentDetailScreen({super.key, required this.deviceId});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  final _currency = NumberFormat.decimalPattern('vi');
  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _error;

  bool get _isAvailable {
    final status = _text(_detail?['tinhTrang']);
    return status == 'san_sang';
  }
  bool get _isInCart => CartManager.contains(widget.deviceId);

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/user/UserDevices/${widget.deviceId}',
        ),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API ${response.statusCode}: ${response.body}');
      }
      if (!mounted) return;
      setState(() {
        _detail = jsonDecode(response.body) as Map<String, dynamic>;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _addToCart() {
    final detail = _detail;
    if (detail == null || !_isAvailable) return;

    final added = CartManager.addToCart({
      ...detail,
      'price': _number(detail['giaThueNgay']),
    });
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Đã thêm ${_text(detail['name'])} vào giỏ.'
              : 'Thiết bị đã có trong giỏ.',
        ),
        action: SnackBarAction(
          label: 'Xem giỏ',
          onPressed: _openCart,
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Chi tiết thiết bị'),
        backgroundColor: const Color(0xFFF3F7FB),
        actions: [
          IconButton(
            tooltip: 'Giỏ hàng',
            onPressed: _openCart,
            icon: Badge(
              isLabelVisible: CartManager.cartItems.isNotEmpty,
              label: Text(CartManager.cartItems.length.toString()),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: _body(),
      bottomNavigationBar:
          _loading || _detail == null ? null : _bottomAction(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_detail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 52),
              const SizedBox(height: 12),
              Text(_error ?? 'Không tìm thấy thông tin thiết bị.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadDetail,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _DeviceImage(path: _text(detail['imageUrl'])),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _text(detail['name'], fallback: 'Thiết bị'),
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusBadge(available: _isAvailable),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    _text(detail['maTaiSan']),
                    _text(detail['loaiMay']),
                  ].where((value) => value.isNotEmpty).join(' • '),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_currency.format(_number(detail['giaThueNgay']))} đ/ngày',
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tiền cọc dự kiến: '
                        '${_currency.format(_number(detail['tienDatCocDuKien']))} đ '
                        '(${_number(detail['tiLeDatCoc']).toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Giá trị thiết bị: '
                        '${_currency.format(_number(detail['giaTriMay']))} đ',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thông số kỹ thuật',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _spec(Icons.developer_board_outlined, 'CPU', detail['cpu']),
                      _spec(Icons.memory_rounded, 'RAM', detail['ram']),
                      _spec(Icons.storage_rounded, 'Ổ cứng', detail['ssd']),
                      _spec(Icons.videogame_asset_outlined, 'GPU', detail['gpu']),
                      _spec(Icons.monitor_outlined, 'Màn hình', detail['display']),
                      _spec(
                        Icons.laptop_windows_outlined,
                        'Hệ điều hành',
                        detail['heDieuHanh'],
                      ),
                      _spec(
                        Icons.qr_code_2_rounded,
                        'Serial',
                        detail['serialNumber'],
                        last: true,
                      ),
                    ],
                  ),
                ),
                if (_text(detail['ghiChu']).isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Ghi chú',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(_text(detail['ghiChu'])),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _spec(
    IconData icon,
    String label,
    dynamic value, {
    bool last = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: const Color(0xFF0F766E)),
          title: Text(label),
          trailing: SizedBox(
            width: 180,
            child: Text(
              _text(value, fallback: 'Chưa cập nhật'),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (!last) const Divider(height: 1, indent: 56),
      ],
    );
  }

  Widget _bottomAction() {
    final disabled = !_isAvailable || _isInCart;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: FilledButton.icon(
            onPressed: disabled ? (_isInCart ? _openCart : null) : _addToCart,
            icon: Icon(
              _isInCart
                  ? Icons.shopping_cart_checkout_rounded
                  : Icons.add_shopping_cart_rounded,
            ),
            label: Text(
              !_isAvailable
                  ? 'Thiết bị không còn sẵn sàng'
                  : _isInCart
                      ? 'Đã có trong giỏ - Xem giỏ'
                      : 'Thêm vào giỏ thuê',
            ),
          ),
        ),
      ),
    );
  }

  String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  double _number(dynamic value) => (value as num?)?.toDouble() ?? 0;
}

class _DeviceImage extends StatelessWidget {
  final String path;

  const _DeviceImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final resolved = path.startsWith('/')
        ? ApiConfig.baseUrl + path
        : path;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: const Color(0xFFE2E8F0),
        child: resolved.startsWith('http')
            ? Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImageFallback(),
              )
            : Image.asset(
                resolved.isEmpty ? 'assets/images/Lap1.jpg' : resolved,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImageFallback(),
              ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.laptop_mac_rounded, size: 72, color: Color(0xFF64748B)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool available;

  const _StatusBadge({required this.available});

  @override
  Widget build(BuildContext context) {
    final color = available ? const Color(0xFF059669) : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        available ? 'Sẵn sàng' : 'Không sẵn sàng',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}
