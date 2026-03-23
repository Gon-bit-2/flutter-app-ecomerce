import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ConversationItemWidget extends StatelessWidget {
  final ConversationEntity conversation;
  final VoidCallback onTap;

  const ConversationItemWidget({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            SizedBox(width: 12.w),
            // Tên + tin nhắn gần nhất
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUser.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessage?.createdAt != null)
                        Text(
                          _formatTime(conversation.lastMessage!.createdAt!),
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    conversation.lastMessage?.content ?? 'Bắt đầu trò chuyện',
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatar = conversation.otherUser.avatar;
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.r),
      child: avatar != null && avatar.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: avatar,
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
              placeholder: (context, url) => _defaultAvatar(),
              errorWidget: (context, url, error) => _defaultAvatar(),
            )
          : _defaultAvatar(),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          conversation.otherUser.name.isNotEmpty
              ? conversation.otherUser.name[0].toUpperCase()
              : '?',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} phút';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} giờ';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày';
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}
