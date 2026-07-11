import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sushishop_btl/models/food.dart';
import 'package:sushishop_btl/theme/colors.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  // Kết nối Supabase Client
  final _supabase = Supabase.instance.client;

  late TabController _tabController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    imageController.dispose();
    ratingController.dispose();
    descController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void createNewFood() {
    nameController.clear();
    priceController.clear();
    imageController.clear();
    ratingController.clear();
    descController.clear();

    imageController.text = "lib/images/salmon_sushi.png";
    ratingController.text = "4.5";

    showFoodDialog();
  }

  void showFoodDialog({Food? food}) {
    bool isEditing = food != null;
    if (isEditing) {
      nameController.text = food.name;
      priceController.text = food.price;
      imageController.text = food.imagePath;
      ratingController.text = food.rating;
      descController.text = food.description;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEditing ? 'Sửa Món Sushi' : 'Thêm Món Sushi Mới',
          style: GoogleFonts.dmSerifDisplay(),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên món ăn'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Giá cả'),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'Đường dẫn ảnh asset',
                ),
              ),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(
                  labelText: 'Đánh giá (Rating)',
                ),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                final foodData = {
                  'name': nameController.text,
                  'price': priceController.text,
                  'imagePath': imageController.text,
                  'rating': ratingController.text,
                  'description': descController.text,
                };

                if (isEditing) {
                  await _supabase
                      .from('foods')
                      .update(foodData)
                      .eq('id', food.id!);
                } else {
                  await _supabase.from('foods').insert(foodData);
                }

                if (mounted) Navigator.pop(context);
              }
            },
            child: Text(
              isEditing ? 'Cập nhật' : 'Lưu lại',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void deleteFood(String id) async {
    await _supabase.from('foods').delete().eq('id', id);
  }

  void deleteOrder(String id) async {
    await _supabase.from('orders').delete().eq('id', id);
  }

  void deleteFeedback(String id) async {
    await _supabase.from('feedbacks').delete().eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'A D M I N  P A N E L',
          style: GoogleFonts.dmSerifDisplay(letterSpacing: 2),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.fastfood), text: "Quản lý món ăn"),
            Tab(icon: Icon(Icons.receipt_long), text: "Đơn hàng mới"),
            Tab(icon: Icon(Icons.rate_review), text: "Phê duyệt Feedback"),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return _tabController.index == 0
              ? FloatingActionButton(
                  backgroundColor: primaryColor,
                  onPressed: createNewFood,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : const SizedBox();
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          //menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "Danh sách thực đơn hiện tại",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _supabase.from('foods').stream(primaryKey: ['id']),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return const Center(child: Text('Lỗi tải thực đơn!'));
                    if (!snapshot.hasData)
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      );

                    final rawDocs = snapshot.data!;
                    List<Food> adminFoodMenu = rawDocs
                        .map((item) => Food.fromMap(item))
                        .toList();

                    if (adminFoodMenu.isEmpty) {
                      return const Center(
                        child: Text('Danh sách trống. Bấm nút + để thêm món!'),
                      );
                    }

                    return ListView.builder(
                      itemCount: adminFoodMenu.length,
                      itemBuilder: (context, index) {
                        final food = adminFoodMenu[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            bottom: 10,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: ListTile(
                            leading: Image.asset(food.imagePath, height: 40),
                            title: Text(
                              food.name,
                              style: GoogleFonts.dmSerifDisplay(fontSize: 16),
                            ),
                            subtitle: Text('\$${food.price}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => showFoodDialog(food: food),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    if (food.id != null) deleteFood(food.id!);
                                  },
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
            ],
          ),

          //orderlist
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "Đơn đặt hàng trực tuyến",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _supabase.from('orders').stream(primaryKey: ['id']),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return const Center(
                        child: Text('Lỗi kết nối luồng đơn hàng!'),
                      );
                    if (!snapshot.hasData)
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      );

                    final orders = snapshot.data!;

                    if (orders.isEmpty) {
                      return const Center(
                        child: Text(
                          'Hiện tại chưa có đơn hàng nào mới.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final String orderId = order['id'].toString();
                        final String summary =
                            order['items_summary'] ?? 'Không rõ món';
                        final String price = order['total_price'] ?? '0.00';

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                            ),
                          ),
                          margin: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            bottom: 12,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.restaurant,
                                color: primaryColor,
                              ),
                            ),
                            title: Text(
                              summary,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Thành tiền: \$$price',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 28,
                              ),
                              tooltip: 'Hoàn thành đơn hàng',
                              onPressed: () => deleteOrder(orderId),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          //feedback
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "Hộp thư Phản hồi & Duyệt hiển thị",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _supabase
                      .from('feedbacks')
                      .stream(primaryKey: ['id']),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return const Center(
                        child: Text('Lỗi kết nối luồng Feedback!'),
                      );
                    if (!snapshot.hasData)
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      );

                    final feedbacks = snapshot.data!;
                    if (feedbacks.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có phản hồi nào từ khách.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) {
                        final fb = feedbacks[index];
                        final String feedbackId = fb['id'].toString();
                        bool isApproved = fb['is_approved'] ?? false;
                        String phone = fb['phone_number'] ?? 'Không để lại SĐT';
                        String food = fb['food_name'] ?? '';

                        return Container(
                          decoration: BoxDecoration(
                            color: isApproved
                                ? Colors.green.shade50
                                : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: isApproved
                                ? Border.all(color: Colors.green.shade300)
                                : null,
                          ),
                          margin: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            bottom: 12,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isApproved
                                  ? Colors.green
                                  : Colors.amber,
                              child: Icon(
                                isApproved ? Icons.verified : Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              '${fb['customer_name']} ($phone)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (food.isNotEmpty)
                                  Text(
                                    'Món: $food',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  '"${fb['feedback_content']}"',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // NÚT PHÊ DUYỆT
                                IconButton(
                                  icon: Icon(
                                    isApproved
                                        ? Icons.visibility_off
                                        : Icons.check_circle,
                                    color: isApproved
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                  tooltip: isApproved
                                      ? 'Ẩn khỏi App'
                                      : 'Duyệt lên App',
                                  onPressed: () async {
                                    await _supabase
                                        .from('feedbacks')
                                        .update({'is_approved': !isApproved})
                                        .eq('id', feedbackId);
                                  },
                                ),
                                // Nút xóa vĩnh viễn
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Xóa vĩnh viễn',
                                  onPressed: () => deleteFeedback(feedbackId),
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
            ],
          ),
        ],
      ),
    );
  }
}
