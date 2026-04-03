import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/login_page.dart';
import 'package:app_fe_ecomerce/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:app_fe_ecomerce/features/notification/presentation/widgets/notification_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial data if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        final notifState = context.read<NotificationBloc>().state;
        if (notifState.status == NotificationStatus.initial ||
            notifState.status == NotificationStatus.failure) {
          context.read<NotificationBloc>().add(NotificationRefreshed());
        }
      }
    });
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NotificationBloc>().add(NotificationLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Thông báo',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    context
                        .read<NotificationBloc>()
                        .add(NotificationMarkAllAsRead());
                  },
                  child: Text(
                    'Đọc tất cả',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthSuccess) {
            context.read<NotificationBloc>().add(NotificationRefreshed());
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess) {
              return _buildLoginRequiredView();
            }

            return BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state.status == NotificationStatus.loading || state.status == NotificationStatus.initial) {
                  return _buildLoadingSkeleton();
                }

                if (state.status == NotificationStatus.failure) {
                  final errorMsg = state.errorMessage ?? '';
                  return _buildErrorView(errorMsg.isNotEmpty ? errorMsg : 'Đã có lỗi xảy ra');
                }

                if (state.notifications.isEmpty) {
                  return _buildEmptyView();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<NotificationBloc>().add(NotificationRefreshed());
                  },
                  color: AppColors.primaryBlue,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.hasReachedMax
                        ? state.notifications.length
                        : state.notifications.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.notifications.length) {
                        return Padding(
                          padding: EdgeInsets.all(16.h),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        );
                      }

                      final notification = state.notifications[index];
                      return NotificationItemWidget(
                        notification: notification,
                        onTap: () {
                          // Đánh dấu đã đọc
                          if (!notification.isRead) {
                            context
                                .read<NotificationBloc>()
                                .add(NotificationMarkAsRead(
                                  notificationId: notification.id,
                                ));
                          }
                          // Navigate theo data.url nếu có
                          final url = notification.data?['url'] as String?;
                          if (url != null && url.isNotEmpty) {
                            Navigator.pushNamed(context, url);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 200.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 80.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80.sp,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          SizedBox(height: 16.h),
          Text(
            'Chưa có thông báo nào',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Thông báo mới sẽ hiển thị tại đây',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequiredView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 40.sp,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Đăng nhập để xem thông báo',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Hãy đăng nhập để không bỏ lỡ\ncác thông báo quan trọng từ đơn hàng\nvà khuyến mãi hấp dẫn!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Đăng nhập ngay',
                  style: AppTextStyles.buttonText.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64.sp, color: AppColors.textSecondary),
          SizedBox(height: 16.h),
          Text(
            'Đã có lỗi xảy ra',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<NotificationBloc>().add(NotificationRefreshed()),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
