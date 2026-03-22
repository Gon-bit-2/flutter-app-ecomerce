import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/get_shop_videos_use_case.dart';
import '../../../domain/usecases/create_shop_video_use_case.dart';
import '../../../domain/usecases/update_shop_video_use_case.dart';
import '../../../domain/usecases/delete_shop_video_use_case.dart';

import 'seller_video_event.dart';
import 'seller_video_state.dart';

@injectable
class SellerVideoBloc extends Bloc<SellerVideoEvent, SellerVideoState> {
  final GetShopVideosUseCase getShopVideosUseCase;
  final CreateShopVideoUseCase createShopVideoUseCase;
  final UpdateShopVideoUseCase updateShopVideoUseCase;
  final DeleteShopVideoUseCase deleteShopVideoUseCase;

  int _currentPage = 1;
  static const int _limit = 10;
  int _currentShopId = -1;

  SellerVideoBloc(
    this.getShopVideosUseCase,
    this.createShopVideoUseCase,
    this.updateShopVideoUseCase,
    this.deleteShopVideoUseCase,
  ) : super(SellerVideoInitial()) {
    on<LoadMyVideosEvent>(_onLoadMyVideos);
    on<LoadMoreMyVideosEvent>(_onLoadMoreMyVideos);
    on<CreateSellerVideoEvent>(_onCreateSellerVideo);
    on<UpdateSellerVideoEvent>(_onUpdateSellerVideo);
    on<DeleteSellerVideoEvent>(_onDeleteSellerVideo);
  }

  Future<void> _onLoadMyVideos(
    LoadMyVideosEvent event,
    Emitter<SellerVideoState> emit,
  ) async {
    _currentShopId = event.shopId;
    if (event.isRefresh) {
      _currentPage = 1;
    }

    emit(const SellerVideosLoading(isFirstFetch: true));

    final result = await getShopVideosUseCase.call(
      page: _currentPage,
      limit: _limit,
      shopId: _currentShopId,
    );

    result.fold(
      (failure) => emit(SellerVideoError(failure.message)),
      (videos) {
        bool hasReachedMax = videos.length < _limit;
        emit(SellerVideosLoaded(videos, hasReachedMax: hasReachedMax));
      },
    );
  }

  Future<void> _onLoadMoreMyVideos(
    LoadMoreMyVideosEvent event,
    Emitter<SellerVideoState> emit,
  ) async {
    if (state is SellerVideosLoaded) {
      final currentState = state as SellerVideosLoaded;
      if (currentState.hasReachedMax) return;

      emit(SellerVideosLoading(oldVideos: currentState.videos));
      _currentPage++;

      final result = await getShopVideosUseCase.call(
        page: _currentPage,
        limit: _limit,
        shopId: _currentShopId,
      );

      result.fold(
        (failure) {
           // Rollback
           emit(SellerVideoError(failure.message, oldVideos: currentState.videos));
           emit(SellerVideosLoaded(currentState.videos, hasReachedMax: currentState.hasReachedMax));
        },
        (videos) {
          bool hasReachedMax = videos.length < _limit;
          emit(SellerVideosLoaded(
            [...currentState.videos, ...videos],
            hasReachedMax: hasReachedMax,
          ));
        },
      );
    }
  }

  Future<void> _onCreateSellerVideo(
    CreateSellerVideoEvent event,
    Emitter<SellerVideoState> emit,
  ) async {
    emit(SellerVideoActionLoading());

    final result = await createShopVideoUseCase.call(
      video: event.video,
      caption: event.caption,
      thumbnailUrl: event.thumbnailUrl,
      productIds: event.productIds,
    );

    result.fold(
      (failure) => emit(SellerVideoError(failure.message)),
      (video) => emit(CreateSellerVideoSuccess(video)),
    );
  }

  Future<void> _onUpdateSellerVideo(
    UpdateSellerVideoEvent event,
    Emitter<SellerVideoState> emit,
  ) async {
    emit(SellerVideoActionLoading());

    final result = await updateShopVideoUseCase.call(event.id, event.data);

    result.fold(
      (failure) => emit(SellerVideoError(failure.message)),
      (video) => emit(UpdateSellerVideoSuccess(video)),
    );
  }

  Future<void> _onDeleteSellerVideo(
    DeleteSellerVideoEvent event,
    Emitter<SellerVideoState> emit,
  ) async {
    emit(SellerVideoActionLoading());

    final result = await deleteShopVideoUseCase.call(event.id);

    result.fold(
      (failure) => emit(SellerVideoError(failure.message)),
      (_) => emit(DeleteSellerVideoSuccess(event.id)),
    );
  }
}
