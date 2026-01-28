# Hướng Dẫn Chi Tiết Module Auth & Luồng Dữ Liệu (Flow)

Tài liệu này giải thích chi tiết kiến trúc, các thư viện được sử dụng và luồng dữ liệu (flow) trong tính năng Authentication (Đăng nhập/Đăng ký) của dự án.

## 1. Kiến Trúc Tổng Quan (Clean Architecture)

Dự án áp dụng **Clean Architecture** để chia tách code thành 3 tầng độc lập, giúp code dễ bảo trì, test và mở rộng.

- **Presentation Layer (`lib/features/auth/presentation`)**:
  - Chứa UI (Pages, Widgets) và State Management (Bloc/Cubit).
  - Nhiệm vụ: Hiển thị giao diện và nhận tương tác từ User. Không chứa logic gọi API hay lưu database trực tiếp.

- **Domain Layer (`lib/features/auth/domain`)**:
  - Chứa Entities (Object dữ liệu thuần túy) và Repository Interfaces (Các bản thiết kế/hợp đồng).
  - Nhiệm vụ: Định nghĩa "Cái gì cần làm" (ví dụ: cần hàm login, logout) mà không quan tâm "Làm như thế nào" (không quan tâm gọi API bằng Dio hay http).
  - Đây là lớp **độc lập nhất**, không phụ thuộc vào các thư viện bên ngoài (như Dio, Flutter Widgets).

- **Data Layer (`lib/features/auth/data`)**:
  - Chứa Models (Mapping dữ liệu JSON), Datasources (Nguồn dữ liệu) và Repository Implementations.
  - Nhiệm vụ: Thực hiện chi tiết "Làm như thế nào". Gọi API thật, lưu xuống máy thật.

---

## 2. Giải Thích Các Thư Viện (Packages) Chính

### a. `dio` & `AuthInterceptor` (Network)

- **Dio**: Là thư viện HTTP Client mạnh mẽ thay thế cho `http` mặc định.
- **Interceptor**: Hãy tưởng tượng nó như một cái trạm kiểm soát (Toll booth). Mọi request đi ra khỏi App đều phải qua trạm này.
  - **Tác dụng**: Thay vì mỗi màn hình gọi API ta đều phải code dòng `headers: {'Authorization': 'Bearer ...'}`, ta chỉ cấu hình 1 lần trong `AuthInterceptor`. Nó sẽ tự động móc Token từ bộ nhớ và gắn vào Header cho **mọi** request.

### b. `flutter_secure_storage` (Lưu trữ bảo mật)

- Khác với `shared_preferences` (chỉ lưu dạng text plain, dễ bị hack/đọc trộm trên root device), `secure_secure_storage` lưu dữ liệu vào **Keystore** (Android) hoặc **Keychain** (iOS). Đây là nơi an toàn nhất trên điện thoại để lưu các thông tin nhạy cảm như **Access Token** & **Refresh Token**.

### c. `injectable` & `get_it` (Dependency Injection - DI)

- **Vấn đề**: Bình thường bạn sẽ code `var repo = AuthRepositoryImpl();`. Nếu `Impl` thay đổi constructor, bạn phải sửa code ở 100 chỗ.
- **Giải pháp**: Bạn chỉ cần khai báo: "Tôi cần `AuthRepository`, hãy đưa cho tôi". `get_it` sẽ tự tìm class `Impl` tương ứng, tự khởi tạo (new) nó và đưa cho bạn.
- `@injectable`, `@LazySingleton`: Là các đánh dấu (annotation) để tool tự động sinh code khởi tạo.

### d. `fpdart` (Error Handling)

- Sử dụng kiểu dữ liệu `Either<L, R>`.
  - **Left (Trái)**: Chứa lỗi (Failure).
  - **Right (Phải)**: Chứa dữ liệu thành công (Success).
- **Lợi ích**: Giúp bạn bắt buộc phải xử lý cả 2 trường hợp (Thành công/Thất bại) khi nhận kết quả, tránh việc quên `try-catch` khiến App bị Crash.

---

## 3. Luồng Dữ Liệu Chi Tiết (Flow) - Ví Dụ: LOGIN

