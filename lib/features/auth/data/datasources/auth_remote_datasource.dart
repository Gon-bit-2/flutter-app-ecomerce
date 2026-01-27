import 'package:injectable/injectable.dart';
import '../models/user_model.dart';

// Tạo interface trước (để dễ test giả lập sau này)
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // 1. Gọi API POST /auth/login
      final response = await _dioClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // 2. Phân tích kết quả trả về
      // Giả sử server trả về: { "user": { "id": 1, ... }, "accessToken": "..." }
      // Tùy vào cấu trúc JSON thực tế của API bên bạn mà sửa đoạn này nhé.
      // Dưới đây tôi giả định response.data chính là thông tin user hoặc chứa user.

      // LOGIC MẪU (Cần điều chỉnh theo API thực tế):
      // Nếu API trả về { "data": { ...user info... } }
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow; // Nếu lỗi thì ném ra cho Repository xử lý
    }
  }
}
