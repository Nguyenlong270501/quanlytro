import 'package:flutter/material.dart';

/// Dialog xác nhận hai nút (mặc định Hủy / Đồng ý). Dùng chung trong app.
abstract final class AppConfirmDialog {
  /// Trả về `true` khi nhấn nút xác nhận, `false` khi đóng hoặc nhấn hủy.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String cancelLabel = 'Hủy',
    String confirmLabel = 'Đồng ý',
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext, rootNavigator: true)
                  .pop(false),
              child: Text(cancelLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext, rootNavigator: true)
                  .pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result == true;
  }
}
