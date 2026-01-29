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
  _VariantInput({String? name, List<String>? options})
    : nameController = TextEditingController(text: name),
      options = options ?? [],
      optionInputController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController optionInputController;
  final List<String> options;

  void dispose() {
    nameController.dispose();
    optionInputController.dispose();
  }
}

class _SkuInputModel {
  String value;
  TextEditingController priceController;
  TextEditingController stockController;
  TextEditingController imageController;

  _SkuInputModel({
    required this.value,
    String? price,
    String? stock,
    String? image,
  }) : priceController = TextEditingController(text: price),
       stockController = TextEditingController(text: stock),
       imageController = TextEditingController(text: image);

  void dispose() {
    priceController.dispose();
    stockController.dispose();
    imageController.dispose();
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
  List<_SkuInputModel> _skuInputs = [];

  // Dropdown selections
  int? _selectedBrandId;
  int? _selectedCategoryId;

  // Image Upload
  final List<String> _uploadedImageUrls = [];
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
      _uploadedImageUrls.addAll(product.images);
    }

    if (product.variants != null && product.variants!.isNotEmpty) {
      _variantInputs.clear();
      for (var v in product.variants!) {
        if (v is Map && v['value'] != null && v['options'] is List) {
          final name = v['value'];
          final options = List<String>.from(v['options']);
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

    // Initial SKU generation to populate formatted list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSkuList(initial: true);
    });
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
    for (final sku in _skuInputs) {
      sku.dispose();
    }
    super.dispose();
  }

