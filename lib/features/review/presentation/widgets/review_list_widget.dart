import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../injection_container.dart';
import '../bloc/review_list/review_list_bloc.dart';
import '../bloc/create_review/create_review_bloc.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'create_review_bottom_sheet.dart';

class ReviewListWidget extends StatefulWidget {
  final int productId;
  /// true nếu user đã mua sản phẩm này (có đơn hàng completed)
  final bool canReview;
  /// true nếu user đã đánh giá sản phẩm này rồi
  final bool hasReviewed;
  /// orderId liên quan (nếu có) để gửi review
  final int? orderId;

  const ReviewListWidget({
    super.key,
    required this.productId,
    this.canReview = false,
    this.hasReviewed = false,
    this.orderId,
  });

  @override
  State<ReviewListWidget> createState() => _ReviewListWidgetState();
}

class _ReviewListWidgetState extends State<ReviewListWidget> {
  late ReviewListBloc _reviewListBloc;

  @override
  void initState() {
    super.initState();
    _reviewListBloc = getIt<ReviewListBloc>()
      ..add(LoadProductReviewsEvent(productId: widget.productId, isRefresh: true));
  }

  @override
  void dispose() {
    _reviewListBloc.close();
    super.dispose();
  }

  void _showCreateReviewSheet() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (_) => getIt<CreateReviewBloc>(),
        child: CreateReviewBottomSheet(
          productId: widget.productId,
          orderId: widget.orderId,
          onReviewCreated: () {
            _reviewListBloc.add(LoadProductReviewsEvent(productId: widget.productId, isRefresh: true));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reviewListBloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Đánh giá sản phẩm",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              // Hiện nút đánh giá chỉ khi user đã mua & chưa đánh giá
              if (widget.hasReviewed)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 14.sp, color: Colors.green.shade700),
                      SizedBox(width: 4.w),
                      Text(
                        'Đã đánh giá',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (widget.canReview)
                TextButton(
                  onPressed: _showCreateReviewSheet,
                  child: Text(
                    "Viết đánh giá",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Nếu canReview=false và hasReviewed=false → không hiển thị gì
            ],
          ),
          BlocBuilder<ReviewListBloc, ReviewListState>(
            builder: (context, state) {
              if (state is ReviewListLoading && state.isFirstFetch) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ReviewListError) {
                return Center(
                  child: Text(
                    "Lỗi tải đánh giá: ${state.message}",
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                );
              } else if (state is ReviewListLoaded) {
                if (state.reviews.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: Text(
                        "Chưa có đánh giá nào. Hãy là người đầu tiên đánh giá!",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.reviews.length >= 3 ? 3 : state.reviews.length, // Preview max 3
                  separatorBuilder: (context, index) => Divider(color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final review = state.reviews[index];
                    return _buildReviewItem(review);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Nút xem tất cả nếu có nhiều hơn 3
          BlocBuilder<ReviewListBloc, ReviewListState>(
            builder: (context, state) {
              if (state is ReviewListLoaded && state.reviews.length > 3) {
                return Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to Full Review List Screen
                    },
                    child: Text(
                      "Xem tất cả (${state.reviews.length})",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }

  Widget _buildReviewItem(dynamic review) {
    // review is Review entity
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: Colors.grey[300],
                backgroundImage: review.userId != null 
                  ? const NetworkImage('https://i.pravatar.cc/100') // Placeholder for user avatar
                  : null,
                child: review.userId == null ? Icon(Icons.person, size: 20.sp, color: Colors.white) : null,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User ${review.userId}", // Replace with real username if available
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 14.sp,
                          color: index < review.rating ? Colors.amber : Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                review.createdAt != null 
                  ? DateFormat('dd/MM/yyyy').format(review.createdAt!) 
                  : DateFormat('dd/MM/yyyy').format(DateTime.now()),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            review.content ?? "",
            style: TextStyle(fontSize: 14.sp, height: 1.4),
          ),
          if (review.mediaUrls != null && review.mediaUrls!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            SizedBox(
              height: 70.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.mediaUrls!.length,
                separatorBuilder: (context, _) => SizedBox(width: 8.w),
                itemBuilder: (context, imgIndex) {
                  final media = review.mediaUrls![imgIndex];
                  final url = media.url;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      width: 70.h,
                      height: 70.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            )
          ]
        ],
      ),
    );
  }
}
