import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_daily_discover_usecase.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;
  final GetDailyDiscoverUseCase getDailyDiscoverUseCase;

  HomeBloc(this.getHomeDataUseCase, this.getDailyDiscoverUseCase)
    : super(HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeLoadMoreDailyDiscover>(_onLoadMore);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    // Fetch aggregated data
    final result = await getHomeDataUseCase(NoParams());

    await result.fold((failure) async => emit(HomeError(failure.message)), (
      data,
    ) async {
      // Initial daily discover fetch (Page 1)
      final dailyResult = await getDailyDiscoverUseCase(
        GetDailyDiscoverParams(page: 1),
      );

      dailyResult.fold(
        (failure) => emit(
          HomeError(failure.message),
        ), // Or Partial success? Use fallback
        (products) {
          emit(
            HomeLoaded(
              banners: data.banners,
              categories: data.categories,
              flashSale: data.flashSale,
              dailyDiscoverProducts: products,
              dailyDiscoverPage: 1,
              hasMoreDailyDiscover: products.length >= 10, // Assuming limit 10
            ),
          );
        },
      );
    });
  }

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    // Similar to Started but maybe keep old data while loading or just reload silently?
    // Usually pull-to-refresh shows spinner.
    // For simplicity, reuse logic.
    await _onStarted(HomeStarted(), emit);
  }

  Future<void> _onLoadMore(
    HomeLoadMoreDailyDiscover event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      if (!currentState.hasMoreDailyDiscover) return;

      final nextPage = currentState.dailyDiscoverPage + 1;
      final result = await getDailyDiscoverUseCase(
        GetDailyDiscoverParams(page: nextPage),
      );

      result.fold(
        (failure) {}, // Ignore error on infinite scroll or show toast
        (newProducts) {
          emit(
            currentState.copyWith(
              dailyDiscoverProducts:
                  currentState.dailyDiscoverProducts + newProducts,
              dailyDiscoverPage: nextPage,
              hasMoreDailyDiscover: newProducts.length >= 10,
            ),
          );
        },
      );
    }
  }
}
