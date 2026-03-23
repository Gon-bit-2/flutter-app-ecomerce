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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tin nhắn',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatFailure) {
            return _buildErrorState(context, state.message);
          }

          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return _buildEmptyState();
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatBloc>().add(ChatLoadConversations());
              },
              child: ListView.builder(
                itemCount: state.conversations.length,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80.sp,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'Chưa có tin nhắn',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Bắt đầu trò chuyện với người bán\nđể hỏi thêm về sản phẩm!',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Không thể tải tin nhắn',
            style: AppTextStyles.h3,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ChatBloc>().add(ChatLoadConversations());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
