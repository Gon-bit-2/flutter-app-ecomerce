import 'package:app_fe_ecomerce/features/category/domain/repositories/category_repository.dart';
import 'package:app_fe_ecomerce/features/common/domain/repositories/common_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../bloc/add_product/add_product_bloc.dart';
import '../bloc/add_product/add_product_event.dart';
import '../bloc/add_product/add_product_state.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;

  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  late AddProductBloc _bloc;

  // Main Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _virtualPriceController = TextEditingController();
  final _brandController = TextEditingController();

  // Selected Values not in controllers
  int? _selectedCategoryId;

  // Bulk Apply Controllers
  final _skuDefaultPriceController = TextEditingController();
  final _skuDefaultStockController = TextEditingController();
  final _skuDefaultImageController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Use proper GetIt DI approach or default Provider. Since GetIt is used directly, inject the Bloc if it's registered
    // For now keeping manual instantiation but it's cleaner to inject AddProductBloc directly
    _bloc = AddProductBloc(
      categoryRepository: GetIt.I<CategoryRepository>(),
      commonRepository: GetIt.I<CommonRepository>(),
      productRepository: GetIt.I<ProductRepository>(),
    )..add(AddProductStarted(product: widget.product));
  }

  @override
  void dispose() {
    _bloc.close();
    _nameController.dispose();
    _descController.dispose();
    _basePriceController.dispose();
    _virtualPriceController.dispose();
    _brandController.dispose();
    _skuDefaultPriceController.dispose();
    _skuDefaultStockController.dispose();
    _skuDefaultImageController.dispose();
    super.dispose();
  }

  // Sync initial data from Bloc to Controllers
  void _onStateChanged(BuildContext context, AddProductState state) {
    if (state.status == AddProductStatus.failure &&
        state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }

    if (state.status == AddProductStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null ? "Tạo thành công" : "Cập nhật thành công",
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<AddProductBloc, AddProductState>(
        listener: (context, state) {
          _onStateChanged(context, state);
          // Data initialization hook
          if (state.isDataLoaded &&
              _nameController.text.isEmpty &&
              widget.product != null) {
            if (state.categories.isNotEmpty) {
              _nameController.text = widget.product!.name;
              _descController.text = widget.product!.description ?? '';
              _basePriceController.text = widget.product!.basePrice
                  .toInt()
                  .toString();
              if (widget.product!.virtualPrice != null) {
                _virtualPriceController.text = widget.product!.virtualPrice!
                    .toInt()
                    .toString();
              }
              // Brand name would need to be fetched from the backend or mapped
              // For now, if we don't have it on the Product entity, we can just leave it empty for user to edit or fetch
              // _brandController.text = ...

              // Handle Category (Single hardcoded for now in UI logic, assuming complex mapping later)
              // _selectedCategoryId = ...
            }
          }
        },
        builder: (context, state) {
          if (state.status == AddProductStatus.initial && !state.isDataLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.product == null ? "Thêm sản phẩm" : "Sửa sản phẩm",
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: state.status == AddProductStatus.loading
                      ? null
                      : _submit,
                ),
              ],
            ),
            body:
                state.status == AddProductStatus.loading && !state.isDataLoaded
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(state),
                          SizedBox(height: 24.h),
                          _buildTextField("Tên sản phẩm", _nameController),
                          SizedBox(height: 12.h),
                          _buildBrandCategorySelectors(state),
                          SizedBox(height: 12.h),
                          _buildTextField(
                            "Mô tả",
                            _descController,
                            maxLines: 3,
                            isRequired: false,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  "Giá cơ bản",
                                  _basePriceController,
                                  isNumber: true,
                                  isPrice: true,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildTextField(
                                  "Giá ảo (Gạch ngang)",
                                  _virtualPriceController,
                                  isNumber: true,
                                  isRequired: false,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          _buildVariantsSection(state),
                          SizedBox(height: 24.h),
                          _buildSkusSection(state),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(AddProductState state) {
    return SizedBox(
      height: 120.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () async {
              final images = await _picker.pickMultiImage();
              if (images.isNotEmpty && mounted) {
                _bloc.add(AddProductImagePicked(images));
              }
            },
            child: Container(
              width: 100.h,
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: state.isUploadingImage
                  ? const Center(child: CircularProgressIndicator())
                  : const Icon(Icons.add_a_photo, color: Colors.grey),
            ),
          ),
          ...state.uploadedImageUrls.asMap().entries.map((e) {
            return Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100.h,
                    height: 100.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(e.value),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: GestureDetector(
                      onTap: () => _bloc.add(AddProductImageRemoved(e.key)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
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
    );
  }

  Widget _buildBrandCategorySelectors(AddProductState state) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _brandController,
            decoration: InputDecoration(
              labelText: "Thương hiệu",
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: DropdownButtonFormField<int>(
            isDense: true,
            isExpanded: true,
            initialValue: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: "Danh mục",
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 12.h,
              ),
            ),
            items: state.categories
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      c.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedCategoryId = v),
            validator: (v) => v == null ? 'Bắt buộc' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildVariantsSection(AddProductState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Biến thể",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        ...state.variants.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _VariantItemWidget(
              index: entry.key,
              variant: entry.value,
              onRemove: () => _bloc.add(AddProductVariantRemoved(entry.key)),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () => _bloc.add(AddProductVariantAdded()),
          icon: const Icon(Icons.add),
          label: const Text("Thêm biến thể"),
        ),
      ],
    );
  }

  Widget _buildSkusSection(AddProductState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cấu hình SKU",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        // Bulk Apply
        Container(
          padding: EdgeInsets.all(12.w),
          color: Colors.grey[50],
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Giá chung",
                      _skuDefaultPriceController,
                      isNumber: true,
                      isRequired: false,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildTextField(
                      "Kho chung",
                      _skuDefaultStockController,
                      isNumber: true,
                      isRequired: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(
                    _skuDefaultPriceController.text,
                  );
                  final stock = int.tryParse(_skuDefaultStockController.text);
                  if (price != null || stock != null) {
                    _bloc.add(
                      AddProductApplyDefaultSku(price: price, stock: stock),
                    );
                  }
                },
                child: const Text("Áp dụng tất cả"),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.skus.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            return _SkuItemWidget(index: index, sku: state.skus[index]);
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isRequired = true,
    int maxLines = 1,
    bool isPrice = false,
    bool isStock = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (isRequired && (v == null || v.isEmpty)) {
          return "Vui lòng nhập $label";
        }
        if (isPrice && v != null && v.isNotEmpty) {
          final price = double.tryParse(v);
          if (price == null || price <= 0) {
            return "Giá phải lớn hơn 0";
          }
        }
        if (isStock && v != null && v.isNotEmpty) {
          final stock = int.tryParse(v);
          if (stock == null || stock < 0) {
            return "Số lượng tồn kho phải >= 0";
          }
        }
        return null;
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Validate ít nhất 1 ảnh
      if (_bloc.state.uploadedImageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng tải lên ít nhất 1 ảnh sản phẩm'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate giá cơ bản > 0
      final basePrice = double.tryParse(_basePriceController.text) ?? 0;
      if (basePrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giá cơ bản phải lớn hơn 0'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate SKUs: mỗi SKU phải có giá > 0
      final skus = _bloc.state.skus;
      if (skus.isNotEmpty) {
        final invalidSkus = skus.where((s) => s.price <= 0).toList();
        if (invalidSkus.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${invalidSkus.length} SKU chưa có giá hoặc giá <= 0. Vui lòng kiểm tra lại.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Hiện preview dialog trước khi submit
      _showPreviewDialog(basePrice);
    }
  }

  void _showPreviewDialog(double basePrice) {
    final state = _bloc.state;
    final virtualPrice = double.tryParse(_virtualPriceController.text);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Xem trước sản phẩm',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ảnh
              if (state.uploadedImageUrls.isNotEmpty)
                SizedBox(
                  height: 80.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.uploadedImageUrls.length,
                    itemBuilder: (_, i) => Container(
                      width: 80.h,
                      height: 80.h,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: NetworkImage(state.uploadedImageUrls[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 12.h),

              // Tên
              Text(
                _nameController.text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),

              // Giá
              Row(
                children: [
                  Text(
                    '${basePrice.toInt()} đ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (virtualPrice != null && virtualPrice > 0) ...[
                    SizedBox(width: 8.w),
                    Text(
                      '${virtualPrice.toInt()} đ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8.h),

              // Thương hiệu + Danh mục
              if (_brandController.text.isNotEmpty)
                Text('Thương hiệu: ${_brandController.text}',
                    style: TextStyle(fontSize: 13.sp)),

              // Mô tả
              if (_descController.text.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text('Mô tả:',
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.w600)),
                Text(_descController.text,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ],

              // Variants
              if (state.variants.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text('Biến thể:',
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ...state.variants.map((v) => Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text('  ${v.name}: ${v.options.join(", ")}',
                          style: TextStyle(fontSize: 12.sp)),
                    )),
              ],

              // SKUs summary
              if (state.skus.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text('SKU (${state.skus.length}):',
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ...state.skus.take(5).map((s) => Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                          '  ${s.value}: ${s.price.toInt()}đ / Kho: ${s.stock}',
                          style: TextStyle(fontSize: 12.sp)),
                    )),
                if (state.skus.length > 5)
                  Text('  ... và ${state.skus.length - 5} SKU khác',
                      style: TextStyle(
                          fontSize: 12.sp, fontStyle: FontStyle.italic)),
              ],

              // Ảnh count
              SizedBox(height: 8.h),
              Text('Ảnh: ${state.uploadedImageUrls.length} ảnh',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Chỉnh sửa'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performSubmit(basePrice);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text(
              widget.product == null ? 'Đăng sản phẩm' : 'Cập nhật',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _performSubmit(double basePrice) {
    _bloc.add(
      AddProductSubmitted(
        name: _nameController.text,
        description: _descController.text,
        basePrice: basePrice,
        virtualPrice: double.tryParse(_virtualPriceController.text) ?? 0,
        brandName: _brandController.text,
        categoryId: _selectedCategoryId,
      ),
    );
  }
}

class _VariantItemWidget extends StatefulWidget {
  final int index;
  final VariantInput variant;
  final VoidCallback onRemove;

  const _VariantItemWidget({
    required this.index,
    required this.variant,
    required this.onRemove,
  });

  @override
  State<_VariantItemWidget> createState() => _VariantItemWidgetState();
}

class _VariantItemWidgetState extends State<_VariantItemWidget> {
  late TextEditingController _nameController;
  final TextEditingController _optionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.variant.name);
  }

  @override
  void didUpdateWidget(covariant _VariantItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.variant.name != oldWidget.variant.name &&
        widget.variant.name != _nameController.text) {
      _nameController.text = widget.variant.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (focus) {
                    if (!focus) {
                      context.read<AddProductBloc>().add(
                        AddProductVariantNameChanged(
                          widget.index,
                          _nameController.text,
                        ),
                      );
                    }
                  },
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Tên biến thể (VD: Màu sắc)",
                    ),
                    onChanged: (v) {
                      // Optional: Update on every char or just on focus loss.
                      // For smoother UX, focus loss or debounce is better.
                      // Here relying on onFocusChange above.
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _optionController,
                  decoration: const InputDecoration(labelText: "Thêm tùy chọn"),
                  onSubmitted: (v) => _addOption(),
                ),
              ),
              SizedBox(width: 4.w),
              TextButton(onPressed: _addOption, child: const Text("Thêm")),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: widget.variant.options
                .map(
                  (opt) => Chip(
                    label: Text(opt),
                    onDeleted: () => context.read<AddProductBloc>().add(
                      AddProductVariantOptionRemoved(widget.index, opt),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _addOption() {
    if (_optionController.text.isNotEmpty) {
      context.read<AddProductBloc>().add(
        AddProductVariantOptionAdded(widget.index, _optionController.text),
      );
      _optionController.clear();
    }
  }
}

class _SkuItemWidget extends StatefulWidget {
  final int index;
  final SkuInput sku;

  const _SkuItemWidget({required this.index, required this.sku});

  @override
  State<_SkuItemWidget> createState() => _SkuItemWidgetState();
}

class _SkuItemWidgetState extends State<_SkuItemWidget> {
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.sku.price > 0 ? widget.sku.price.toInt().toString() : '',
    );
    _stockController = TextEditingController(
      text: widget.sku.stock > 0 ? widget.sku.stock.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant _SkuItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if value changed externally
    if (widget.sku.price != oldWidget.sku.price &&
        _priceController.text != widget.sku.price.toInt().toString()) {
      _priceController.text = widget.sku.price > 0
          ? widget.sku.price.toInt().toString()
          : '';
    }
    if (widget.sku.stock != oldWidget.sku.stock &&
        _stockController.text != widget.sku.stock.toString()) {
      _stockController.text = widget.sku.stock > 0
          ? widget.sku.stock.toString()
          : '';
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _updateSku() {
    final price = double.tryParse(_priceController.text);
    final stock = int.tryParse(_stockController.text);
    context.read<AddProductBloc>().add(
      AddProductSkuUpdated(index: widget.index, price: price, stock: stock),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.sku.value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (f) {
                    if (!f) _updateSku();
                  },
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Giá"),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Focus(
                  onFocusChange: (f) {
                    if (!f) _updateSku();
                  },
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Kho"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
