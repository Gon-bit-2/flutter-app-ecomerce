class CloudinaryHelper {
  /// Biến đổi URL gốc từ Cloudinary thành URL đã được áp dụng các bộ lọc nén, cắt, và giảm dung lượng.
  /// Mặc định:
  /// - `f_auto`: Chuyển định dạng ảnh sang WebP hoặc định dạng tối ưu nhất cho thiết bị.
  /// - `q_auto`: Nén chất lượng ảnh tốt nhất có thể mà mắt thường không phân biệt rõ, tiết kiệm dung lượng.
  /// - `c_fill`: Crop để vừa đủ khung mà không mất tỷ lệ (center focus).
  static String optimizeUrl(
    String originalUrl, {
    int? width,
    int? height,
    String? cropMode = 'fill', // Các mode phổ biến: fill, fit, scale, thumb, pad
  }) {
    if (originalUrl.isEmpty) return originalUrl;

    // Chỉ can thiệp tối ưu hóa nếu đây là URL của hệ thống Cloudinary, 
    // tránh làm hỏng URL nếu load ảnh từ domain khác (vd: google avatar)
    if (!originalUrl.contains('res.cloudinary.com')) {
      return originalUrl;
    }

    // Nếu url đã có sẵn các transform flag, ta không cần ghi đè để tránh conflict
    // Cloudinary format flag luôn nằm ngay sau chữ /upload/
    if (originalUrl.contains('/upload/c_') || 
        originalUrl.contains('/upload/w_') || 
        originalUrl.contains('/upload/q_') || 
        originalUrl.contains('/upload/f_')) {
      return originalUrl;
    }

    final transformations = <String>['f_auto', 'q_auto']; // Luôn ép nén size & format

    // Nếu dev có config width, height từ bên ngoài (AppNetworkImage sẽ lo cái này)
    if (width != null) {
      transformations.add('w_$width');
    }
    if (height != null) {
      transformations.add('h_$height');
    }
    if (cropMode != null) {
      transformations.add('c_$cropMode');
    }

    final transformationString = transformations.join(',');

    // Cloudinary Cấu trúc logic: https://res.cloudinary.com/cloud_name/image/upload/v1234/file.png
    // Ta nhét cái transformation ngay sau chữ /upload/
    final parts = originalUrl.split('/upload/');
    if (parts.length != 2) {
      return originalUrl; // URL format bị lỗi hoặc có nhiều chỗ /upload/ lạ lùng
    }

    // Kết quả mượt như Sunsilk:
    // https://res.cloudinary.com/cloud_name/image/upload/f_auto,q_auto,w_400,h_400,c_fill/v1234/file.png
    return '${parts[0]}/upload/$transformationString/${parts[1]}';
  }
}
