# 🛒 SushiShop - Tokyo Sushi Shop (Nhóm 9)
> **Môn học:** Lập trình cho thiết bị di động  
> **Nền tảng:** Flutter Framework (Dart) & Supabase Cloud Backend (PostgreSQL)

---

## 👥 Thành viên nhóm 9
* **Nguyễn Hữu Quang Long** (MSV: 23010309) 
* **Bùi Việt Long** (MSV: 23010278) 
* **Phạm Khắc Hùng** (MSV: 23017320)

---

## 📝 Giới thiệu dự án
**Tokyo Sushi Shop** là ứng dụng di động đặt món ăn trực tuyến được xây dựng dựa trên kiến trúc hiện đại, kết hợp sức mạnh giao diện mượt mà của **Flutter** và khả năng đồng bộ dữ liệu theo thời gian thực (**Realtime Stream**) cực mạnh của **Supabase Cloud**. 

Dự án nhằm giải quyết triệt để các hạn chế của mô hình gọi món truyền thống, mang lại trải nghiệm liền mạch cho cả **Khách hàng** lẫn **Quản trị viên nhà hàng**.

---

## ✨ Các tính năng nổi bật

### 1. Phía Khách hàng (Guest View) 🍣
* **Khám phá Thực đơn thông minh:** Menu phân chia khoa học thành danh sách cuộn ngang (`Food Menu`) và danh sách đề xuất cuộn dọc (`Must try foods` - tự động lọc các món có rating >= 4.5).
* **Tìm kiếm động:** Ô tìm kiếm thông minh bắt sự kiện lọc món ăn trực tiếp ngay khi người dùng nhập ký tự.
* **Giỏ hàng tối ưu:** Tự động gộp các sản phẩm trùng nhau, hỗ trợ tăng/giảm số lượng và xóa món linh hoạt kèm bộ tính tổng tiền tự động.
* **Form Feedback nâng cao:** Khách hàng có thể gửi đánh giá kèm bộ chọn thả xuống (`DropdownButton`) quét động tên món ăn từ Database, tránh việc nhập sai dữ liệu.
* **Hòm thư đánh giá công cộng:** Hiển thị danh sách các phản hồi thực tế của khách hàng đã qua kiểm duyệt một cách trực quan.

### 2. Phía Quản trị viên (Admin Panel) 🛠️
* **Thiết kế giao diện Tab tập trung:** Gộp toàn bộ tính năng quản trị vào 1 màn hình duy nhất với 3 Tab điều hướng mượt mà: *Quản lý món ăn*, *Đơn hàng mới*, và *Phê duyệt Feedback*.
* **CRUD Thực đơn Realtime:** Thêm món mới, Sửa thông tin, Xóa món ăn với hiệu ứng đồng bộ ngay lập tức xuống màn hình của khách hàng mà không cần tải lại app.
* **Xử lý đơn hàng trực tuyến:** Lắng nghe luồng dữ liệu đơn hàng liên tục. Khi khách bấm đặt món, đơn hàng lập tức hiển thị trên màn hình Admin. Admin xử lý xong chỉ cần bấm tích xanh để hoàn thành.
* **Kiểm duyệt Feedback linh hoạt:** Hỗ trợ tính năng Bật/Tắt hiển thị đánh giá của khách (`is_approved`). Giao diện Admin tự động đổi màu nền thông minh (Màu xanh mờ cho feedback đã duyệt) giúp quản trị trực quan.

---

## 📐 Kiến trúc & Sơ đồ Cơ sở dữ liệu (Database Schema)
Ứng dụng sử dụng Cơ sở dữ liệu quan hệ **PostgreSQL** trên **Supabase Cloud** bao gồm 3 bảng cốt lõi:
1. `foods`: Lưu trữ danh sách thực đơn (id, name, price, imagePath, rating, description).
2. `orders`: Lưu trữ thông tin đơn đặt hàng (id, created_at, total_price, items_summary).
3. `feedbacks`: Lưu trữ hòm thư góp ý của khách hàng (id, customer_name, phone_number, food_name, feedback_content, is_approved).

---
