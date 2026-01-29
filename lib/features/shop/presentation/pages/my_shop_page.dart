import 'package:app_fe_ecomerce/features/product/presentation/pages/add_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyShopPage extends StatelessWidget {
  const MyShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Shop"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShopHeader(),
            SizedBox(height: 24.h),
            _buildMenuGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShopHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        // Changed from Column to Row for better layout
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.blue.shade50,
            child: Icon(Icons.storefront, size: 30.r, color: Colors.blue),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Awesome Shop",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                "Active",
                style: TextStyle(fontSize: 14.sp, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menuItems = [
      {
        "icon": Icons.add_box_outlined,
        "title": "Add Product",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
        },
      },
      {
        "icon": Icons.inventory_2_outlined,
        "title": "My Products",
        "onTap": () {
          // TODO: Implement My Products List
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("My Products List")));
        },
      },
      {
        "icon": Icons.list_alt,
        "title": "Orders",
        "onTap": () {
          // TODO: Implement Orders
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Orders - Coming Soon")));
        },
      },
      {
        "icon": Icons.settings_outlined,
        "title": "Shop Settings",
        "onTap": () {
          // TODO: Implement Shop Settings
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Shop Settings - Coming Soon")),
          );
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.w,
        childAspectRatio: 1.2,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuCard(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          onTap: item['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32.sp, color: Colors.blue),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
