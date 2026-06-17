import '../../features/admin/approvals/data/models/landlord_summary.dart';
import '../../features/landlord/create_property/data/models/landlord_summary_model.dart';

class PropertyApprovalsHelper {

  static String shortLandlordId(String id) {
    if (id.isEmpty) return '—';
    if (id.length <= 14) return id;
    return '${id.substring(0, 12)}…';
  }


  /// Ưu tiên snapshot nhúng trên property, sau đó `users/{id}`, cuối cùng rút gọn id.
  static String getLandlordDisplayName({
    required String landlordId,
    LandlordSummaryModel? embedded,
    LandlordSummary? summary,
  }) {
    if (embedded != null && embedded.userName.trim().isNotEmpty) {
      return embedded.userName.trim();
    }
    if (summary != null && summary.displayName.trim().isNotEmpty) {
      return summary.displayName.trim();
    }
    return shortLandlordId(landlordId);
  }
}