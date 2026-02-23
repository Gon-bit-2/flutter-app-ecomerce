import 'package:equatable/equatable.dart';
import '../../../../category/domain/entities/category.dart';

enum AddProductStatus { initial, loading, success, failure }

class VariantInput extends Equatable {
  final String id;
  final String name;
  final List<String> options;

  const VariantInput({this.id = '', this.name = '', this.options = const []});

  VariantInput copyWith({String? id, String? name, List<String>? options}) {
    return VariantInput(
      id: id ?? this.id,
      name: name ?? this.name,
      options: options ?? this.options,
    );
  }

  @override
  List<Object> get props => [id, name, options];
}

class SkuInput extends Equatable {
  final String id;
  final String value;
  final double price;
  final int stock;
  final String image;

  const SkuInput({
    this.id = '',
    required this.value,
    required this.price,
    required this.stock,
    required this.image,
  });

  SkuInput copyWith({
    String? id,
    String? value,
    double? price,
    int? stock,
    String? image,
  }) {
    return SkuInput(
      id: id ?? this.id,
      value: value ?? this.value,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      image: image ?? this.image,
    );
  }

  @override
  List<Object> get props => [id, value, price, stock, image];
}

class AddProductState extends Equatable {
  final AddProductStatus status;
  final String? errorMessage;
  final List<Category> categories;
  final List<String> uploadedImageUrls;
  final bool isUploadingImage;
  final List<VariantInput> variants;
  final List<SkuInput> skus;

  // We might want to track if data initialization is done
  final bool isDataLoaded;

  const AddProductState({
    this.status = AddProductStatus.initial,
    this.errorMessage,
    this.categories = const [],
    this.uploadedImageUrls = const [],
    this.isUploadingImage = false,
    this.variants = const [],
    this.skus = const [],
    this.isDataLoaded = false,
  });

  AddProductState copyWith({
    AddProductStatus? status,
    String? errorMessage,
    List<Category>? categories,
    List<String>? uploadedImageUrls,
    bool? isUploadingImage,
    List<VariantInput>? variants,
    List<SkuInput>? skus,
    bool? isDataLoaded,
  }) {
    return AddProductState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      uploadedImageUrls: uploadedImageUrls ?? this.uploadedImageUrls,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      variants: variants ?? this.variants,
      skus: skus ?? this.skus,
      isDataLoaded: isDataLoaded ?? this.isDataLoaded,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    categories,
    uploadedImageUrls,
    isUploadingImage,
    variants,
    skus,
    isDataLoaded,
  ];
}
