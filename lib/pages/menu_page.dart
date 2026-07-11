import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sushishop_btl/components/button.dart';
import 'package:sushishop_btl/models/food.dart';
import 'package:sushishop_btl/theme/colors.dart';
import 'package:sushishop_btl/components/food_tile.dart';
import 'package:sushishop_btl/pages/food_details_page.dart';
import 'package:sushishop_btl/pages/cart_page.dart';
import 'package:sushishop_btl/pages/intro_page.dart';
import 'package:sushishop_btl/pages/all_feedbacks_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _supabase = Supabase.instance.client;

  String searchQuery = "";

  List<Food> globalCart = [];

  void navigateToFoodDetails(Food food) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FoodDetailsPage(food: food, currentCart: globalCart),
      ),
    );
    setState(() {});
  }

  void openCartPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage(cartItems: globalCart)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        // Quay lại IntroPage
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[900]),
          onPressed: () {
            // Xóa sạch lịch sử các trang trước đó và quay lại IntroPage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const IntroPage()),
              (route) => false,
            );
          },
        ),

        title: Text('Tokyo', style: TextStyle(color: Colors.grey[900])),
        actions: [
          // ĐÃ THÊM: Nút xem danh sách Feedback nằm bên cạnh nút giỏ hàng
          IconButton(
            icon: Icon(
              Icons.rate_review_outlined,
              color: Colors.grey[900],
              size: 26,
            ),
            tooltip: 'Xem đánh giá của khách hàng',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllFeedbacksPage(),
                ),
              );
            },
          ),

          const SizedBox(width: 5),

          // Nút Giỏ Hàng kèm số lượng
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.grey[900],
                  size: 28,
                ),
                onPressed: openCartPage,
              ),
              if (globalCart.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${globalCart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Promo banner
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get 32% promo',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyButton(text: "redeem", onTap: () {}),
                  ],
                ),
                Image.asset('lib/images/many_sushi.png', height: 100),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // 2. Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                hintText: "Search here..",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // 3. Menu list title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Food Menu",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            flex: 3,
            child: FutureBuilder<List<dynamic>>(
              future: _supabase.from('foods').select(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Lỗi kết nối Supabase rồi!'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }

                List<Food> allFoods = snapshot.data!
                    .map((item) => Food.fromMap(item))
                    .toList();

                List<Food> dbFoodMenu = allFoods.where((food) {
                  return food.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
                }).toList();

                if (dbFoodMenu.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy món sushi nào phù hợp',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dbFoodMenu.length,
                  itemBuilder: (context, index) {
                    final currentFood = dbFoodMenu[index];
                    return FoodTile(
                      food: currentFood,
                      onTap: () => navigateToFoodDetails(currentFood),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 25),

          // 5. Popular food title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Must try foods",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            flex: 2,
            child: FutureBuilder<List<dynamic>>(
              future: _supabase.from('foods').select(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: SizedBox());
                }

                List<Food> allFoods = snapshot.data!
                    .map((item) => Food.fromMap(item))
                    .toList();

                List<Food> popularFoods = allFoods.where((food) {
                  double rating = double.tryParse(food.rating) ?? 0.0;
                  return rating >= 4.5;
                }).toList();

                if (popularFoods.isEmpty) {
                  return const Center(
                    child: Text('Trống', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: popularFoods.length,
                  itemBuilder: (context, index) {
                    final food = popularFoods[index];
                    return GestureDetector(
                      onTap: () => navigateToFoodDetails(food),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.only(
                          left: 25,
                          right: 25,
                          bottom: 10,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(food.imagePath, height: 60),
                                const SizedBox(width: 25),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '\$' + food.price,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  food.rating,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
