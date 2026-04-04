import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/banner_section.dart';
import '../widgets/category_section.dart';
import '../widgets/daily_discover_section.dart';
import '../widgets/flash_sale_section.dart';
import '../widgets/home_app_bar.dart';
import 'package:app_fe_ecomerce/core/common/widgets/shimmer_loading.dart';
import 'package:app_fe_ecomerce/features/auth/domain/entities/user_entity.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/login_page.dart';
import 'package:app_fe_ecomerce/features/profile/presentation/pages/profile_page.dart';
import 'package:app_fe_ecomerce/features/shop_video/presentation/pages/video_feed_page.dart'
    as app_fe_ecomerce_shop_video;
import 'package:app_fe_ecomerce/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:app_fe_ecomerce/features/notification/presentation/pages/notification_page.dart';
import 'package:app_fe_ecomerce/features/notification/domain/entities/notification_entity.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<HomeBloc>()..add(HomeStarted()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late ScrollController _scrollController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<HomeBloc>().add(HomeLoadMoreDailyDiscover());
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

  /// Helper: trích xuất user từ các AuthState khác nhau
  UserEntity? _getUserFromState(AuthState state) {
    if (state is AuthSuccess) return state.user;
    if (state is AuthSetup2FASuccess) return state.user;
    if (state is AuthDisable2FASuccess) return state.user;
    if (state is AuthLoading) return state.user;
    if (state is AuthFailure) return state.user;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              // Khi đăng nhập thành công, tự động chuyển người dùng về tab Trang chủ (0)
              // thay vì để họ ở lại tab Thông báo hoặc tab trống.
              if (_currentIndex != 0) {
                setState(() {
                  _currentIndex = 0;
                });
              }
            }
          },
        ),
        BlocListener<NotificationBloc, NotificationState>(
          listenWhen: (previous, current) {
            // Chỉ trigger khi có thông báo mới (id của thông báo đầu tiên thay đổi)
            // hoặc khi unreadCount tăng lên
            return current.notifications.isNotEmpty &&
                (previous.notifications.isEmpty ||
                    current.notifications.first.id != previous.notifications.first.id) &&
                current.unreadCount > previous.unreadCount;
          },
          listener: (context, state) {
            if (state.notifications.isNotEmpty) {
              _showInAppNotification(context, state.notifications.first);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Index 0: Home — với pull-to-refresh
            RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeRefreshed());
              },
              color: AppColors.primaryBlue,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  const HomeAppBar(),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading) {
                        return const SliverFillRemaining(
                          child: HomePageSkeleton(),
                        );
                      }
                      if (state is HomeError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Đã có lỗi xảy ra',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  style: AppTextStyles.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => context.read<HomeBloc>().add(
                                    HomeRefreshed(),
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Thử lại'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (state is HomeLoaded) {
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            BannerSection(banners: state.banners),
                            SizedBox(height: 10.h),
                            CategorySection(categories: state.categories),
                            SizedBox(height: 10.h),
                            FlashSaleSection(flashSale: state.flashSale),
                            SizedBox(height: 10.h),
                          ]),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                  const DailyDiscoverHeader(),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoaded) {
                        return DailyDiscoverSection(
                          products: state.dailyDiscoverProducts,
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoaded && state.hasMoreDailyDiscover) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                ],
              ),
            ),

            // Index 1: Video Feed
            const app_fe_ecomerce_shop_video.VideoFeedPage(),

            // Index 2: Thông báo
            const NotificationPage(),

            // Index 3: Tôi / Profile
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = _getUserFromState(state);

                if (user != null) {
                  final content = ProfilePage(user: user);
                  if (state is AuthLoading) {
                    return Stack(
                      children: [
                        content,
                        Container(
                          color: Colors.black.withOpacity(0.1),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }
                  return content;
                }

                // Fallback for loading without user
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _buildGuestProfile(context);
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, -1),
                blurRadius: 8,
              ),
            ],
          ),
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, notifState) {
              return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                backgroundColor: Colors.white,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Trang chủ',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.ondemand_video_outlined),
                    label: 'Video',
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: notifState.unreadCount > 0,
                      label: Text(
                        notifState.unreadCount > 99
                            ? '99+'
                            : '${notifState.unreadCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    label: 'Thông báo',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Tôi',
                  ),
                ],
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: AppColors.textSecondary,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F2F5), Colors.white],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar placeholder với viền gradient
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1565C0).withOpacity(0.3),
                  const Color(0xFF42A5F5).withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48.r,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 44.r,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Icon(
                  Icons.person_rounded,
                  size: 50.sp,
                  color: const Color(0xFF90CAF9),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          // Tiêu đề chào mừng
          Text(
            "Chào mừng bạn!",
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Đăng nhập để trải nghiệm mua sắm\nvà quản lý tài khoản dễ dàng",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 36.h),
          // Nút đăng nhập gradient
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Đăng nhập / Đăng ký",
                          style: AppTextStyles.buttonText.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Tính năng highlights
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGuestFeature(Icons.local_shipping_rounded, 'Giao nhanh'),
                _buildGuestFeature(Icons.verified_rounded, 'Uy tín'),
                _buildGuestFeature(Icons.support_agent_rounded, 'Hỗ trợ 24/7'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestFeature(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: const Color(0xFF1E88E5), size: 20.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showInAppNotification(BuildContext context, NotificationEntity notif) {
    // Determine icon and color based on content exactly like in NotificationItemWidget
    final t = notif.type.toUpperCase();
    final title = notif.title.toLowerCase();
    
    IconData icon = Icons.notifications_active_outlined;
    Color color = AppColors.primaryBlue;

    if (t == 'ORDER_SUCCESS' || title.contains('đặt hàng thành công') || t == 'ORDER') {
      icon = Icons.check_circle_outline_rounded;
      color = AppColors.success;
    } else if (t == 'PAYMENT_SUCCESS' || title.contains('thanh toán thành công') || t == 'PAYMENT') {
      icon = Icons.account_balance_wallet_outlined;
      color = AppColors.primaryBlue;
    } else if (t == 'ORDER_CANCELLED' || t == 'CANCELLED' || title.contains('hủy đơn') || title.contains('đã hủy')) {
      icon = Icons.cancel_outlined;
      color = AppColors.error;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notif.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'XEM',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _currentIndex = 2; // Navigate to notification tab
            });
          },
        ),
      ),
    );
  }
}

