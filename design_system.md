# Design System - Ứng Dụng E-Commerce

## 1. Tổng Quan
Tài liệu này mô tả hệ thống thiết kế (Design System) cho ứng dụng thương mại điện tử, tập trung vào trải nghiệm người dùng liền mạch, thân thiện và dễ sử dụng.
- **Phong cách thiết kế:** Hiện đại, tối giản, trực quan và sạch sẽ.
- **Mục tiêu:** Đồng nhất UI trên toàn ứng dụng để đảm bảo người dùng có thể thao tác tiện lợi nhất.

## 2. Màu Sắc (Color Palette)
Màu sắc chủ đạo của ứng dụng là **Xanh da trời (Sky Blue)** và **Trắng (White)**, mang lại cảm giác tươi mới, chuyên nghiệp và tin cậy.

- **Primary Color (Màu chính):** Xanh da trời (`#00A8E8` hoặc `#2196F3`). 
  - *Sử dụng:* Các nút bấm chính (Button), Icon đang chọn ở thanh Navigation, các liên kết/text cần nhấn mạnh, checkbox/radio button khi đang chọn.
- **Secondary Color (Màu phụ):** Xanh nhạt (`#E3F2FD`).
  - *Sử dụng:* Nền của các phần cảnh báo thông tin nhẹ nhàng, background của icon báo hiệu hoặc header/banner nổi bật nhẹ.
- **Background Color (Nền):** Trắng (`#FFFFFF`). 
  - *Sử dụng:* Nền chủ đạo của toàn bộ ứng dụng, giúp nội dung sản phẩm nổi bật.
- **Surface Color (Bề mặt phụ):** Trắng xám (`#F5F5F7`). 
  - *Sử dụng:* Dùng cho nền của các thẻ (Card), ô tìm kiếm, nền sau các khối thông tin để tạo sự tách biệt mà không cần viền.
- **Text Colors (Màu chữ):**
  - *Tiêu đề \& Văn bản chính:* Đen xám (`#212121`).
  - *Phụ đề \& Văn bản phụ:* Xám nhạt (`#757575`).
- **Semantic Colors (Màu trạng thái):**
  - *Thành công:* Xanh lá (`#4CAF50`).
  - *Cảnh báo:* Vàng cam (`#FF9800`) / Đang xử lý.
  - *Lỗi / Xóa:* Đỏ (`#F44336`) (Dùng cho thông báo lỗi hoặc nút Xóa sản phẩm).

## 3. Typography (Kiểu chữ)
Sử dụng các font chữ chữ không chân (San-Serif) dễ nhìn trên mọi kích thước (ví dụ: `Roboto`, `Inter` hoặc `SF Pro Display`).

- **Heading 1 (H1):** 28px, Bold - Tiêu đề trang hoặc màn hình.
- **Heading 2 (H2):** 20px, SemiBold - Tiêu đề các mục lớn (ví dụ: "Sản phẩm nổi bật", "Gợi ý cho bạn").
- **Body Text:** 14px đến 16px, Regular - Tên sản phẩm, mô tả nội dung.
- **Caption:** 12px, Regular, màu xám - Thời gian tin nhắn, chi tiết phụ.
- **Button Text:** 16px, Medium - Thường giữ chữ thường hoặc viết hoa chữ cái đầu.

## 4. Các Thành Phần Giao Diện Cơ Bản (Components)

### 4.1. Buttons (Nút bấm)
- **Primary Button (Nút chính):** Nền Xanh da trời, chữ Trắng. Góc bo tròn mềm mại (`borderRadius: 8px` hoặc `12px`). Dùng cho: "Đăng nhập", "Mua ngay", "Xác nhận".
- **Outline Button (Nút có viền):** Không màu nền, viền Xanh da trời, chữ Xanh da trời. Dùng cho: "Thêm vào giỏ", "Hủy bỏ", "Theo dõi".
- **Disabled Button (Nút mờ):** Nền khối xám nhạt (`#E0E0E0`), chữ xám (khi form chưa điền đủ).

