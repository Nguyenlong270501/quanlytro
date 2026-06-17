import '../models/admin_user_stats_counts.dart';

abstract class AdminDashboardDataSource {
  Future<AdminUserStatsCounts> fetchUserStatsCounts();
}
