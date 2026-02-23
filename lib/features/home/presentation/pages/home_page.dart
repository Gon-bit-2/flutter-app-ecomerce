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
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/login_page.dart';
import 'package:app_fe_ecomerce/features/profile/presentation/pages/profile_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Index 0: Home
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              const HomeAppBar(),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state is HomeError) {
                    return SliverFillRemaining(
                      child: Center(child: Text('Error: ${state.message}')),
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
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
          // Index 1: Mall
          const Center(child: Text("Tab Mall - Sắp ra mắt")),
          // Index 2: Live
          const Center(child: Text("Tab Live - Sắp ra mắt")),
          // Index 3: Notify
          const Center(child: Text("Tab Thông báo - Sắp ra mắt")),
          // Index 4: Me / Profile
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Determine if we have a user to display
              final user = (state is AuthSuccess)
                  ? state.user
                  : (state is AuthSetup2FASuccess)
                  ? state.user
                  : (state is AuthDisable2FASuccess)
                  ? state.user
                  : (state is AuthLoading)
                  ? state.user
                  : (state is AuthFailure)
                  ? state.user
                  : null;

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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Mall',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Tôi',
          ),
        ],
        selectedItemColor: const Color(0xFF1A94FF),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            "Chào mừng đến với E-Commerce",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            "Đăng nhập để quản lý tài khoản",
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
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
                backgroundColor: const Color(0xFF1A94FF),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: const Text("Đăng nhập / Đăng ký"),
            ),
          ),
        ],
      ),
    );
  }
}