### 4.2. Text Fields (Ô nhập liệu)
- **Trạng thái mặc định:** Nền xám rất nhạt (`#F5F5F7`), không viền hoặc viền xám siêu mỏng. Bo góc `8px`. Trông gọn và hiện đại hơn dạng viền truyền thống.
- **Trạng thái đang nhập (Focused):** Viền chuyển sang màu Xanh da trời (Primary), đổ bóng viền mờ màu xanh.

### 4.3. Product Card (Thẻ hiển thị Sản phẩm)
- Nền Trắng, có shadow cực nhẹ để nẩy thẻ lên. Bo góc `12px`.
- Layout từ trên xuống: Ảnh sản phẩm (tỉ lệ 1:1) -> Tên sản phẩm (tối đa 2 dòng, cắt chữ thành dấu ...) -> Giá tiền (Màu xanh chủ đạo, in đậm) -> Tag/Rating (Số sao) góc phải.

### 4.4. Bottom Navigation Bar (Thanh điều hướng dưới)
- Nền trắng trơn, có shadow trên cùng mờ nhẹ để cách biệt nội dung.
- Icon trang hiện tại: Màu Xanh da trời kèm tên tab màu xanh.
- Icon trang khác: Màu xám (`#757575`).

---

## 5. Thiết Kế Màn Hình Ứng Dụng (Screen Designs)

### 5.1. Xác Thực (Đăng nhập / Đăng ký)
- **Giao diện:** Tối giản. Nền trắng hoàn toàn.
- **Chi tiết:**
  - Logo màu Xanh da trời ở giữa màn hình.
  - Các ô nhập Email, Mật khẩu có biểu tượng icon nhỏ bên trong giúp dễ nhận diện chức năng.
  - Sử dụng chung nút Primary to, tràn chiều ngang trừ phần lề hai bên (padding 20px).
  - Khuyến khích đăng nhập nhanh bằng Google/Apple bằng các nút có viền xám nhạt.

### 5.2. Màn Hình Trang Chủ (Home)
- **Header:** Thanh tìm kiếm (Search Bar) bo tròn với icon kính lúp mờ ở trái. Khu vực nền Header màu Xanh gradient nhẹ từ trên xuống để làm sang trọng app. Góc phải có Icon Giỏ hàng (chứa số lượng hiển thị đỏ nhỏ ở góc).
- **Banner:** Carousel trượt tự động các khuyến mãi. Bo tròn góc banner.
- **Danh Mục (Category):** Circle Icons background xanh siêu nhạt. Text dưới icon.
- **Feed Sản Phẩm:** Sử dụng lưới (Grid 2 cột). Khu vực nền feed chuyển qua màu Trắng xám (`#F5F5F7`) để phần Product Card (màu trắng) tự động nổi bật lên nhờ màu sắc tương phản.

### 5.3. Tìm Kiếm & Lọc (Search & Filter)
- **Trang trước khi gõ tìm kiếm:** Hiển thị "Lịch sử tìm kiếm" dưới dạng các nút hình viên thuốc (Pill shape) viền xám để người dùng tiện nhấn tìm lại.
- **Trên trang kết quả tìm kiếm:**
  - Có thanh Lọc (Filter Tabs: Phổ biến, Mới nhất, Bán chạy, Giá mũi tên lên/xuống). Tab đang chọn text đậm lên và có viền chân màu xanh da trời.

### 5.4. Giỏ Hàng & Thanh Toán (Cart & Checkout)
- **Giỏ hàng:**
  - Layout chia thành các Shop riêng biệt. Mỗi sản phẩm có 1 Checkbox (icon tròn chấm xanh khi check).
  - Có khu vực chọn "Shopee/App Voucher" viền đứt đoạn hoặc màu ưu đãi bắt mắt.
  - Phần Footer tổng tiền nổi bật nằm cố định ở mép dưới màn hình, tích hợp Nút "Mua hàng" (Primary Color).
