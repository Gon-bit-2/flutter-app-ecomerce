import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../../brand/domain/entities/brand.dart';
import '../../../brand/domain/repositories/brand_repository.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../common/domain/repositories/common_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;

  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _VariantInput {
  _VariantInput({String? name, String? options})
    : nameController = TextEditingController(text: name),
      optionsController = TextEditingController(text: options);

  final TextEditingController nameController;
  final TextEditingController optionsController;

  void dispose() {
    nameController.dispose();
    optionsController.dispose();
  }
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _virtualPriceController = TextEditingController();
  final _skuPriceController = TextEditingController();
  final _skuStockController = TextEditingController();
  final _skuImageController = TextEditingController();

  final List<_VariantInput> _variantInputs = [_VariantInput()];

  // Dropdown selections
  int? _selectedBrandId;
  int? _selectedCategoryId;

  // Image Upload
  String? _uploadedImageUrl;
  XFile? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _isFetchingData = true;

  // Data lists
  List<Brand> _brands = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    if (widget.product != null) {
      _initFormData();
    }
  }

  void _initFormData() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descController.text = product.description ?? '';
    _basePriceController.text = product.basePrice.toInt().toString();
    _virtualPriceController.text =
        product.virtualPrice?.toInt().toString() ?? '';
    _selectedBrandId = product.brandId;
    // Category mapping needs adjustments if product returns list of categories or IDs
    // For now assuming we might not have it or implement category logic if needed.
    // _selectedCategoryId = ...

    if (product.images.isNotEmpty) {
      _uploadedImageUrl = product.images.first;
    }

    if (product.variants != null && product.variants!.isNotEmpty) {
      _variantInputs.clear();
      for (var v in product.variants!) {
        if (v is Map && v['value'] != null && v['options'] is List) {
          final name = v['value'];
          final options = (v['options'] as List).join(', ');
          _variantInputs.add(_VariantInput(name: name, options: options));
        }
      }
    }

    // Initialize SKU defaults from first SKU if exists
    if (product.skus.isNotEmpty) {
      final firstSku = product.skus.first;
      _skuPriceController.text = firstSku.price.toInt().toString();
      _skuStockController.text = firstSku.stock.toString();
      _skuImageController.text = firstSku.image;
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isFetchingData = true);

    // Fetch Brands
    final brandResult = await GetIt.I<BrandRepository>().getBrands();
    // Fetch Categories
    final categoryResult = await GetIt.I<CategoryRepository>().getCategories();

    setState(() {
      _isFetchingData = false;
      brandResult.fold(
        (l) => debugPrint("Error fetching brands: ${l.message}"),
        (r) => _brands = r,
      );
      categoryResult.fold(
        (l) => debugPrint("Error fetching categories: ${l.message}"),
        (r) => _categories = r,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _basePriceController.dispose();
    _virtualPriceController.dispose();
    _skuPriceController.dispose();
    _skuStockController.dispose();
    _skuImageController.dispose();
    for (final variant in _variantInputs) {
      variant.dispose();
    }
    super.dispose();
  }

  List<List<String>> _buildOptionGroups() {
    return _variantInputs
        .map(
          (variant) => variant.optionsController.text
              .split(',')
              .map((option) => option.trim())
              .where((option) => option.isNotEmpty)
              .toList(),
        )
        .where((options) => options.isNotEmpty)
        .toList();
  }

  List<String> _buildSkuValues(List<List<String>> optionGroups) {
    if (optionGroups.isEmpty) {
      return ['Default'];
    }

    List<String> results = [''];
    for (final group in optionGroups) {
      final nextResults = <String>[];
      for (final prefix in results) {
        for (final option in group) {
          nextResults.add(prefix.isEmpty ? option : '$prefix - $option');
        }
      }
      results = nextResults;
    }
    return results;
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImageFile = image;
        _isUploadingImage = true;
      });

      final result = await GetIt.I<CommonRepository>().uploadFile(
        _pickedImageFile!,
      );

      setState(() => _isUploadingImage = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload Failed: ${failure.message}")),
          );
          setState(() => _pickedImageFile = null); // Reset on failure
        },
        (url) {
          setState(() => _uploadedImageUrl = url);
        },
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBrandId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please select a brand")));
        return;
      }
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a category")),
        );
        return;
      }
      if (_uploadedImageUrl == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please upload an image")));
        return;
      }

      setState(() => _isLoading = true);

      final basePrice = int.tryParse(_basePriceController.text) ?? 0;
      final virtualPrice = int.tryParse(_virtualPriceController.text) ?? 0;
      final skuImageInput = _skuImageController.text.trim();
      final skuPrice = int.tryParse(_skuPriceController.text) ?? basePrice;
      final skuStock = int.tryParse(_skuStockController.text) ?? 100;
      final skuImage = skuImageInput.isNotEmpty
          ? skuImageInput
          : _uploadedImageUrl;

      final variants = <Map<String, dynamic>>[];
      for (final variant in _variantInputs) {
        final name = variant.nameController.text.trim();
        final options = variant.optionsController.text
            .split(',')
            .map((option) => option.trim())
            .where((option) => option.isNotEmpty)
            .toList();

        if (name.isEmpty && options.isEmpty) {
          continue;
        }

        if (name.isEmpty || options.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Variant name và options phải nhập đầy đủ"),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        variants.add({"value": name, "options": options});
      }

      final optionGroups = _buildOptionGroups();
      final skuValues = _buildSkuValues(optionGroups);

      // Create payload matching API
      final Map<String, dynamic> payload = {
        "name": _nameController.text,
        "basePrice": basePrice,
        "virtualPrice": virtualPrice,
        "brandId": _selectedBrandId,
        "images": [_uploadedImageUrl],
        "categories": [_selectedCategoryId],
        "publishedAt": DateTime.now().toUtc().toIso8601String(),
        // Add required variants array
        "variants": variants.isNotEmpty
            ? variants
            : [
                {
                  "value": "Type",
                  "options": ["Default"],
                },
              ],
        // Generate SKUs from variant combinations
        "skus": skuValues
            .map(
              (value) => {
                "value": value,
                "price": skuPrice,
                "stock": skuStock,
                "image": skuImage,
              },
            )
            .toList(),
      };

      final productRepo = GetIt.I<ProductRepository>();
      final result = widget.product == null
          ? await productRepo.createProduct(payload)
          : await productRepo.updateProduct(widget.product!.id, payload);

      setState(() => _isLoading = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product == null
                    ? "Product Created Successfully!"
                    : "Product Updated Successfully!",
              ),
            ),
          );
          Navigator.pop(context, true); // Return true to signal refresh
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? "Add New Product" : "Edit Product",
        ),
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Image Picker Section ---
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        height: 200.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.r),
                          image: _uploadedImageUrl != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    _uploadedImageUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _isUploadingImage
                            ? const Center(child: CircularProgressIndicator())
                            : (_uploadedImageUrl == null)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8.h),
                                  const Text(
                                    "Tap to upload image",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    _buildTextField("Product Name", _nameController),
                    SizedBox(height: 12.h),

                    Text(
                      "Variants",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8.h),
                    ..._variantInputs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final variant = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                "Variant Name",
                                variant.nameController,
                                isRequired: false,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                "Options (comma-separated)",
                                variant.optionsController,
                                isRequired: false,
                              ),
                            ),
                            if (_variantInputs.length > 1) ...[
                              SizedBox(width: 8.w),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _variantInputs.removeAt(index).dispose();
                                  });
                                },
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _variantInputs.add(_VariantInput());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Variant"),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Default SKU Price (Optional)",
                            _skuPriceController,
                            isNumber: true,
                            isRequired: false,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTextField(
                            "Default SKU Stock (Optional)",
                            _skuStockController,
                            isNumber: true,
                            isRequired: false,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      "Default SKU Image URL (Optional)",
                      _skuImageController,
                      isRequired: false,
                    ),
                    SizedBox(height: 24.h),
                    _buildTextField(
                      "Description",
                      _descController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Base Price",
                            _basePriceController,
                            isNumber: true,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTextField(
                            "Original Price",
                            _virtualPriceController,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // --- Brand Dropdown ---
                    DropdownButtonFormField<int>(
                      initialValue: _selectedBrandId,
                      decoration: const InputDecoration(
                        labelText: "Brand",
                        border: OutlineInputBorder(),
                      ),
                      items: _brands
                          .map(
                            (brand) => DropdownMenuItem(
                              value: brand.id,
                              child: Text(brand.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedBrandId = val),
                      validator: (val) => val == null ? "Required" : null,
                    ),

                    SizedBox(height: 12.h),

                    // --- Category Dropdown ---
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategoryId = val),
                      validator: (val) => val == null ? "Required" : null,
                    ),

                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: (_isLoading || _isUploadingImage)
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text("Create Product"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return "$label is required";
        }
        return null;
      },
    );
  }
}
