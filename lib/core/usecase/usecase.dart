import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';

// Type: Kiểu dữ liệu trả về thành công (Ví dụ: UserEntity)
// Params: Tham số truyền vào (Ví dụ: LoginParams)
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

// Dùng cho những UseCase không cần tham số (Ví dụ: GetProfile)
class NoParams {}
