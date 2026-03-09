import 'package:flutter/material.dart';
import '../../domain/entities/discount.dart';
import 'package:intl/intl.dart';

class DiscountCardWidget extends StatelessWidget {
  final Discount discount;
  final bool isSelected;
  final VoidCallback? onTap;

  const DiscountCardWidget({
    Key? key,
    required this.discount,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Format giá trị hiển thị
    String valueText = '';
    String prefixText = 'Giảm ';
    if (discount.type == DiscountType.PERCENTAGE) {
      valueText = '${discount.value.toInt()}%';
    } else {
      valueText = currencyFormatter.format(discount.value);
    }

    // Nhận diện loại Freeship chính xác từ enum
    final isFreeship =
        discount.type == DiscountType.SHIPPING ||
        discount.name.toLowerCase().contains('freeship') ||
        discount.name.toLowerCase().contains('vận chuyển');
    final tagColor = isFreeship
        ? Colors.teal
        : (discount.scope == DiscountScope.SHOP
              ? Colors.orange.shade700
              : Theme.of(context).primaryColor);
    final bgColor = isFreeship
        ? Colors.teal.shade50
        : (discount.scope == DiscountScope.SHOP
              ? Colors.orange.shade50
              : Theme.of(context).primaryColor.withOpacity(0.05));

    return GestureDetector(
      onTap: discount.isActive ? onTap : null,
      child: Opacity(
        opacity: discount.isActive ? 1.0 : 0.5,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? tagColor : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phần trái: Badge / Chuyên mục
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                        style:
                            BorderStyle.none, // Hide solid border to use dash
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isFreeship
                                  ? Icons.local_shipping
                                  : (discount.scope == DiscountScope.SHOP
                                        ? Icons.storefront
                                        : Icons.local_activity),
                              color: tagColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                discount.scope == DiscountScope.SHOP
                                    ? 'SHOP'
                                    : 'TẤT CẢ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: tagColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Nét đứt chia cắt (Dashed Line)
                SizedBox(
                  width: 1,
                  child: Column(
                    children: List.generate(
                      15,
                      (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ),

                // Phần phải: Thông tin thẻ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: prefixText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text: valueText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: tagColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (discount.maxDiscountValue != null &&
                            discount.maxDiscountValue! > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Giảm tối đa ${currencyFormatter.format(discount.maxDiscountValue)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Đơn tối thiểu ${currencyFormatter.format(discount.minOrderValue)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: tagColor.withOpacity(0.5),
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                discount.code,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: tagColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: tagColor,
                                size: 22,
                              )
                            else if (!isSelected && onTap != null)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'HSD: ${dateFormat.format(discount.endDate)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
