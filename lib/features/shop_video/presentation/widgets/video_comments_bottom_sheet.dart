import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui';

import '../bloc/video_comments/video_comments_bloc.dart';
import '../bloc/video_comments/video_comments_event.dart';
import '../bloc/video_comments/video_comments_state.dart';
import '../../domain/entities/shop_video_comment.dart';

class VideoCommentsBottomSheet extends StatefulWidget {
  final int videoId;

  const VideoCommentsBottomSheet({super.key, required this.videoId});

  static Future<void> show(BuildContext context, int videoId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider<VideoCommentsBloc>(
        create: (context) => GetIt.I<VideoCommentsBloc>()
          ..add(LoadVideoCommentsEvent(videoId, isRefresh: true)),
        child: VideoCommentsBottomSheet(videoId: videoId),
      ),
    );
  }

  @override
  State<VideoCommentsBottomSheet> createState() =>
      _VideoCommentsBottomSheetState();
}

class _VideoCommentsBottomSheetState extends State<VideoCommentsBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  int? _replyToCommentId;
  String? _replyToUsername;
  late AnimationController _replyBannerController;
  late Animation<Offset> _replySlideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _replyBannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _replySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _replyBannerController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _replyBannerController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<VideoCommentsBloc>().add(LoadMoreVideoCommentsEvent());
    }
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    context.read<VideoCommentsBloc>().add(AddVideoCommentEvent(
          content: text,
          parentId: _replyToCommentId,
        ));

    _commentController.clear();
    _cancelReply();
    _focusNode.unfocus();
  }

  void _setReply(int commentId, String username) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToUsername = username;
    });
    _replyBannerController.forward();
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    _replyBannerController.reverse();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _replyToCommentId = null;
          _replyToUsername = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Divider(height: 1, color: Colors.grey.shade200),
              Expanded(child: _buildCommentsList()),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // ───── Header với drag handle ─────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 10.h),
          // Title + close button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                BlocBuilder<VideoCommentsBloc, VideoCommentsState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is VideoCommentsLoaded) count = state.comments.length;
                    if (state is AddCommentSuccess) count = state.comments.length;
                    return Text(
                      count > 0 ? '$count bình luận' : 'Bình luận',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212121),
                        letterSpacing: 0.1,
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18.sp, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───── Danh sách comments ─────
  Widget _buildCommentsList() {
    return BlocBuilder<VideoCommentsBloc, VideoCommentsState>(
      builder: (context, state) {
        if (state is VideoCommentsLoading && state.isFirstFetch) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF00A8E8),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Đang tải bình luận...',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        List<ShopVideoComment> comments = [];
        bool hasReachedMax = false;

        if (state is VideoCommentsLoaded) {
          comments = state.comments;
          hasReachedMax = state.hasReachedMax;
        } else if (state is VideoCommentsLoading) {
          comments = state.oldComments;
        } else if (state is AddCommentSuccess) {
          comments = state.comments;
        } else if (state is VideoCommentsError) {
          comments = state.oldComments ?? [];
        }

        if (comments.isEmpty && state is! VideoCommentsLoading) {
          return _buildEmptyComments();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
          itemCount: comments.length + (hasReachedMax ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= comments.length) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Center(
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00A8E8),
                    ),
                  ),
                ),
              );
            }
            return _buildCommentItem(comments[index]);
          },
        );
      },
    );
  }

  // ───── Empty state đẹp ─────
  Widget _buildEmptyComments() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 56.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 12.h),
          Text(
            'Chưa có bình luận',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Hãy là người đầu tiên bình luận!',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ───── Comment item ─────
  Widget _buildCommentItem(ShopVideoComment comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 52.w : 16.w,
        right: 16.w,
        top: isReply ? 8.h : 14.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isReply
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF00A8E8), Color(0xFF2196F3)],
                    ),
              border: isReply ? Border.all(color: Colors.grey.shade200) : null,
            ),
            child: CircleAvatar(
              radius: isReply ? 12.r : 16.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: NetworkImage(
                comment.user?.avatar ??
                    'https://ui-avatars.com/api/?name=${comment.user?.name ?? "U"}&background=E3F2FD&color=2196F3',
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  comment.user?.name ?? 'Người dùng',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF212121),
                    letterSpacing: 0.1,
                  ),
                ),
                SizedBox(height: 3.h),
                // Nội dung comment
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF424242),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6.h),
                // Metadata row
                Row(
                  children: [
                    Text(
                      _formatRelativeTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!isReply) ...[
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () => _setReply(
                          comment.id,
                          comment.user?.name ?? 'Người dùng',
                        ),
                        child: Text(
                          'Trả lời',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2196F3),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Like mini button cho comment
                    GestureDetector(
                      onTap: () {
                        // Placeholder: like comment
                      },
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 16.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                // Replies
                if (comment.replies.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Column(
                      children: comment.replies
                          .map((reply) =>
                              _buildCommentItem(reply, isReply: true))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───── Input Area ─────
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 12.w,
        top: 10.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply Banner (animated)
          if (_replyToUsername != null)
            SlideTransition(
              position: _replySlideAnimation,
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded, size: 16.sp, color: const Color(0xFF2196F3)),
                    SizedBox(width: 6.w),
                    Text(
                      'Trả lời $_replyToUsername',
                      style: TextStyle(
                        color: const Color(0xFF2196F3),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(Icons.close_rounded, size: 16.sp, color: const Color(0xFF2196F3)),
                    ),
                  ],
                ),
              ),
            ),
          // Input Row
          Row(
            children: [
              // Input field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    children: [
                      // Emoji icon placeholder
                      Padding(
                        padding: EdgeInsets.only(left: 12.w),
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          size: 22.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Thêm bình luận...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 10.h,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF212121),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Send button với gradient
              GestureDetector(
                onTap: _submitComment,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00A8E8), Color(0xFF2196F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4000A8E8),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───── Relative time formatter ─────
  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} tuần trước';
    return '${(diff.inDays / 30).floor()} tháng trước';
  }
}
