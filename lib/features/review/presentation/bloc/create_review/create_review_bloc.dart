import 'dart:io';
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
    if (state.content.trim().isEmpty) {
      emit(state.copyWith(status: CreateReviewStatus.failure, errorMessage: 'Vui lòng nhập nội dung đánh giá'));
      return;
    }

    emit(state.copyWith(status: CreateReviewStatus.loading));

    try {
      List<Map<String, String>> uploadedMedias = [];
      
      // Upload từng ảnh/video từ path local
      for (String path in state.mediaPaths) {
        final File file = File(path);
        // Nhận diện kiểu dựa vào đuôi file. (Thực tế nên dùng mime or image_picker)
        final bool isVideo = path.toLowerCase().endsWith('.mp4') || path.toLowerCase().endsWith('.mov');
        
        // Gọi remoteDataSource upload
        final url = await remoteDataSource.uploadMedia(file);
        uploadedMedias.add({
          "url": url,
          "type": isVideo ? "VIDEO" : "IMAGE",
        });
      }

      final payload = {
        "content": state.content,
        "rating": state.rating,
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
    } catch (e) {
      emit(state.copyWith(status: CreateReviewStatus.failure, errorMessage: e.toString()));
    }
  }
}
