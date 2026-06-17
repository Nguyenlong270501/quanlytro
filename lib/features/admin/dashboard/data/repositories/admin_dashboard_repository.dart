import 'package:dartz/dartz.dart';

import '../models/admin_user_stats_counts.dart';

abstract class AdminDashboardRepository {
  Future<Either<String, AdminUserStatsCounts>> getUserStatsCounts();
}
