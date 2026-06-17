import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../approvals/data/models/landlord_request.dart';
import '../../../../landlord/create_property/data/models/property_model.dart';
import '../models/admin_user_stats_counts.dart';
import 'admin_dashboard_data_source.dart';

class AdminDashboardDataSourceImpl implements AdminDashboardDataSource {
  AdminDashboardDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _landlordRequestsCollection = 'landlord_requests';
  static const String _propertiesCollection = 'properties';

  int _count(AggregateQuerySnapshot snapshot) => snapshot.count ?? 0;

  @override
  Future<AdminUserStatsCounts> fetchUserStatsCounts() async {
    final users = _firestore.collection(_usersCollection);
    final landlordRequests = _firestore.collection(_landlordRequestsCollection);
    final properties = _firestore.collection(_propertiesCollection);

    final snapshots = await Future.wait([
      users.count().get(),
      users
          .where('role', isEqualTo: UserRole.landlord.firestoreValue)
          .count()
          .get(),
      users
          .where('role', isEqualTo: UserRole.tenant.firestoreValue)
          .count()
          .get(),
      landlordRequests
          .where(
            'status',
            isEqualTo: LandlordRequestStatus.pending.firestoreValue,
          )
          .count()
          .get(),
      properties.count().get(),
      properties
          .where('status', isEqualTo: PropertyStatus.pending.name)
          .count()
          .get(),
      properties
          .where('status', isEqualTo: PropertyStatus.approved.name)
          .count()
          .get(),
      properties
          .where('status', isEqualTo: PropertyStatus.rejected.name)
          .count()
          .get(),
    ]);

    return AdminUserStatsCounts(
      totalUsers: _count(snapshots[0]),
      landlordUsers: _count(snapshots[1]),
      tenantUsers: _count(snapshots[2]),
      pendingLandlordRequests: _count(snapshots[3]),
      totalPosts: _count(snapshots[4]),
      pendingPosts: _count(snapshots[5]),
      approvedPosts: _count(snapshots[6]),
      rejectedPosts: _count(snapshots[7]),
    );
  }
}
