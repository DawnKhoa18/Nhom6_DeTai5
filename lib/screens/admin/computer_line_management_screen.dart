import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_computer_line.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class ComputerLineManagementScreen extends StatefulWidget {
  const ComputerLineManagementScreen({super.key});

  @override
  State<ComputerLineManagementScreen> createState() =>
      _ComputerLineManagementScreenState();
}

class _ComputerLineManagementScreenState
    extends State<ComputerLineManagementScreen> {
  final AdminApiService _apiService = const AdminApiService();

  late Future<List<AdminComputerLine>> _linesFuture;
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _linesFuture = _apiService.getComputerLines();
  }

  void _reload() {
    setState(() {
      _linesFuture = _apiService.getComputerLines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý dòng máy'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      drawer: const AdminNavigationDrawer(
        currentSection: AdminSection.computerLines,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm dòng máy'),
      ),
      body: FutureBuilder<List<AdminComputerLine>>(
        future: _linesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Không tải được danh sách dòng máy.',
              detail: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final lines = snapshot.data ?? const [];
          final filtered = lines.where(_matchesKeyword).toList();

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _HeaderPanel(
                  lines: lines,
                  onKeywordChanged: (value) {
                    setState(() {
                      keyword = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách dòng máy',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${filtered.length} mục',
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const _EmptyState()
                else
                  ...filtered.map((line) => _ComputerLineCard(line: line)),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesKeyword(AdminComputerLine line) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    if (normalizedKeyword.isEmpty) return true;

    return line.name.toLowerCase().contains(normalizedKeyword) ||
        line.brand.toLowerCase().contains(normalizedKeyword) ||
        (line.description ?? '').toLowerCase().contains(normalizedKeyword);
  }
}

class _HeaderPanel extends StatelessWidget {
  final List<AdminComputerLine> lines;
  final ValueChanged<String> onKeywordChanged;

  const _HeaderPanel({
    required this.lines,
    required this.onKeywordChanged,
  });

  @override
  Widget build(BuildContext context) {
    final brands = <String>{for (final line in lines) line.brand}.toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dòng máy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quản lý tên dòng, hãng và mô tả dùng khi nhập thiết bị mới.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo tên dòng, hãng hoặc mô tả',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onKeywordChanged,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryChip(
                label: 'Tổng ${lines.length}',
                color: const Color(0xFF1D4ED8),
              ),
              _SummaryChip(
                label: 'Hãng ${brands.length}',
                color: const Color(0xFF7C3AED),
              ),
              _SummaryChip(
                label:
                    'Thiết bị ${lines.fold<int>(0, (sum, line) => sum + line.deviceCount)}',
                color: const Color(0xFF059669),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComputerLineCard extends StatelessWidget {
  final AdminComputerLine line;

  const _ComputerLineCard({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _brandColor(line.brand);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.computer_rounded, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        line.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    _SummaryChip(
                      label: '${line.deviceCount} máy',
                      color: const Color(0xFF1D4ED8),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  line.brand,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (line.description != null &&
                    line.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    line.description!,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String detail;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 42, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Không có dòng máy phù hợp với từ khóa hiện tại.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}

Color _brandColor(String brand) {
  switch (brand.toLowerCase()) {
    case 'apple':
      return const Color(0xFF111827);
    case 'dell':
      return const Color(0xFF2563EB);
    case 'lenovo':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF059669);
  }
}
