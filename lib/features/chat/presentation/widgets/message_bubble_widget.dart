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
      padding: EdgeInsets.only(
        left: isMe ? 56.w : 4.w,
        right: isMe ? 4.w : 56.w,
        top: 3.h,
        bottom: 3.h,
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                // Gradient cho tin nhắn gửi, white cho tin nhận
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF00A8E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  // Tail shape giống iMessage
                  bottomLeft: isMe
                      ? Radius.circular(18.r)
                      : Radius.circular(4.r),
                  bottomRight: isMe
                      ? Radius.circular(4.r)
                      : Radius.circular(18.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? const Color(0x202196F3)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: isMe ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Nội dung
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      color: isMe ? Colors.white : const Color(0xFF212121),
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Thời gian + trạng thái gửi
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isMe
                              ? Colors.white.withOpacity(0.75)
                              : Colors.grey.shade400,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.done_all_rounded,
                          size: 14.sp,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }
}
