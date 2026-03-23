import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/message_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MessageBubbleWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) SizedBox(width: 40.w), // Space cho avatar nếu cần
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primaryBlue
                    : AppColors.inputBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                  bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatMessageTime(message.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.sp,
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 40.w), // Space bên phải
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }
}
