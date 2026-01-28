import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/app_colors.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50.r),
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          color: Colors.white,
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor ?? AppColors.textPrimary,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}
