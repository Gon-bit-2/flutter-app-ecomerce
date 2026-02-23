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

    if (state.isDataLoaded) {
      // Only set text if empty (initial load) to avoid overwriting user edits if we used this listener deeply
      // But here we rely on isDataLoaded being irrelevant after init?
      // Actually isDataLoaded is true after first response.
      // We should perform one-time population.
      // But standard way: populate once in init if data available? No, data comes async.
      // So checking condition:
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
            // This simple check prevents re-writing if user cleared the name, but good enough for now
            if (state.categories.isNotEmpty) {
              // Just ensures we have some data loaded
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
              // Brand name would need to be fetched from the backend
              // For now we leave it empty for editing
              // Handle Category (Single hardcoded for now in UI logic, assuming complex mapping later)
              // But widget.product doesn't strictly have single category ID field in Entity unless we check categories list
              // Assuming first category for now if available
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: isRequired
          ? (v) => (v == null || v.isEmpty) ? "Vui lòng nhập $label" : null
          : null,
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Validations for Brand/Category/Images are handled in Bloc or simple Check
      // Dispatch event
      _bloc.add(
        AddProductSubmitted(
          name: _nameController.text,
          description: _descController.text,
          basePrice: double.tryParse(_basePriceController.text) ?? 0,
          virtualPrice: double.tryParse(_virtualPriceController.text) ?? 0,
          brandName: _brandController.text,
          categoryId: _selectedCategoryId,
        ),
      );
    }
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
