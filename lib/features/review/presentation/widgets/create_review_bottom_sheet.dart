import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/review/presentation/bloc/create_review/create_review_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class CreateReviewBottomSheet extends StatefulWidget {
  final int productId;
  final int? orderId;
  final String? productName;
  final String? productImage;
  final VoidCallback onReviewCreated;

  const CreateReviewBottomSheet({
    super.key,
    required this.productId,
    this.orderId,
    this.productName,
    this.productImage,
    required this.onReviewCreated,
  });

  @override
  State<CreateReviewBottomSheet> createState() =>
      _CreateReviewBottomSheetState();
}

class _CreateReviewBottomSheetState extends State<CreateReviewBottomSheet> {
  final _contentController = TextEditingController();
  int _rating = 5;
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  void _submitReview() {
    FocusScope.of(context).unfocus();
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập nội dung đánh giá!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần mua sản phẩm này trước khi đánh giá.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Lấy userId từ AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đánh giá.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<CreateReviewBloc>().add(
      SubmitReviewEvent(
        productId: widget.productId,
        orderId: widget.orderId!,
        userId: authState.user.id,
        content: content,
        rating: _rating,
        mediaPaths: _selectedImages.map((e) => e.path).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateReviewBloc, CreateReviewState>(
      listener: (listenerCtx, state) {
        if (state.status == CreateReviewStatus.success) {
          widget.onReviewCreated();
          // Dùng addPostFrameCallback để tránh lỗi khi pop trong build cycle
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(listenerCtx)) {
              Navigator.of(listenerCtx).pop();
            }
          });
          ScaffoldMessenger.of(listenerCtx).showSnackBar(
            const SnackBar(
              content: Text("Gửi đánh giá thành công! Cảm ơn bạn."),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == CreateReviewStatus.failure) {
          ScaffoldMessenger.of(listenerCtx).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? "Lỗi không xác định"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 16.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Viết đánh giá",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              // Thông tin sản phẩm đang đánh giá
              if (widget.productName != null || widget.productImage != null) ...[
                const Divider(),
                Row(
                  children: [
                    if (widget.productImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: AppNetworkImage(
                          imageUrl: widget.productImage!,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (widget.productImage != null) SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.productName ?? '',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Đơn hàng #${widget.orderId}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],

              SizedBox(height: 12.h),

              // Rating stars
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Chất lượng sản phẩm tuyệt vời?",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 16.h),

              // Nội dung đánh giá
              TextField(
                controller: _contentController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: "Hãy chia sẻ cảm nhận của bạn về sản phẩm nhé...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Chọn ảnh
              Text(
                "Đính kèm hình ảnh (Tối đa 5 ảnh)",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: 80.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    InkWell(
                      onTap: _selectedImages.length < 5 ? _pickImage : null,
                      child: Container(
                        width: 80.h,
                        height: 80.h,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.grey[600]),
                            SizedBox(height: 4.h),
                            Text(
                              "${_selectedImages.length}/5",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ...List.generate(_selectedImages.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: kIsWeb 
                                  ? AppNetworkImage(
                                      imageUrl: _selectedImages[index].path,
                                      width: 80.h,
                                      height: 80.h,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_selectedImages[index].path),
                                      width: 80.h,
                                      height: 80.h,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Nút Submit
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<CreateReviewBloc, CreateReviewState>(
                  builder: (context, state) {
                    bool isLoading = state.status == CreateReviewStatus.loading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Gửi đánh giá",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
