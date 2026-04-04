import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/notification/domain/entities/notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

enum AppNotificationType {
  orderSuccess,
  paymentSuccess,
  orderCancelled,
  promotion,
  system,
  other,
}

class NotificationItemWidget extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
  });

  AppNotificationType _parseType() {
    final t = notification.type.toUpperCase();
    final title = notification.title.toLowerCase();

    if (t == 'ORDER_SUCCESS' || title.contains('đặt hàng thành công')) {
      return AppNotificationType.orderSuccess;
    }
    if (t == 'PAYMENT_SUCCESS' || title.contains('thanh toán thành công') || t == 'PAYMENT') {
      return AppNotificationType.paymentSuccess;
    }
    if (t == 'ORDER_CANCELLED' || t == 'CANCELLED' || title.contains('hủy đơn') || title.contains('đã hủy')) {
      return AppNotificationType.orderCancelled;
    }
    if (t == 'PROMOTION') return AppNotificationType.promotion;
    if (t == 'SYSTEM') return AppNotificationType.system;
    
    // Fallback cho order nói chung nếu chưa map được
    if (t == 'ORDER') return AppNotificationType.orderSuccess;

    return AppNotificationType.other;
  }

  IconData _getIcon(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.orderSuccess:
        return Icons.check_circle_outline_rounded;
      case AppNotificationType.paymentSuccess:
        return Icons.account_balance_wallet_outlined;
      case AppNotificationType.orderCancelled:
        return Icons.cancel_outlined;
      case AppNotificationType.promotion:
        return Icons.local_offer_outlined;
      case AppNotificationType.system:
        return Icons.info_outline_rounded;
      case AppNotificationType.other:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getPrimaryColor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.orderSuccess:
        return AppColors.success;
      case AppNotificationType.paymentSuccess:
        return AppColors.primaryBlue; // Hoặc một màu nổi bật cho thanh toán
      case AppNotificationType.orderCancelled:
        return AppColors.error;
      case AppNotificationType.promotion:
        return AppColors.warning;
      case AppNotificationType.system:
        return AppColors.textSecondary;
      case AppNotificationType.other:
        return AppColors.primaryBlue;
    }
  }

  LinearGradient _getIconGradient(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.orderSuccess:
        return LinearGradient(
          colors: [AppColors.success.withOpacity(0.2), AppColors.success.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppNotificationType.paymentSuccess:
        return LinearGradient(
          colors: [AppColors.primaryBlue.withOpacity(0.2), AppColors.primaryBlue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppNotificationType.orderCancelled:
        return LinearGradient(
          colors: [AppColors.error.withOpacity(0.2), AppColors.error.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppNotificationType.promotion:
        return LinearGradient(
          colors: [AppColors.warning.withOpacity(0.2), AppColors.warning.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _parseType();
    final primaryColor = _getPrimaryColor(type);
    final timeAgo = notification.createdAt != null
        ? timeago.format(notification.createdAt!, locale: 'vi')
        : '';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: notification.isRead 
                  ? Colors.black.withOpacity(0.03)
                  : primaryColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: notification.isRead 
                ? AppColors.border.withOpacity(0.5)
                : primaryColor.withOpacity(0.3),
            width: notification.isRead ? 0.5 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Background
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: _getIconGradient(type),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                _getIcon(type),
                color: primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: notification.isRead 
                                ? AppColors.textPrimary.withOpacity(0.8)
                                : AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 10.w,
                          height: 10.w,
                          margin: EdgeInsets.only(left: 10.w, top: 4.h),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14.sp,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        timeAgo,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.8),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
