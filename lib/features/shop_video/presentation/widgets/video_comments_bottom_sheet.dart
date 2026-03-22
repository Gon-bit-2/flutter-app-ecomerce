import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

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
      builder: (context) => VideoCommentsBottomSheet(videoId: videoId),
    );
  }

  @override
  State<VideoCommentsBottomSheet> createState() => _VideoCommentsBottomSheetState();
}

class _VideoCommentsBottomSheetState extends State<VideoCommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _replyToCommentId;
  String? _replyToUsername;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
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
    setState(() {
      _replyToCommentId = null;
      _replyToUsername = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Provide new BLoC instance just for this bottom sheet lifecycle
    return BlocProvider<VideoCommentsBloc>(
      create: (context) => GetIt.I<VideoCommentsBloc>()
        ..add(LoadVideoCommentsEvent(widget.videoId, isRefresh: true)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 48.h,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'Bình luận',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8.w,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Comments List
            Expanded(
              child: BlocBuilder<VideoCommentsBloc, VideoCommentsState>(
                builder: (context, state) {
                  if (state is VideoCommentsLoading && state.isFirstFetch) {
                    return const Center(child: CircularProgressIndicator());
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
                    return const Center(child: Text('Chưa có bình luận nào.'));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: comments.length + (hasReachedMax ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index >= comments.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _buildCommentItem(context, comments[index]);
                    },
                  );
                },
              ),
            ),
            // Input Area
            Container(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 8.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_replyToUsername != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Text(
                            'Trả lời: $_replyToUsername',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _replyToCommentId = null;
                                _replyToUsername = null;
                              });
                            },
                            child: Icon(Icons.close, size: 16.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Thêm bình luận...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.r),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      BlocBuilder<VideoCommentsBloc, VideoCommentsState>(
                        builder: (context, state) {
                          return IconButton(
                            icon: Icon(
                              Icons.send_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: _submitComment,
                          );
                        },
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

  Widget _buildCommentItem(BuildContext context, ShopVideoComment comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 56.w : 16.w,
        right: 16.w,
        top: 12.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 12.r : 16.r,
            backgroundImage: NetworkImage(
              comment.user?.avatar ??
                  'https://ui-avatars.com/api/?name=${comment.user?.name ?? "U"}&background=random',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.user?.name ?? 'Người dùng',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  comment.content,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt),
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                    ),
                    SizedBox(width: 16.w),
                    if (!isReply)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _replyToCommentId = comment.id;
                            _replyToUsername = comment.user?.name ?? 'Người dùng';
                          });
                          FocusScope.of(context).requestFocus();
                        },
                        child: Text(
                          'Trả lời',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
                // Render replies
                if (comment.replies.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Column(
                      children: comment.replies
                          .map((reply) => _buildCommentItem(context, reply, isReply: true))
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
}
