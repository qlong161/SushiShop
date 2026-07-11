import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sushishop_btl/theme/colors.dart';

class FeedbackPage extends StatefulWidget {
  final String?
  initialFoodName; // Nhận tên món ăn mặc định nếu ấn từ trang chi tiết

  const FeedbackPage({super.key, this.initialFoodName});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _supabase = Supabase.instance.client;

  // Các bộ điều khiển nhập liệu
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // Biến lưu trữ món ăn được chọn từ Dropdown thả xuống
  String? selectedFoodName;

  // Danh sách chứa tên tất cả các món ăn kéo từ database về
  List<String> dbFoodNames = [];
  bool isLoadingFoods = true;

  @override
  void initState() {
    super.initState();
    // Đặt món ăn mặc định ban đầu nếu có truyền từ trang chi tiết sang
    if (widget.initialFoodName != null) {
      selectedFoodName = widget.initialFoodName;
    }
    // Tiến hành kéo danh sách món ăn từ database về
    fetchFoodNames();
  }

  // HÀM QUÉT DỮ LIỆU: Lấy toàn bộ cột 'name' trong bảng 'foods'
  void fetchFoodNames() async {
    try {
      final data = await _supabase.from('foods').select('name');
      final List<String> fetchedNames = [];

      for (var item in data) {
        if (item['name'] != null) {
          fetchedNames.add(item['name'].toString());
        }
      }

      setState(() {
        dbFoodNames = fetchedNames;
        // Xử lý an toàn: Nếu món truyền sang không nằm trong list, chèn lên đầu danh sách
        if (selectedFoodName != null &&
            !dbFoodNames.contains(selectedFoodName)) {
          dbFoodNames.insert(0, selectedFoodName!);
        }
        isLoadingFoods = false;
      });
    } catch (e) {
      setState(() {
        isLoadingFoods = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tải được danh sách món ăn từ DB: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void sendFeedback() async {
    if (nameController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập Tên và Nội dung phản hồi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    try {
      // Đẩy dữ liệu lên bảng feedbacks vừa tạo
      await _supabase.from('feedbacks').insert({
        'customer_name': nameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'food_name': selectedFoodName ?? '', // Lưu giá trị đã chọn từ Dropdown
        'feedback_content': contentController.text.trim(),
      });

      if (mounted) Navigator.pop(context); // Tắt loading

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Cảm Ơn Quý Khách! ❤️'),
            content: const Text(
              'Ý kiến đóng góp của bạn đã được ghi nhận để cải thiện dịch vụ nhà hàng ngày một tốt hơn.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Đóng',
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
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi dữ liệu lên mây: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey[900],
        title: Text('Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Trải nghiệm của bạn thế nào?",
              style: TextStyle(
                fontSize: 30,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Hãy chia sẻ ý kiến đóng góp của bạn để Tokyo Sushi phục vụ tốt hơn nhé!",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 25),

            //name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Họ và tên của bạn (*)',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            //sdt
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Số điện thoại liên hệ',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            isLoadingFoods
                ? const Center(
                    child: LinearProgressIndicator(color: Colors.red),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFoodName,
                        hint: const Text(
                          'Chọn món ăn cần góp ý (Không bắt buộc)',
                        ),
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                        items: dbFoodNames.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedFoodName = newValue;
                          });
                        },
                      ),
                    ),
                  ),
            const SizedBox(height: 15),

            // 4. Ô nhập nội dung feedback
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Nội dung phản hồi chi tiết (*)',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Nút bấm kích hoạt bắn gói tin
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: sendFeedback,
                child: const Text(
                  'Gửi ý kiến đóng góp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
