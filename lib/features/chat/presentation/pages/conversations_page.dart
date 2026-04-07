import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/widgets/conversation_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ChatBloc>()
        ..add(ChatLoadConversations())
        ..add(ChatConnectSocket()),
      child: const _ConversationsView(),
    );
  }
}

class _ConversationsView extends StatelessWidget {
  const _ConversationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Custom gradient header
          _buildHeader(context),
          // Search bar
          _buildSearchBar(),
          // Conversations list
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return _buildLoadingState();
                }

                if (state is ChatFailure) {
                  return _buildErrorState(context, state.message);
                }

                if (state is ConversationsLoaded) {
                  if (state.conversations.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    color: AppColors.primaryBlue,
                    onRefresh: () async {
                      context.read<ChatBloc>().add(ChatLoadConversations());
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.only(top: 4.h),
                      itemCount: state.conversations.length,
                      separatorBuilder: (_, __) => Padding(
                        padding: EdgeInsets.only(left: 76.w),
                        child: Divider(height: 1, color: Colors.grey.shade100),
                      ),
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        return ConversationItemWidget(
                          conversation: conversation,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(
                                  conversationId: conversation.id,
                                  otherUserName: conversation.otherUser.name,
                                  otherUserAvatar: conversation.otherUser.avatar,
                                  receiverId: conversation.otherUser.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───── Gradient Header ─────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 16.w,
        right: 16.w,
        bottom: 16.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF00A8E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x302196F3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Tin nhắn',
              style: AppTextStyles.h2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Edit / New chat button
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit_note_rounded, color: Colors.white, size: 22.sp),
          ),
        ],
      ),
    );
  }

  // ───── Search Bar ─────
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20.sp),
          SizedBox(width: 10.w),
          Text(
            'Tìm kiếm cuộc trò chuyện...',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ───── Loading State ─────
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: 6,
      itemBuilder: (_, __) => _buildSkeletonItem(),
    );
  }

  Widget _buildSkeletonItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          // Avatar skeleton
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 180.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───── Empty State ─────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40.sp,
              color: AppColors.primaryBlue.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Chưa có tin nhắn',
            style: AppTextStyles.h3.copyWith(
              color: const Color(0xFF424242),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Bắt đầu trò chuyện với người bán\nđể hỏi thêm về sản phẩm!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ───── Error State ─────
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 32.sp,
                color: AppColors.error.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Không thể tải tin nhắn',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () {
                context.read<ChatBloc>().add(ChatLoadConversations());
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF00A8E8)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x302196F3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Thử lại',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
