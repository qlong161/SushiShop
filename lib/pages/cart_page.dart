import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. IMPORT SUPABASE VÀO ĐÂY
import 'package:sushishop_btl/models/food.dart';
import 'package:sushishop_btl/theme/colors.dart';

class CartPage extends StatefulWidget {
  final List<Food> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> getGroupedCart() {
    List<Map<String, dynamic>> grouped = [];
    for (var item in widget.cartItems) {
      int index = grouped.indexWhere(
        (element) => element['food'].name == item.name,
      );
      if (index != -1) {
        grouped[index]['quantity']++;
      } else {
        grouped.add({'food': item, 'quantity': 1});
      }
    }
    return grouped;
  }

  double calculateTotal(List<Map<String, dynamic>> groupedCart) {
    double total = 0;
    for (var item in groupedCart) {
      double price = double.tryParse(item['food'].price) ?? 0.0;
      int qty = item['quantity'] as int;
      total += price * qty;
    }
    return total;
  }

  void increaseQuantity(Food food) {
    setState(() {
      widget.cartItems.add(food);
    });
  }

  void decreaseQuantity(Food food) {
    setState(() {
      int index = widget.cartItems.lastIndexWhere(
        (element) => element.name == food.name,
      );
      if (index != -1) {
        widget.cartItems.removeAt(index);
      }
    });
  }

  void checkoutOrder(List<Map<String, dynamic>> groupedCart) async {
    if (widget.cartItems.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    List<String> summaryParts = [];
    for (var item in groupedCart) {
      summaryParts.add("${item['quantity']}x ${item['food'].name}");
    }
    String itemsSummary = summaryParts.join(", ");
    double finalPrice = calculateTotal(groupedCart);

    try {
      await _supabase.from('orders').insert({
        'total_price': finalPrice.toStringAsFixed(2),
        'items_summary': itemsSummary,
      });

      if (mounted) Navigator.pop(context);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Thành Công! 🎉', style: GoogleFonts.dmSerifDisplay()),
            content: const Text(
              'Món ăn đã được đặt, cảm ơn quý khách đã sử dụng dịch vụ tại nhà hàng',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.cartItems.clear(); // Xóa sạch giỏ hàng gốc
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/menupage',
                    (route) => false,
                  );
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Bẫy lỗi nếu đường truyền mạng gặp vấn đề hoặc sai tên bảng
      if (mounted) Navigator.pop(context); // Tắt loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đặt hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedCart = getGroupedCart();

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey[900],
        title: Text('Cart', style: GoogleFonts.dmSerifDisplay()),
      ),
      body: groupedCart.isEmpty
          ? const Center(
              child: Text(
                'Giỏ hàng trống trơn, quay lại chọn món đi b!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: groupedCart.length,
                    itemBuilder: (context, index) {
                      final item = groupedCart[index];
                      final Food food = item['food'];
                      final int quantity = item['quantity'];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(
                          left: 25,
                          right: 25,
                          top: 10,
                        ),
                        child: ListTile(
                          leading: Image.asset(food.imagePath, height: 40),
                          title: Text(
                            food.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('\$${food.price}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.grey,
                                ),
                                onPressed: () => decreaseQuantity(food),
                              ),
                              Text(
                                '$quantity',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: primaryColor,
                                ),
                                onPressed: () => increaseQuantity(food),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng thanh toán:',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            '\$${calculateTotal(groupedCart).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => checkoutOrder(groupedCart),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Đặt món ngay ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
