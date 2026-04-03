import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_shop_statistics.dart';
import 'shop_statistics_state.dart';

@injectable
class ShopStatisticsCubit extends Cubit<ShopStatisticsState> {
  final GetShopStatistics getShopStatistics;

  ShopStatisticsCubit(this.getShopStatistics) : super(ShopStatisticsInitial());

  Future<void> fetchStatistics() async {
    emit(ShopStatisticsLoading());
    final result = await getShopStatistics(NoParams());
    
    result.fold(
      (failure) => emit(ShopStatisticsError(message: failure.message)),
      (statistics) => emit(ShopStatisticsLoaded(statistics: statistics)),
    );
  }
}
