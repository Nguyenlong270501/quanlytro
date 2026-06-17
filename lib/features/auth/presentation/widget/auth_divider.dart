import 'package:flutter/material.dart';
import '../../../../core/theme/app_style.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider(color: Colors.black38)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'HOẶC TIẾP TỤC VỚI',
            style: AppTypography.medium14(color: const Color(0xFF6B7280)),
          ),
        ),
        Expanded(child: Divider(color: Colors.black38)),
      ],
    );
  }
}
