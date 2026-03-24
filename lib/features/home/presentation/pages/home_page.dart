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
import 'package:app_fe_ecomerce/features/shop_video/presentation/pages/video_feed_page.dart' as app_fe_ecomerce_shop_video;

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
    return Scaffold(
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
                              Icon(Icons.cloud_off, size: 64, color: AppColors.textSecondary),
                              const SizedBox(height: 16),
                              Text(
                                'Đã có lỗi xảy ra',
                                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => context.read<HomeBloc>().add(HomeRefreshed()),
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

          // Index 2: Tôi / Profile
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
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.ondemand_video_outlined), label: 'Video'),
            BottomNavigationBarItem(
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
        ),
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 80.sp, color: AppColors.textSecondary),
          SizedBox(height: 16.h),
          Text(
            "Chào mừng đến với E-Commerce",
            style: AppTextStyles.h3,
          ),
          SizedBox(height: 8.h),
          Text(
            "Đăng nhập để quản lý tài khoản",
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 32.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text("Đăng nhập / Đăng ký", style: AppTextStyles.buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
