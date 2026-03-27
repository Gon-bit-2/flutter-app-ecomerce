import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/notification/domain/entities/notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationItemWidget extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return Icons.local_shipping_outlined;
      case 'PAYMENT':
        return Icons.payment_outlined;
      case 'PROMOTION':
        return Icons.local_offer_outlined;
      case 'SYSTEM':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return AppColors.primaryBlue;
      case 'PAYMENT':
        return AppColors.success;
      case 'PROMOTION':
        return AppColors.warning;
      case 'SYSTEM':
        return AppColors.textSecondary;
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColorForType(notification.type);
    final timeAgo = notification.createdAt != null
        ? timeago.format(notification.createdAt!, locale: 'vi')
        : '';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.primaryBlue.withOpacity(0.04),
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon tròn
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: iconColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          margin: EdgeInsets.only(left: 8.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    timeAgo,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
