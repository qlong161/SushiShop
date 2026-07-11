import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sushishop_btl/models/food.dart';

class FoodTile extends StatelessWidget {
  final Food food;
  final void Function()? onTap;

  const FoodTile({
    super.key,
    required this.food,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.only(left: 25),
        padding: const EdgeInsets.all(25),
        width: 200,
        // 1. CỐ ĐỊNH chiều rộng của thẻ để không bị méo khi bật trên Web
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //image
            // 2. SỬA: Bọc Expanded và xóa height: 140 để ảnh tự co giãn theo thiết bị (Web/Mobile)
            Expanded(
              child: Center(
                child: Image.asset(
                  food.imagePath,
                  fit: BoxFit.contain, // Giữ nguyên tỷ lệ ảnh, không bị móp
                ),
              ),
            ),

            const SizedBox(height: 10),
            // Thêm khoảng cách nhỏ giữa ảnh và chữ

            // text
            Text(
              food.name,
              style: GoogleFonts.dmSerifDisplay(fontSize: 20),
              maxLines: 1, // Tránh chữ quá dài làm nhảy dòng gây lỗi giao diện
              overflow: TextOverflow
                  .ellipsis, // Nếu quá dài tự động xuất hiện dấu "..."
            ),

            const SizedBox(height: 5),
            // Thêm khoảng cách giữa chữ và giá tiền

            // price + rating
            // 3. SỬA: Thay SizedBox bằng Row để tự động dàn đều hai bên dựa theo width của Container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //price
                Text(
                  '\$${food.price}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),

                //rating
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow[800], size: 18),
                    const SizedBox(width: 4),
                    Text(food.rating,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}