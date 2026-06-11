import 'dart:convert';
import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_report.dart';
import 'package:share_plus/share_plus.dart';

class ReportExportService {
  const ReportExportService();

  Future<void> shareCsv({
    required AdminReport report,
    required Rect sharePositionOrigin,
  }) async {
    final date = DateFormat('yyyyMMdd');
    final fileName =
        'bao_cao_${date.format(report.from)}_${date.format(report.to)}.csv';
    final content = '\uFEFF${_buildCsv(report)}';

    await SharePlus.instance.share(
      ShareParams(
        title: 'Xuất báo cáo thống kê',
        subject: 'Báo cáo thống kê thiết bị cho thuê',
        files: [
          XFile.fromData(
            utf8.encode(content),
            mimeType: 'text/csv',
          ),
        ],
        fileNameOverrides: [fileName],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  String _buildCsv(AdminReport report) {
    final date = DateFormat('dd/MM/yyyy');
    final rows = <List<Object?>>[
      ['BÁO CÁO THỐNG KÊ THIẾT BỊ CHO THUÊ'],
      ['Từ ngày', date.format(report.from)],
      ['Đến ngày', date.format(report.to)],
      [],
      ['TỔNG QUAN'],
      ['Chỉ tiêu', 'Giá trị'],
      ['Doanh thu thực thu', report.overview.totalRevenue],
      ['Số giao dịch', report.overview.paymentCount],
      ['Số đơn thuê', report.overview.rentalOrderCount],
      ['Thiết bị đã sử dụng', report.overview.usedDeviceCount],
      ['Tổng thiết bị', report.overview.totalDeviceCount],
      ['Tỷ lệ sử dụng (%)', report.overview.utilizationRate],
      [],
      ['DOANH THU THEO THÁNG'],
      ['Năm', 'Tháng', 'Doanh thu', 'Số giao dịch'],
      ...report.monthlyRevenue.map(
        (item) => [
          item.year,
          item.month,
          item.revenue,
          item.transactionCount,
        ],
      ),
      [],
      ['PHƯƠNG THỨC THANH TOÁN'],
      ['Phương thức', 'Số giao dịch', 'Số tiền'],
      ...report.paymentMethods.map(
        (item) => [
          _methodText(item.method),
          item.count,
          item.amount,
        ],
      ),
    ];

    return rows.map((row) => row.map(_escape).join(',')).join('\r\n');
  }

  String _escape(Object? value) {
    final text = value?.toString() ?? '';
    return '"${text.replaceAll('"', '""')}"';
  }

  String _methodText(String value) {
    switch (value) {
      case 'tien_mat':
        return 'Tiền mặt';
      case 'chuyen_khoan':
        return 'Chuyển khoản';
      case 'vi_dien_tu':
        return 'Ví điện tử';
      default:
        return value;
    }
  }
}