  List<List<String>> _buildOptionGroups() {
    return _variantInputs
        .map((variant) => variant.options)
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
          nextResults.add(prefix.isEmpty ? option : '$prefix, $option');
        }
      }
      results = nextResults;
    }
    return results;
  }

  // Renamed and moved logic to support updating state
  void _updateSkuList({bool initial = false}) {
    final optionGroups = _buildOptionGroups();
    final skuValues = _buildSkuValues(optionGroups);

    final List<_SkuInputModel> newSkus = [];

    // Existing product maps
    Map<String, Product> existingSkuMap = {};
    if (initial && widget.product != null) {
      // logic to map existing skus if needed,
      // but strictly we map by value string.
      for (var s in widget.product!.skus) {
        // "Red, S" -> SKU
        // s.value is the key
        // We need to pass data to controllers
      }
    }

    // Preservation map from current _skuInputs
    final Map<String, _SkuInputModel> currentMap = {
      for (var sku in _skuInputs) sku.value: sku,
    };

    for (var value in skuValues) {
      if (currentMap.containsKey(value)) {
        newSkus.add(currentMap[value]!); // Keep existing input
        currentMap.remove(value); // Taken
      } else {
        // Create new
        String? initPrice = _skuPriceController.text;
        String? initStock = _skuStockController.text;
        String? initImage = _skuImageController.text;

        // If initial load and editing, try to find match in widget.product.skus
        if (initial && widget.product != null) {
          final found = widget.product!.skus
              .where((element) => element.value == value)
              .firstOrNull;
          if (found != null) {
            initPrice = found.price.toInt().toString();
            initStock = found.stock.toString();
            initImage = found.image;
          }
        }

        newSkus.add(
          _SkuInputModel(
            value: value,
            price: initPrice,
            stock: initStock,
            image: initImage,
          ),
        );
      }
    }

    // Dispose removed ones
    for (var sku in currentMap.values) {
      sku.dispose();
    }

    setState(() {
      _skuInputs = newSkus;
    });
  }

  Future<void> _pickAndUploadImage() async {
    // Pick multiple images? Or single one by one. User asked for "upload multiple images at once" imply multi-pick?
    // ImagePicker supports pickMultiImage.
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _isUploadingImage = true;
      });

      // Upload each image
      for (var image in images) {
        final result = await GetIt.I<CommonRepository>().uploadFile(image);
        result.fold(
          (failure) {
            // Show error but continue? Or stop?
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Upload Failed for ${image.name}: ${failure.message}",
                ),
              ),
            );
          },
          (url) {
            setState(() => _uploadedImageUrls.add(url));
          },
        );
      }

      setState(() => _isUploadingImage = false);
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
      if (_uploadedImageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload at least one image")),
        );
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
          : _uploadedImageUrls.first;

      final variants = <Map<String, dynamic>>[];
      for (final variant in _variantInputs) {
        final name = variant.nameController.text.trim();
        final options = variant.options; // Use the list directly

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

      if (basePrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Base Price must be greater than 0")),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Ensure SKU price is valid
      int finalSkuPrice = skuPrice;
      if (finalSkuPrice <= 0) {
        finalSkuPrice = basePrice;
      }

      // Validate and build SKUs from input list
      final List<Map<String, dynamic>> finalSkus = [];
      for (var sku in _skuInputs) {
        final price = int.tryParse(sku.priceController.text) ?? basePrice;
        final stock = int.tryParse(sku.stockController.text) ?? 0;
        final image = sku.imageController.text.isNotEmpty
            ? sku.imageController.text
            : (_uploadedImageUrls.isNotEmpty ? _uploadedImageUrls.first : '');

        if (price <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Price for SKU ${sku.value} must be > 0")),
          );
          setState(() => _isLoading = false);
          return;
        }

        finalSkus.add({
          "value": sku.value,
          "price": price,
          "stock": stock,
          "image": image,
        });
      }

      // Create payload matching API
      final Map<String, dynamic> payload = {
        "name": _nameController.text,
        "basePrice": basePrice,
        "virtualPrice": virtualPrice,
        "brandId": _selectedBrandId,
        "images": _uploadedImageUrls,
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
        // Use generated SKUs
        "skus": finalSkus,
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
                    // --- Image List & Picker ---
                    SizedBox(
                      height: 120.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: Container(
                              width: 100.h,
                              height: 100.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: _isUploadingImage
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_a_photo,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "Add Images",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          ..._uploadedImageUrls.asMap().entries.map((entry) {
                            final index = entry.key;
                            final url = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(left: 12.w),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 100.h,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(url),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _uploadedImageUrls.removeAt(index);
                                        });
                                      },
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
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
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
                                  child: _buildTextField(
                                    "Variant Name (e.g. Color)",
                                    variant.nameController,
                                    isRequired: false,
                                  ),
                                ),
                                if (_variantInputs.length > 1)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _variantInputs
                                            .removeAt(index)
                                            .dispose();
                                        _updateSkuList();
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    "Add Option (e.g. Red)",
                                    variant.optionInputController,
                                    isRequired: false,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                ElevatedButton(
                                  onPressed: () {
                                    final text = variant
                                        .optionInputController
                                        .text
                                        .trim();
                                    if (text.isNotEmpty) {
                                      setState(() {
                                        if (!variant.options.contains(text)) {
                                          variant.options.add(text);
                                          _updateSkuList();
                                        }
                                        variant.optionInputController.clear();
                                      });
                                    }
                                  },
                                  child: const Text("Add"),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            if (variant.options.isNotEmpty)
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 4.h,
                                children: variant.options.map((option) {
                                  return Chip(
                                    label: Text(option),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 18,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        variant.options.remove(option);
                                        _updateSkuList();
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
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
                            // No need to update SKU list here as new variant has no options yet
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
                            "Default SKU Price (Bulk Apply)",
                            _skuPriceController,
                            isNumber: true,
                            isRequired: false,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed: () {
                            // Apply to all
                            for (var sku in _skuInputs) {
                              sku.priceController.text =
                                  _skuPriceController.text;
                            }
                            setState(() {});
                          },
                          child: const Text("Apply All"),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Default SKU Stock (Bulk Apply)",
                            _skuStockController,
                            isNumber: true,
                            isRequired: false,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed: () {
                            for (var sku in _skuInputs) {
                              sku.stockController.text =
                                  _skuStockController.text;
                            }
                            setState(() {});
                          },
                          child: const Text("Apply All"),
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
                    Text(
                      "SKU Configuration",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _skuInputs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final sku = _skuInputs[index];
                          return Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sku.value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        "Price",
                                        sku.priceController,
                                        isNumber: true,
                                        isRequired: true,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _buildTextField(
                                        "Stock",
                                        sku.stockController,
                                        isNumber: true,
                                        isRequired: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
