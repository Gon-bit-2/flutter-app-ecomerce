import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object?> get props => [];
}

class AddProductStarted extends AddProductEvent {
  final Product? product;
  const AddProductStarted({this.product});

  @override
  List<Object?> get props => [product];
}

class AddProductImagePicked extends AddProductEvent {
  final List<XFile> images;
  const AddProductImagePicked(this.images);

  @override
  List<Object?> get props => [images];
}

class AddProductImageRemoved extends AddProductEvent {
  final int index;
  const AddProductImageRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class AddProductVariantAdded extends AddProductEvent {}

class AddProductVariantRemoved extends AddProductEvent {
  final int index;
  const AddProductVariantRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class AddProductVariantNameChanged extends AddProductEvent {
  final int index;
  final String name;
  const AddProductVariantNameChanged(this.index, this.name);

  @override
  List<Object?> get props => [index, name];
}

class AddProductVariantOptionAdded extends AddProductEvent {
  final int variantIndex;
  final String option;
  const AddProductVariantOptionAdded(this.variantIndex, this.option);

  @override
  List<Object?> get props => [variantIndex, option];
}

class AddProductVariantOptionRemoved extends AddProductEvent {
  final int variantIndex;
  final String option;
  const AddProductVariantOptionRemoved(this.variantIndex, this.option);

  @override
  List<Object?> get props => [variantIndex, option];
}

class AddProductSkuUpdated extends AddProductEvent {
  final int index;
  final double? price;
  final int? stock;
  final String? image;

  const AddProductSkuUpdated({
    required this.index,
    this.price,
    this.stock,
    this.image,
  });

  @override
  List<Object?> get props => [index, price, stock, image];
}

class AddProductApplyDefaultSku extends AddProductEvent {
  final double? price;
  final int? stock;
  final String? image;

  const AddProductApplyDefaultSku({this.price, this.stock, this.image});

  @override
  List<Object?> get props => [price, stock, image];
}

class AddProductSubmitted extends AddProductEvent {
  final String name;
  final String description;
  final double basePrice;
  final double virtualPrice;
  final String? brandName;
  final int? categoryId;

  const AddProductSubmitted({
    required this.name,
    required this.description,
    required this.basePrice,
    required this.virtualPrice,
    this.brandName,
    this.categoryId,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    basePrice,
    virtualPrice,
    brandName,
    categoryId,
  ];
}
