import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/category/domain/usecases/create_category_usecase.dart';
import 'package:app_fe_ecomerce/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:app_fe_ecomerce/features/category/domain/usecases/get_category_id_usecase.dart';
import 'package:app_fe_ecomerce/features/category/domain/usecases/get_category_usecase.dart';
import 'package:app_fe_ecomerce/features/category/domain/usecases/update_category_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'category_event.dart';
part 'category_state.dart';

@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoryUseCase _getCategoryUseCase;
  final GetCategoryIdUseCase _getCategoryIdUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  CategoryBloc(
    this._getCategoryUseCase,
    this._getCategoryIdUseCase,
    this._createCategoryUseCase,
    this._updateCategoryUseCase,
    this._deleteCategoryUseCase,
  ) : super(CategoryInitial()) {
    // 1. Tải danh sách danh mục
    on<CategoryLoadRequested>((event, emit) async {
      emit(CategoryLoading());
      final result = await _getCategoryUseCase(
        GetCategoryParams(parentCategoryId: event.parentCategoryId),
      );
      result.fold(
        (failure) => emit(CategoryFailure(failure.message)),
        (categories) => emit(CategoryLoaded(categories)),
      );
    });

    // 2. Xem chi tiết 1 danh mục
    on<CategoryDetailRequested>((event, emit) async {
      emit(CategoryLoading());
      final result = await _getCategoryIdUseCase(
        GetCategoryIdParams(id: event.id),
      );
      result.fold(
        (failure) => emit(CategoryFailure(failure.message)),
        (category) => emit(CategoryDetailLoaded(category)),
      );
    });

    // 3. Tạo danh mục mới
    on<CategoryCreated>((event, emit) async {
      emit(CategoryLoading());
      final result = await _createCategoryUseCase(
        CreateCategoryParams(
          name: event.name,
          logo: event.logo,
          parentCategoryId: event.parentCategoryId,
        ),
      );
      result.fold((failure) => emit(CategoryFailure(failure.message)), (_) {
        emit(
          const CategoryOperationSuccess(message: 'Tạo danh mục thành công'),
        );
        add(CategoryLoadRequested(parentCategoryId: event.parentCategoryId));
      });
    });

    // 4. Cập nhật danh mục
    on<CategoryUpdated>((event, emit) async {
      emit(CategoryLoading());
      final result = await _updateCategoryUseCase(
        UpdateCategoryParams(
          id: event.id,
          name: event.name,
          logo: event.logo,
          parentCategoryId: event.parentCategoryId,
        ),
      );
      result.fold((failure) => emit(CategoryFailure(failure.message)), (_) {
        emit(
          const CategoryOperationSuccess(
            message: 'Cập nhật danh mục thành công',
          ),
        );
        add(const CategoryLoadRequested());
      });
    });

    // 5. Xóa danh mục
    on<CategoryDeleted>((event, emit) async {
      emit(CategoryLoading());
      final result = await _deleteCategoryUseCase(
        DeleteCategoryParams(id: event.id),
      );
      result.fold((failure) => emit(CategoryFailure(failure.message)), (_) {
        emit(
          const CategoryOperationSuccess(message: 'Xóa danh mục thành công'),
        );
        add(const CategoryLoadRequested());
      });
    });
  }
}
