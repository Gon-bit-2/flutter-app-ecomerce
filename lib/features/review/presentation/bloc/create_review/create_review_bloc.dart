import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/review.dart';
import '../../../domain/usecases/create_review_use_case.dart';
import '../../../data/datasources/review_remote_data_source.dart';

part 'create_review_event.dart';
part 'create_review_state.dart';

@injectable
class CreateReviewBloc extends Bloc<CreateReviewEvent, CreateReviewState> {
  final CreateReviewUseCase createReviewUseCase;
  final ReviewRemoteDataSource remoteDataSource;

  CreateReviewBloc(this.createReviewUseCase, this.remoteDataSource)
      : super(const CreateReviewState()) {
    on<FormContentChanged>(_onContentChanged);
    on<FormRatingChanged>(_onRatingChanged);
    on<FormMediasChanged>(_onMediasChanged);
    on<SubmitReviewEvent>(_onSubmit);
  }

  void _onContentChanged(FormContentChanged event, Emitter<CreateReviewState> emit) {
    emit(state.copyWith(content: event.content, status: CreateReviewStatus.initial));
  }

  void _onRatingChanged(FormRatingChanged event, Emitter<CreateReviewState> emit) {
    emit(state.copyWith(rating: event.rating, status: CreateReviewStatus.initial));
  }

  void _onMediasChanged(FormMediasChanged event, Emitter<CreateReviewState> emit) {
    emit(state.copyWith(mediaPaths: event.mediaPaths, status: CreateReviewStatus.initial));
  }

  Future<void> _onSubmit(SubmitReviewEvent event, Emitter<CreateReviewState> emit) async {
    // Sử dụng data trực tiếp từ event thay vì state để tránh race condition
    final content = event.content;
    final rating = event.rating;
    final mediaPaths = event.mediaPaths;

    if (content.trim().isEmpty) {
      emit(state.copyWith(status: CreateReviewStatus.failure, errorMessage: 'Vui lòng nhập nội dung đánh giá'));
      return;
    }

    emit(state.copyWith(status: CreateReviewStatus.loading));

    try {
      List<Map<String, String>> uploadedMedias = [];
      
      // Upload từng ảnh/video từ path local
      for (String path in mediaPaths) {
        final File file = File(path);
        final bool isVideo = path.toLowerCase().endsWith('.mp4') || path.toLowerCase().endsWith('.mov');
        final url = await remoteDataSource.uploadMedia(file);
        uploadedMedias.add({
          "url": url,
          "type": isVideo ? "VIDEO" : "IMAGE",
        });
      }

      final payload = {
        "content": content,
        "rating": rating,
        "productId": event.productId,
        "orderId": event.orderId,
        "userId": event.userId,
        "medias": uploadedMedias,
      };

      final result = await createReviewUseCase.call(payload);

      result.fold(
        (failure) => emit(state.copyWith(
          status: CreateReviewStatus.failure,
          errorMessage: failure.message,
        )),
        (review) => emit(state.copyWith(
          status: CreateReviewStatus.success,
          createdReview: review,
        )),
      );
    } on DioException catch (e) {
      // Xử lý lỗi Dio cụ thể (từ uploadMedia)
      final statusCode = e.response?.statusCode;
      String message;
      if (statusCode == 409) {
        message = 'Bạn đã đánh giá sản phẩm này rồi!';
      } else if (statusCode == 403) {
        message = 'Bạn cần mua sản phẩm này trước khi đánh giá.';
      } else {
        message = e.response?.data?['message'] ?? 'Lỗi kết nối, vui lòng thử lại.';
      }
      emit(state.copyWith(status: CreateReviewStatus.failure, errorMessage: message));
    } catch (e) {
      emit(state.copyWith(status: CreateReviewStatus.failure, errorMessage: 'Đã có lỗi xảy ra. Vui lòng thử lại.'));
    }
  }
}
