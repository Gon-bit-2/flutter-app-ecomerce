import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/product/domain/repositories/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../category/domain/repositories/category_repository.dart';
import '../../../../common/domain/repositories/common_repository.dart';
import '../../../domain/helpers/sku_generator.dart';

import 'add_product_event.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final CategoryRepository _categoryRepository;
  final CommonRepository _commonRepository;
  final ProductRepository _productRepository;

  int? _editingProductId;

  AddProductBloc({
    required CategoryRepository categoryRepository,
    required CommonRepository commonRepository,
    required ProductRepository productRepository,
  }) : _categoryRepository = categoryRepository,
       _commonRepository = commonRepository,
       _productRepository = productRepository,
       super(const AddProductState()) {
    on<AddProductStarted>(_onStarted);
    on<AddProductImagePicked>(_onImagePicked);
    on<AddProductImageRemoved>(_onImageRemoved);
    on<AddProductVariantAdded>(_onVariantAdded);
    on<AddProductVariantRemoved>(_onVariantRemoved);
    on<AddProductVariantNameChanged>(_onVariantNameChanged);
    on<AddProductVariantOptionAdded>(_onVariantOptionAdded);
    on<AddProductVariantOptionRemoved>(_onVariantOptionRemoved);
    on<AddProductSkuUpdated>(_onSkuUpdated);
    on<AddProductApplyDefaultSku>(_onApplyDefaultSku);
    on<AddProductSubmitted>(_onSubmitted);
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _onStarted(
    AddProductStarted event,
    Emitter<AddProductState> emit,
  ) async {
    emit(state.copyWith(status: AddProductStatus.loading));

    final categoryResult = await _categoryRepository.getCategories();

    List<CategoryEntity> categories = [];
    String? error;

    categoryResult.fold(
      (l) => error = "Lỗi lấy danh sách danh mục: ${l.message}",
      (r) => categories = r,
    );

    if (error != null) {
      emit(
        state.copyWith(status: AddProductStatus.failure, errorMessage: error),
      );
      return;
    }

    List<VariantInput> variants = [VariantInput(id: _generateId())];
    List<String> uploadedImages = [];
    List<SkuInput> skus = [];

    if (event.product != null) {
      _editingProductId = event.product!.id;
      uploadedImages = List.from(event.product!.images);

      if (event.product!.variants != null &&
          event.product!.variants!.isNotEmpty) {
        variants = [];
        for (var v in event.product!.variants!) {
          if (v is Map && v['value'] != null && v['options'] is List) {
            variants.add(
              VariantInput(
                id: _generateId(),
                name: v['value'],
                options: List<String>.from(v['options']),
              ),
            );
          }
        }
      }

      if (event.product!.skus.isNotEmpty) {
        skus = event.product!.skus
            .map(
              (s) => SkuInput(
                id: _generateId(),
                value: s.value,
                price: s.price,
                stock: s.stock,
                image: s.image,
              ),
            )
            .toList();
      } else {
        skus = await _generateSkus(variants, []);
      }
    } else {
      skus = await _generateSkus(variants, []);
    }

    emit(
      state.copyWith(
        status: AddProductStatus.initial,
        categories: categories,
        variants: variants,
        uploadedImageUrls: uploadedImages,
        skus: skus,
        isDataLoaded: true,
      ),
    );
  }

  Future<void> _onImagePicked(
    AddProductImagePicked event,
    Emitter<AddProductState> emit,
  ) async {
    emit(state.copyWith(isUploadingImage: true));
    final List<String> newUrls = List.from(state.uploadedImageUrls);

    for (var image in event.images) {
      final result = await _commonRepository.uploadFile(image);
      result.fold((l) {}, (url) => newUrls.add(url));
    }

    emit(state.copyWith(isUploadingImage: false, uploadedImageUrls: newUrls));
  }

  void _onImageRemoved(
    AddProductImageRemoved event,
    Emitter<AddProductState> emit,
  ) {
    if (event.index >= 0 && event.index < state.uploadedImageUrls.length) {
      final newUrls = List<String>.from(state.uploadedImageUrls);
      newUrls.removeAt(event.index);
      emit(state.copyWith(uploadedImageUrls: newUrls));
    }
  }

  void _onVariantAdded(
    AddProductVariantAdded event,
    Emitter<AddProductState> emit,
  ) {
    final newVariants = List<VariantInput>.from(state.variants)
      ..add(VariantInput(id: _generateId()));
    emit(state.copyWith(variants: newVariants));
  }

  Future<void> _onVariantRemoved(
    AddProductVariantRemoved event,
    Emitter<AddProductState> emit,
  ) async {
    if (event.index >= 0 && event.index < state.variants.length) {
      final newVariants = List<VariantInput>.from(state.variants)
        ..removeAt(event.index);
      final newSkus = await _generateSkus(newVariants, state.skus);
      emit(state.copyWith(variants: newVariants, skus: newSkus));
    }
  }

  void _onVariantNameChanged(
    AddProductVariantNameChanged event,
    Emitter<AddProductState> emit,
  ) {
    if (event.index >= 0 && event.index < state.variants.length) {
      final newVariants = List<VariantInput>.from(state.variants);
      newVariants[event.index] = newVariants[event.index].copyWith(
        name: event.name,
      );
      emit(state.copyWith(variants: newVariants));
    }
  }

  Future<void> _onVariantOptionAdded(
    AddProductVariantOptionAdded event,
    Emitter<AddProductState> emit,
  ) async {
    if (event.variantIndex >= 0 && event.variantIndex < state.variants.length) {
      final variant = state.variants[event.variantIndex];
      if (!variant.options.contains(event.option)) {
        final newOptions = List<String>.from(variant.options)
          ..add(event.option);
        final newVariants = List<VariantInput>.from(state.variants);
        newVariants[event.variantIndex] = variant.copyWith(options: newOptions);

        final newSkus = await _generateSkus(newVariants, state.skus);
        emit(state.copyWith(variants: newVariants, skus: newSkus));
      }
    }
  }

  Future<void> _onVariantOptionRemoved(
    AddProductVariantOptionRemoved event,
    Emitter<AddProductState> emit,
  ) async {
    if (event.variantIndex >= 0 && event.variantIndex < state.variants.length) {
      final variant = state.variants[event.variantIndex];
      if (variant.options.contains(event.option)) {
        final newOptions = List<String>.from(variant.options)
          ..remove(event.option);
        final newVariants = List<VariantInput>.from(state.variants);
        newVariants[event.variantIndex] = variant.copyWith(options: newOptions);

        final newSkus = await _generateSkus(newVariants, state.skus);
        emit(state.copyWith(variants: newVariants, skus: newSkus));
      }
    }
  }

  void _onSkuUpdated(
    AddProductSkuUpdated event,
    Emitter<AddProductState> emit,
  ) {
    if (event.index >= 0 && event.index < state.skus.length) {
      final newSkus = List<SkuInput>.from(state.skus);
      newSkus[event.index] = newSkus[event.index].copyWith(
        price: event.price,
        stock: event.stock,
        image: event.image,
      );
      emit(state.copyWith(skus: newSkus));
    }
  }

  void _onApplyDefaultSku(
    AddProductApplyDefaultSku event,
    Emitter<AddProductState> emit,
  ) {
    final newSkus = state.skus.map((sku) {
      return sku.copyWith(
        price: event.price ?? sku.price,
        stock: event.stock ?? sku.stock,
        image: event.image ?? sku.image,
      );
    }).toList();
    emit(state.copyWith(skus: newSkus));
  }

  Future<void> _onSubmitted(
    AddProductSubmitted event,
    Emitter<AddProductState> emit,
  ) async {
    if (state.uploadedImageUrls.isEmpty) {
      // Just emit failure for now, UI handles snackbar
      // Wait, failing status resets the form status?
      // We generally use a transient state or listen to specific error stream.
      // Or simply emit failure with a message.
      emit(
        state.copyWith(
          status: AddProductStatus.failure,
          errorMessage: "Vui lòng tải lên ít nhất 1 ảnh",
        ),
      );
      // Reset status to allow retry?
      // Actually better:
      // emit(state.copyWith(status: AddProductStatus.initial, errorMessage: null));
      return;
    }

    emit(state.copyWith(status: AddProductStatus.loading));

    final variantsPayload = <Map<String, dynamic>>[];
    for (var v in state.variants) {
      if (v.name.isNotEmpty && v.options.isNotEmpty) {
        variantsPayload.add({"value": v.name, "options": v.options});
      }
    }

    final skusPayload = state.skus
        .map(
          (s) => {
            "value": s.value,
            "price": s.price,
            "stock": s.stock,
            "image": s.image,
          },
        )
        .toList();

    final finalVariants = variantsPayload.isNotEmpty
        ? variantsPayload
        : [
            {
              "value": "Type",
              "options": ["Default"],
            },
          ];

    final Map<String, dynamic> payload = {
      "name": event.name,
      "description": event.description,
      "basePrice": event.basePrice,
      "virtualPrice": event.virtualPrice,
      "brandName": event.brandName,
      "images": state.uploadedImageUrls,
      "categories": event.categoryId != null ? [event.categoryId] : [],
      "publishedAt": DateTime.now().toUtc().toIso8601String(),
      "variants": finalVariants,
      "skus": skusPayload,
    };

    final result = _editingProductId == null
        ? await _productRepository.createProduct(payload)
        : await _productRepository.updateProduct(_editingProductId!, payload);

    result.fold(
      (l) => emit(
        state.copyWith(
          status: AddProductStatus.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(state.copyWith(status: AddProductStatus.success)),
    );
  }

  Future<List<SkuInput>> _generateSkus(
    List<VariantInput> variants,
    List<SkuInput> currentSkus,
  ) async {
    final optionGroups = variants
        .map((v) => v.options)
        .where((o) => o.isNotEmpty)
        .toList();

    // Sử dụng SkuGenerator để tính toán trên Background Isolate
    final skuValues = await SkuGenerator.generateAsync(optionGroups);

    final Map<String, SkuInput> currentMap = {
      for (var sku in currentSkus) sku.value: sku,
    };

    final List<SkuInput> newSkus = [];
    for (var value in skuValues) {
      if (currentMap.containsKey(value)) {
        newSkus.add(currentMap[value]!);
      } else {
        newSkus.add(
          SkuInput(
            id: _generateId(),
            value: value,
            price: 0,
            stock: 0,
            image: '',
          ),
        );
      }
    }
    return newSkus;
  }
}
