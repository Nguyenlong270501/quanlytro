import 'package:equatable/equatable.dart';

/// Thông tin chủ trọ hiển thị trong luồng duyệt bài đăng (đọc từ `users/{landlordId}`).
class LandlordSummary extends Equatable {
  const LandlordSummary({
    required this.userId,
    required this.displayName,
    required this.email,
    this.phoneNumber,
  });

  final String userId;
  final String displayName;
  final String email;
  final String? phoneNumber;

  LandlordSummary mergeWith(LandlordSummary fresh) {
    final mergedName = fresh.displayName.trim().isNotEmpty
        ? fresh.displayName.trim()
        : displayName;
    final mergedEmail =
        fresh.email.trim().isNotEmpty ? fresh.email.trim() : email;
    final freshPhone = fresh.phoneNumber?.trim();
    final mergedPhone =
        freshPhone != null && freshPhone.isNotEmpty ? freshPhone : phoneNumber;

    return LandlordSummary(
      userId: userId,
      displayName: mergedName,
      email: mergedEmail,
      phoneNumber: mergedPhone,
    );
  }

  @override
  List<Object?> get props => [userId, displayName, email, phoneNumber];
}