- **Checkout:**
  - Block "Địa chỉ nhận hàng" nằm trên cùng: Icon location màu đỏ/xanh + tên, SĐT, địa chỉ (dễ dàng nhấn để đổi).
  - Tổng kết giá trị thanh toán chi tiết (Phí ship, Mã giảm giá, Tổng cộng).

### 5.5. Shop Video (Tính năng nổi bật giống Shopee Video / Reels)
- **Chủ đạo:** Nền đen hoàn toàn để video có chiều sâu và sống động, trải nghiệm lướt dọc vô tận.
- **Bố cục:**
  - Video chơi toàn màn hình, nút "Trở về" góc trái trên (trắng mờ).
  - **Tương tác (Phải):** Icon Trái tim, Comment, Chia sẻ xếp dọc bên cạnh phải.
  - **Chi tiết \& Sản phẩm (Trái & Dưới):** Tên user ở dưới góc trái. Ngay dưới đó là Box/Thẻ sản phẩm được link vào video. Box này dùng thiết kế Card mờ (`backdrop-filter`) chữ trắng hoặc chuyển hẳn về khung nền vàng nhạt/xanh nhạt thu hút click "Mua ngay". Nhấn vào sẽ đẩy 1 Bottom Sheet gồm list danh sách sản phẩm.

### 5.6. Nhắn Tin (Chat)
- **List Danh sách Chat:** Layout quen thuộc, ảnh Avatar hình tròn bên trái, Tên in đậm lên cùng số lượng thông báo chờ.
- **Màn Hình Chat:** 
  - Nền chat có thể là Trắng xám `#F5F5F7`.
  - Bubble tin nhắn người mua (mình gửi): Màu Xanh da trời, chữ trắng (Căn phải).
  - Bubble tin nhắn người bán (đối tác): Nền trắng, chữ đen (Căn trái) có bóng drop-shadow siêu nhẹ.
  - Header màn chat có thể ghim sản phẩm đang bàn luận lên trên cùng.

### 5.7. Hồ Sơ (Profile) & Thêm Sản Phẩm Mới (Shop Mgmt)
- **Hồ sơ cá nhân:** Header có nền màu Xanh da trời. Chứa Ảnh đại diện (viền trắng) + Tên tài khoản. Bên dưới là một Card thống kê đơn hàng (Chờ xác nhận, Đang giao, Đã nhận).
- **Thêm Sản Phẩm:**
  - Giao diện form dọc.
  - Input tải ảnh lên: Có khung hình vuông nét đứt viền xám/xanh bọc ngoài, icon dấu cộng lớn ở giữa với text "Thêm ảnh / Video".
  - Chức năng toggle (Bật/tắt) trạng thái kho hiển thị theo kiểu thanh Switch (Bật sang màu xanh da trời).

## 6. Lời Khuyên Trải Nghiệm & UI/UX Chung
1. **Empty States (Trạng thái Rỗng):** Thay vì màn hình trống rỗng nhàm chán khi chưa có mặt hàng trong thông báo/giỏ hàng, sử dụng các hình minh hoạ (vector) dễ thương, đi kèm một thông điệp như "Giỏ hàng của bạn đang trống, hãy thêm đồ đi!" + 1 nút back về Home.
2. **Skeleton Loading:** Hiển thị màn hình chờ dạng khung xương xám nháy mờ (thay cho con quay loading) tại trang chủ và màn tìm kiếm sản phẩm sẽ tạo cảm giác load ứng dụng mượt và nhanh hơn.
3. **Phản hồi tương tác (Touch Feedback):** Bất cứ lúc tab/chạm vào nút, card, hoặc icon nào trên App đều phải có hiệu ứng gợn nhẹ (Ripple Effect - thiết kế sẵn của Flutter Material) cấu hình mang gam màu phụ hoặc xám mờ để người dùng nhận thức thao tác thành công.
4. **Spacing (Khoảng trống):** Mép dọc (Padding ngang) của màn hình thường là `16px` đến `20px` để cho tổng thể gọn gàng, tinh tế và không bị chật chội.
