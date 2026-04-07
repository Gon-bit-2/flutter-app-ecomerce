import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/home/presentation/bloc/home_bloc.dart';
import 'package:app_fe_ecomerce/features/home/presentation/bloc/home_event.dart';
import 'package:app_fe_ecomerce/features/home/presentation/bloc/home_state.dart';
import 'package:app_fe_ecomerce/features/home/presentation/widgets/product_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:app_fe_ecomerce/features/home/presentation/pages/home_page.dart';

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<HomeBloc>()..add(HomeStarted()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hide back button
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          title: Text(
            'Thanh toán thành công',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Success Header section
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 80.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Đặt hàng thành công!',
                        style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Cảm ơn bạn đã mua sắm.\nĐơn hàng của bạn đang được xử lý.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const HomePage()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Tiếp tục mua sắm',
                            style: AppTextStyles.buttonText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title for Suggested Products
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
                  child: Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Có thể bạn sẽ thích',
                        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // Suggested Products Grid
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.h),
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryBlue),
                        ),
                      ),
                    );
                  }
                  
                  if (state is HomeLoaded && state.dailyDiscoverProducts.isNotEmpty) {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 16.w,
                        childCount: state.dailyDiscoverProducts.length > 8 
                          ? 8 : state.dailyDiscoverProducts.length, // Show up to 8 products
                        itemBuilder: (context, index) {
                          return ProductCard(product: state.dailyDiscoverProducts[index]);
                        },
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              
              // Bottom padding
              SliverToBoxAdapter(child: SizedBox(height: 32.h)),
            ],
          ),
        ),
      ),
    );
  }
}
