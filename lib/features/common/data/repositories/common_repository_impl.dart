import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/common_repository.dart';
import '../datasources/common_remote_datasource.dart';

@LazySingleton(as: CommonRepository)
class CommonRepositoryImpl implements CommonRepository {
  final CommonRemoteDataSource remoteDataSource;

  CommonRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> uploadFile(XFile file) async {
    try {
      final url = await remoteDataSource.uploadFile(file);
      return Right(url);
    } on DioException catch (e) {
      String errorMessage = e.message ?? "Upload Failed";
      if (e.response != null && e.response!.data != null) {
        errorMessage = e.response!.data.toString();
        // Try to extract strict message if common format
        if (e.response!.data is Map) {
          final map = e.response!.data as Map;
          if (map['message'] != null) {
            errorMessage = map['message'].toString();
          } else if (map['error'] != null)
            errorMessage = map['error'].toString();
        }
      }
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
