class AdminReport {
  final DateTime from;
  final DateTime to;
  final ReportOverview overview;
  final List<ReportMonthlyRevenue> monthlyRevenue;
  final List<ReportPaymentMethod> paymentMethods;

  const AdminReport({
    required this.from,
    required this.to,
    required this.overview,
    required this.monthlyRevenue,
    required this.paymentMethods,
  });

  factory AdminReport.fromJson(Map<String, dynamic> json) {
    return AdminReport(
      from: DateTime.tryParse(json['from']?.toString() ?? '') ?? DateTime.now(),
      to: DateTime.tryParse(json['to']?.toString() ?? '') ?? DateTime.now(),
      overview: ReportOverview.fromJson(
        json['overview'] as Map<String, dynamic>? ?? const {},
      ),
      monthlyRevenue: _items(json['monthlyRevenue'])
          .map(ReportMonthlyRevenue.fromJson)
          .toList(),
      paymentMethods: _items(json['paymentMethods'])
          .map(ReportPaymentMethod.fromJson)
          .toList(),
    );
  }

  static List<Map<String, dynamic>> _items(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }
}

class ReportOverview {
  final double totalRevenue;
  final int paymentCount;
  final int rentalOrderCount;
  final int usedDeviceCount;
  final int totalDeviceCount;
  final double utilizationRate;

  const ReportOverview({
    required this.totalRevenue,
    required this.paymentCount,
    required this.rentalOrderCount,
    required this.usedDeviceCount,
    required this.totalDeviceCount,
    required this.utilizationRate,
  });

  factory ReportOverview.fromJson(Map<String, dynamic> json) {
    return ReportOverview(
      totalRevenue: _toDouble(json['totalRevenue']),
      paymentCount: json['paymentCount'] as int? ?? 0,
      rentalOrderCount: json['rentalOrderCount'] as int? ?? 0,
      usedDeviceCount: json['usedDeviceCount'] as int? ?? 0,
      totalDeviceCount: json['totalDeviceCount'] as int? ?? 0,
      utilizationRate: _toDouble(json['utilizationRate']),
    );
  }
}

class ReportMonthlyRevenue {
  final int year;
  final int month;
  final double revenue;
  final int transactionCount;

  const ReportMonthlyRevenue({
    required this.year,
    required this.month,
    required this.revenue,
    required this.transactionCount,
  });

  factory ReportMonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return ReportMonthlyRevenue(
      year: json['year'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      revenue: _toDouble(json['revenue']),
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }
}

class ReportPaymentMethod {
  final String method;
  final double amount;
  final int count;

  const ReportPaymentMethod({
    required this.method,
    required this.amount,
    required this.count,
  });

  factory ReportPaymentMethod.fromJson(Map<String, dynamic> json) {
    return ReportPaymentMethod(
      method: json['method'] as String? ?? '',
      amount: _toDouble(json['amount']),
      count: json['count'] as int? ?? 0,
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
