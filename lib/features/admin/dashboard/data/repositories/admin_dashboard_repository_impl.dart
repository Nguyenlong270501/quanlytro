import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../datasources/admin_dashboard_data_source.dart';
import '../models/admin_user_stats_counts.dart';
import 'admin_dashboard_repository.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  AdminDashboardRepositoryImpl(this._dataSource);

  final AdminDashboardDataSource _dataSource;

  @override
  Future<Either<String, AdminUserStatsCounts>> getUserStatsCounts() async {
    try {
      final counts = await _dataSource.fetchUserStatsCounts();
      return Right(counts);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Không thể tải thống kê người dùng.');
    }
  }

  String _mapFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Bạn không có quyền xem thống kê.';
      case 'unavailable':
        return 'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại.';
      case 'deadline-exceeded':
        return 'Hết thời gian chờ. Kiểm tra kết nối mạng.';
      default:
        return e.message ?? 'Không thể tải thống kê người dùng.';
    }
  }
}
