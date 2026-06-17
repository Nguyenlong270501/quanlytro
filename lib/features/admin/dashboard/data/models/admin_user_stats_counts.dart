/// Kết quả aggregate Firestore cho khối thống kê người dùng (dashboard admin).
class AdminUserStatsCounts {
  const AdminUserStatsCounts({
    required this.totalUsers,
    required this.landlordUsers,
    required this.tenantUsers,
    required this.pendingLandlordRequests,
    required this.totalPosts,
    required this.pendingPosts,
    required this.approvedPosts,
    required this.rejectedPosts,
  });

  final int totalUsers;
  final int landlordUsers;
  final int tenantUsers;
  final int pendingLandlordRequests;
  final int totalPosts;
  final int pendingPosts;
  final int approvedPosts;
  final int rejectedPosts;

  AdminUserStatsCounts copyWith({
    int? totalUsers,
    int? landlordUsers,
    int? tenantUsers,
    int? pendingLandlordRequests,
    int? totalPosts,
    int? pendingPosts,
    int? approvedPosts,
    int? rejectedPosts,
  }) {
    return AdminUserStatsCounts(
      totalUsers: totalUsers ?? this.totalUsers,
      landlordUsers: landlordUsers ?? this.landlordUsers,
      tenantUsers: tenantUsers ?? this.tenantUsers,
      pendingLandlordRequests:
          pendingLandlordRequests ?? this.pendingLandlordRequests,
      totalPosts: totalPosts ?? this.totalPosts,
      pendingPosts: pendingPosts ?? this.pendingPosts,
      approvedPosts: approvedPosts ?? this.approvedPosts,
      rejectedPosts: rejectedPosts ?? this.rejectedPosts,
    );
  }
}
