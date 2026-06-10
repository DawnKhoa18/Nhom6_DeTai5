class AdminDashboard {
  final DashboardOverview overview;
  final List<DeviceStatusCount> deviceStatus;
  final List<MonthlyRevenue> monthlyRevenue;
  final List<DashboardReminder> upcomingOrders;
  final List<DashboardReminder> maintenanceReminders;

  const AdminDashboard({
    required this.overview,
    required this.deviceStatus,
    required this.monthlyRevenue,
    required this.upcomingOrders,
    required this.maintenanceReminders,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    final reminders = json['reminders'] as Map<String, dynamic>? ?? {};

    return AdminDashboard(
      overview: DashboardOverview.fromJson(
        json['overview'] as Map<String, dynamic>? ?? {},
      ),
      deviceStatus: _list(json['deviceStatus'])
          .map((item) => DeviceStatusCount.fromJson(item))
          .toList(),
      monthlyRevenue: _list(json['monthlyRevenue'])
          .map((item) => MonthlyRevenue.fromJson(item))
          .toList(),
      upcomingOrders: _list(reminders['upcomingOrders'])
          .map((item) => DashboardReminder.fromJson(item))
          .toList(),
      maintenanceReminders: _list(reminders['maintenanceReminders'])
          .map((item) => DashboardReminder.fromJson(item))
          .toList(),
    );
  }

  List<DashboardReminder> get reminders => [
        ...upcomingOrders,
        ...maintenanceReminders,
      ];

  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }
}

class DashboardOverview {
  final int totalDevices;
  final int availableDevices;
  final int rentedDevices;
  final int maintenanceDevices;
  final int brokenDevices;

  const DashboardOverview({
    required this.totalDevices,
    required this.availableDevices,
    required this.rentedDevices,
    required this.maintenanceDevices,
    required this.brokenDevices,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalDevices: json['totalDevices'] as int? ?? 0,
      availableDevices: json['availableDevices'] as int? ?? 0,
      rentedDevices: json['rentedDevices'] as int? ?? 0,
      maintenanceDevices: json['maintenanceDevices'] as int? ?? 0,
      brokenDevices: json['brokenDevices'] as int? ?? 0,
    );
  }
}

class DeviceStatusCount {
  final String status;
  final int count;

  const DeviceStatusCount({
    required this.status,
    required this.count,
  });

  factory DeviceStatusCount.fromJson(Map<String, dynamic> json) {
    return DeviceStatusCount(
      status: json['status'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class MonthlyRevenue {
  final int year;
  final int month;
  final double revenue;

  const MonthlyRevenue({
    required this.year,
    required this.month,
    required this.revenue,
  });

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      year: json['year'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      revenue: _toDouble(json['revenue']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class DashboardReminder {
  final String type;
  final String title;
  final String? deviceName;
  final String? status;
  final DateTime? dueDate;

  const DashboardReminder({
    required this.type,
    required this.title,
    required this.deviceName,
    required this.status,
    required this.dueDate,
  });

  factory DashboardReminder.fromJson(Map<String, dynamic> json) {
    return DashboardReminder(
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      deviceName: json['deviceName'] as String?,
      status: json['status'] as String?,
      dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? ''),
    );
  }
}
