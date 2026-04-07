import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/widgets/chat_input_widget.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/widgets/message_bubble_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:intl/intl.dart';

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
        ..add(
          ChatLoadMessages(
            conversationId: conversationId,
            receiverId: receiverId,
          ),
        )
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
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;
    if (_showScrollToBottom == isNearBottom) {
      setState(() => _showScrollToBottom = !isNearBottom);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
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
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          // Custom AppBar
          _buildAppBar(context),
          // Messages
          Expanded(
            child: Stack(
              children: [
                BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, state) {
                    if (state is MessagesLoaded) {
                      _scrollToBottom();
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatMessagesLoading) {
                      return _buildLoadingState();
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
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 8.w,
                        ),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isMe = message.senderId == currentUserId;

                          // Date separator
                          Widget? dateSeparator;
                          if (index == 0 ||
                              !_isSameDay(
                                state.messages[index].createdAt,
                                state.messages[index - 1].createdAt,
                              )) {
                            dateSeparator = _buildDateSeparator(
                              message.createdAt,
                            );
                          }

                          return Column(
                            children: [
                              if (dateSeparator != null) dateSeparator,
                              MessageBubbleWidget(message: message, isMe: isMe),
                            ],
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                // Scroll to bottom FAB
                if (_showScrollToBottom)
                  Positioned(
                    right: 16.w,
                    bottom: 8.h,
                    child: GestureDetector(
                      onTap: () => _scrollToBottom(),
                      child: Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primaryBlue,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Input
          ChatInputWidget(
            onSend: (content) {
              context.read<ChatBloc>().add(
                ChatSendMessage(
                  receiverId: widget.receiverId,
                  content: content,
                  currentUserId: currentUserId,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ───── Custom AppBar ─────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6.h,
        left: 8.w,
        right: 16.w,
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20.sp,
                color: const Color(0xFF212121),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Avatar
          _buildAvatar(),
          SizedBox(width: 12.w),
          // Name + Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF212121),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Đang hoạt động',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Call + More buttons
          _buildHeaderAction(Icons.phone_rounded),
          SizedBox(width: 8.w),
          _buildHeaderAction(Icons.more_vert_rounded),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20.sp, color: AppColors.primaryBlue),
    );
  }

  Widget _buildAvatar() {
    final avatar = widget.otherUserAvatar;
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21.r),
        child: avatar != null && avatar.isNotEmpty
            ? AppNetworkImage(
                imageUrl: avatar,
                width: 42.w,
                height: 42.w,
                fit: BoxFit.cover,
              )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 42.w,
      height: 42.w,
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
          widget.otherUserName.isNotEmpty
              ? widget.otherUserName[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ───── Date Separator ─────
  Widget _buildDateSeparator(DateTime? date) {
    if (date == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade200, height: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                _formatDateLabel(date),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade200, height: 1)),
        ],
      ),
    );
  }

  // ───── States ─────
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: Color(0xFF00A8E8),
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              size: 36.sp,
              color: AppColors.primaryBlue.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Bắt đầu trò chuyện!',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF424242),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Gửi tin nhắn đầu tiên để kết nối\nvới ${widget.otherUserName}',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
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
            size: 44.sp,
            color: AppColors.error.withOpacity(0.6),
          ),
          SizedBox(height: 12.h),
          Text(message, style: AppTextStyles.bodyMedium),
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  // ───── Helpers ─────
  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    if (diff < 7) return '$diff ngày trước';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
