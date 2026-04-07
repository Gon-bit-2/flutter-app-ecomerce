import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';

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
    final hasUnread = conversation.unreadCount > 0;

    return Material(
      color: hasUnread ? const Color(0xFFF0F7FF) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryBlue.withOpacity(0.06),
        highlightColor: AppColors.primaryBlue.withOpacity(0.03),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              // Avatar với online indicator
              _buildAvatar(),
              SizedBox(width: 14.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row: Name + Time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherUser.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                              color: const Color(0xFF212121),
                              fontSize: 15.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.lastMessage?.createdAt != null)
                          Text(
                            _formatTime(conversation.lastMessage!.createdAt!),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: hasUnread
                                  ? AppColors.primaryBlue
                                  : Colors.grey.shade400,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    // Row: Last message + Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage?.content ?? 'Bắt đầu trò chuyện',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: hasUnread
                                  ? const Color(0xFF424242)
                                  : Colors.grey.shade500,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          SizedBox(width: 8.w),
                          _buildUnreadBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───── Avatar với online dot ─────
  Widget _buildAvatar() {
    final avatar = conversation.otherUser.avatar;
    return Stack(
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26.r),
            child: avatar != null && avatar.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: avatar,
                    width: 52.w,
                    height: 52.w,
                    fit: BoxFit.cover,
                  )
                : _defaultAvatar(),
          ),
        ),
        // Online indicator
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    // Gradient avatar fallback
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF00A8E8), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          conversation.otherUser.name.isNotEmpty
              ? conversation.otherUser.name[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ───── Unread Badge dạng pill ─────
  Widget _buildUnreadBadge() {
    final count = conversation.unreadCount;
    final text = count > 99 ? '99+' : count.toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: text.length > 1 ? 8.w : 0,
      ),
      constraints: BoxConstraints(minWidth: 22.w, minHeight: 22.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF44336), Color(0xFFE53935)],
        ),
        borderRadius: BorderRadius.circular(11.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40F44336),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes}ph';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('dd/MM').format(dateTime);
  }
}
