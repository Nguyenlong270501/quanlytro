import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_style.dart';

class AuthOauthSection extends StatelessWidget {
  const AuthOauthSection({
    super.key,
    this.onFacebookPressed,
    this.onGooglePressed,
    this.isEnabled = true,
  });

  final void Function()? onFacebookPressed;
  final void Function()? onGooglePressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isEnabled ? onGooglePressed : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/google.png',
                  height: AppSizes.iconSizeSmall,
                  width: AppSizes.iconSizeSmall,
                ),
                AppSizes.gapW8,
                Text(
                  'Google',
                  style: AppTypography.medium14(color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
        AppSizes.gapW16,
        Expanded(
          child: OutlinedButton(
            onPressed: isEnabled ? onFacebookPressed : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.facebook,
                  color: Colors.blue,
                  size: AppSizes.iconSizeSmall,
                ),
                AppSizes.gapW8,
                Text(
                  'Facebook',
                  style: AppTypography.medium14(color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
