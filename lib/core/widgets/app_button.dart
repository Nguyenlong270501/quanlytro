import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_style.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.h,
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: Container(
          height: 55.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: isEnabled
                  ? [Color(0xFFB7A7FF), Color(0xFFFFC58F)]
                  : [Colors.grey.shade300, Colors.grey.shade300],
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.h,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: AppTypography.medium16(color: Colors.black87),
                  ),
          ),
        ),
      ),
    );
  }
}