Hãy đi theo hành trình của một nút bấm "Đăng Nhập":

### 1. Presentation Layer (UI & Bloc)

- **User**: Nhập Email/Pass và nhấn Login.
- **LoginPage**: Gửi sự kiện `AuthLoginEvent(email, pass)` vào `AuthBloc`.
- **AuthBloc**:
  - Chuyển trạng thái sang `Loading` (UI hiện vòng quay).
  - Gọi hàm `login` từ `AuthRepository`.

### 2. Domain Layer -> Data Layer

- **AuthRepository**: Nhận lệnh login. Nó tham chiếu đến `AuthRepositoryImpl` ở Data Layer.

### 3. Data Layer (Repository Impl) - Nơi xử lý logic chính

File `auth_repository_impl.dart` thực hiện chuỗi hành động sau:

1.  **Gọi API**: Sử dụng `AuthRemoteDataSource.login(email, pass)`.
    - `AuthRemoteDataSource` dùng `Dio` bắn request lên Server (`POST /auth/login`).
    - Nhận về JSON, parse thành `TokenModel` (chứa accessToken, refreshToken).
2.  **Lưu Cache**: Gọi `AuthLocalDataSource.saveTokens(...)`.
    - Lưu 2 token này vào bộ nhớ bảo mật (`SecureStorage`).
3.  **Lấy User Profile**:
    - Bây giờ đã có Token, gọi tiếp `AuthRemoteDataSource.getProfile()`.
    - Lúc này `Dio` đi qua `AuthInterceptor`. Interceptor thấy có Token trong Storage -> Gắn vào Header -> API /profile thành công.
4.  **Trả kết quả**:
    - Nếu mọi thứ trơn tru -> Trả về `Right(UserEntity)`.
    - Nếu lỗi (Sai pass, mất mạng) -> Trả về `Left(ServerFailure)`.

### 4. Quay về Presentation

- **AuthBloc**: Nhận kết quả `Either<Failure, User>`.
  - Nếu `Right`: Emit state `Authenticated`. UI chuyển sang Trang Chủ.
  - Nếu `Left`: Emit state `AuthError`. UI hiện thông báo lỗi đỏ.

---

## 4. Giải Thích Code Các File Quan Trọng

### `auth_remote_datasource.dart`

- Đây là "cầu nối" trực tiếp với Backend.
- Chỉ chứa các hàm gọi API thuần túy: `login`, `register`, `refreshToken`...
- Input: Dữ liệu thô (String email, String pass).
- Output: Models (Dữ liệu dạng Object mapping từ JSON).

### `auth_local_datasource.dart`

- Đây là "cái két sắt" của App.
- Chuyên quản lý việc Đọc/Ghi/Xóa Token.
- Sử dụng `flutter_secure_storage` bên dưới.

### `auth_repository_impl.dart` (Quan trọng nhất)

- Đây được ví như "Trưởng phòng".
- Nó điều phối nhân viên `Remote` (đi lấy hàng) và nhân viên `Local` (cất kho).
- Nó chứa logic nghiệp vụ: "Đăng nhập xong thì phải lưu token, lưu xong thì mới lấy profile".
- Nó bọc mọi thứ trong `try-catch` để đảm bảo lỗi không văng ra làm crash App, mà được gói gọn gàng vào object `Failure`.

### `auth_repository_impl.dart` > `refreshToken` Flow

- Khi Token hết hạn (API trả về 401 Unauthorized):
  1.  Interceptor (hoặc logic retry) sẽ gọi `refreshToken`.
  2.  Lấy `refreshToken` từ két sắt (`LocalDataSource`).
  3.  Gửi lên API `/auth/refresh`.
  4.  Nhận `accessToken` mới -> Lưu đè vào két sắt.
  5.  Thực hiện lại request cũ.

---

## Tổng Kết

Bạn không cần nhớ hết từng dòng code, chỉ cần nhớ flow:
**UI -> Bloc -> Repository (Impl) -> Remote (API) -> Local (Save) -> Trả về kết quả.**

Toàn bộ việc khởi tạo class (new ...) đã được `injectable` tự làm. Bạn chỉ cần tập trung vào logic logic nghiệp vụ trong Repository và UI trong Widget.
