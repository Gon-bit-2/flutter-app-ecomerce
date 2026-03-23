import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/widgets/chat_input_widget.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/widgets/message_bubble_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

class ChatDetailPage extends StatelessWidget {
  final int conversationId;
  final String otherUserName;
  final String? otherUserAvatar;
  final int receiverId;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.receiverId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ChatBloc>()
        ..add(ChatLoadMessages(conversationId: conversationId))
        ..add(ChatConnectSocket()),
      child: _ChatDetailView(
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
        receiverId: receiverId,
      ),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  final String otherUserName;
  final String? otherUserAvatar;
  final int receiverId;

  const _ChatDetailView({
    required this.otherUserName,
    this.otherUserAvatar,
    required this.receiverId,
  });

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  int _getCurrentUserId(BuildContext context) {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        return authState.user.id;
      }
    } catch (_) {}
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _getCurrentUserId(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Danh sách tin nhắn
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatMessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatFailure) {
                  return _buildErrorState(context, state.message);
                }

                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return _buildEmptyMessages();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == currentUserId;
                      return MessageBubbleWidget(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          // Ô nhập tin nhắn
          ChatInputWidget(
            onSend: (content) {
              context.read<ChatBloc>().add(ChatSendMessage(
                    receiverId: widget.receiverId,
                    content: content,
                    currentUserId: currentUserId,
                  ));
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          // Avatar
          _buildAvatar(),
          SizedBox(width: 10.w),
          // Tên + trạng thái
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Đang hoạt động',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      elevation: 0,
    );
  }

  Widget _buildAvatar() {
    final avatar = widget.otherUserAvatar;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: avatar != null && avatar.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: avatar,
              width: 36.w,
              height: 36.w,
              fit: BoxFit.cover,
              placeholder: (context, url) => _defaultAvatar(),
              errorWidget: (context, url, error) => _defaultAvatar(),
            )
          : _defaultAvatar(),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.otherUserName.isNotEmpty
              ? widget.otherUserName[0].toUpperCase()
              : '?',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_outlined,
            size: 60.sp,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'Bắt đầu trò chuyện!',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Gửi tin nhắn đầu tiên để bắt đầu\ntrò chuyện với ${widget.otherUserName}',
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
          Icon(Icons.error_outline, size: 50.sp, color: AppColors.error),
          SizedBox(height: 12.h),
          Text(message, style: AppTextStyles.bodyMedium),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () {
              // Retry loading messages
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
