import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/review.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';

late IO.Socket socket;

class Notification {
  final String id;
  final String title;
  final String? description;
  final String discount;
  final String date;
  final String time;
  final bool read;

  Notification({
    required this.id,
    required this.title,
    this.description,
    required this.discount,
    required this.date,
    required this.time,
    required this.read,
  });
}

// Mock data for "Đơn hàng" (Orders)
final List<Notification> mockOrderNotifications = [
  Notification(
    id: "1",
    title: "KẾT NỐI MỚI NGÀY - MỜI LỐI SỐNG X...",
    description: "Hoàn 50% cho lần nhập điện thoại đầu tiên",
    discount: "50%",
    date: "08/04/2025",
    time: "00:00:00",
    read: false,
  ),
  Notification(
    id: "2",
    title: "Nhà Hàng Bếp Mẹ Ìn",
    discount: "10%",
    date: "03/04/2025",
    time: "14:00:00",
    read: true,
  ),
  Notification(
    id: "3",
    title: "Lê Chấm Tư Lê Resort Hot Spring & Spa",
    discount: "20%",
    date: "01/04/2025",
    time: "14:00:00",
    read: false,
  ),
  Notification(
    id: "4",
    title: "Aqua Sky Bar",
    discount: "10%",
    date: "01/04/2025",
    time: "14:00:00",
    read: true,
  ),
];

// Mock data for "Đánh giá" (Reviews)
final List<Notification> mockReviewNotifications = [
  Notification(
    id: "5",
    title: "Cloud Nine Restaurant",
    discount: "10%",
    date: "01/04/2025",
    time: "14:00:00",
    read: false,
  ),
  Notification(
    id: "6",
    title: "Moonlight Sky Bar",
    discount: "10%",
    date: "01/04/2025",
    time: "14:00:00",
    read: false,
  ),
  Notification(
    id: "7",
    title: "Link Bistro Café",
    discount: "10%",
    date: "01/04/2025",
    time: "14:00:00",
    read: true,
  ),
];

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

List<Review> reviews = [];

class _HomeScreenState extends State<HomeScreen> {
  String activeTab = "orders"; // "orders" hoặc "reviews"

  @override
  void initState() {
    super.initState();
    connectSocket();
    _checkLoginStatus();
    // _loadReviews();
  }

  void connectSocket() {
    socket = IO.io(
      'http://localhost:8080', // hoặc IP máy chủ thật nếu chạy trên thiết bị thật
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print("Socket connected ");
    });

    socket.on("review_notification", (data) {
      final fullName = data['data']['review']['fullName'] ?? "Người dùng";

      // Hiện thông báo toast
      Fluttertoast.showToast(
        msg: "Bạn nhận được một đánh giá mới từ $fullName!",
        toastLength: Toast.LENGTH_LONG, // vẫn giữ là LONG (khoảng 3.5s)
        gravity: ToastGravity.CENTER, // 👉 chuyển sang giữa màn hình
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // Cập nhật danh sách đánh giá
      loadReviews();
    });

    socket.onDisconnect((_) {
      print("Socket disconnected ");
    });
  }

  Future<void> loadReviews() async {
    try {
      final result = await fetchReviewList();
      setState(() {
        reviews = result;
      });
    } catch (e) {
      print("Lỗi khi tải reviews: $e");
    }
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  Future<List<Review>> fetchReviewList() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/v1/review/list'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> jsonList =
          decoded['review']; // 👈 lấy từ key 'review'
      return jsonList.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Xóa token
    Navigator.pushReplacementNamed(context, '/login'); // Chuyển về LoginScreen
  }

  // Tính số thông báo chưa đọc cho mỗi tab
  int get unreadOrdersCount =>
      mockOrderNotifications.where((notification) => !notification.read).length;
  int get unreadReviewsCount =>
      reviews.where((review) => !review.isRead).length;

  List<Notification> get notifications =>
      activeTab == "orders" ? mockOrderNotifications : mockReviewNotifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFeee), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.black, size: 24),
                        onPressed: () {
                          Navigator.pop(context); // Quay lại AdminDashboard
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Thông báo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.black, size: 24),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),

                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFddd), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTab(
                        label: 'Đơn hàng',
                        icon: Icons.shopping_bag_outlined,
                        tabValue: 'orders',
                        unreadCount: unreadOrdersCount,
                      ),
                      _buildTab(
                        label: 'Đánh giá',
                        icon: Icons.star_outline,
                        tabValue: 'reviews',
                        unreadCount: unreadReviewsCount,
                      ),
                    ],
                  ),
                ),

                // Notification List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 80),
                    itemCount: activeTab == 'reviews'
                        ? reviews.length
                        : notifications.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0 && activeTab != 'reviews') {
                        return Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            'Thông báo chi tiết trong 30 ngày gần nhất.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }

                      if (activeTab == 'reviews') {
                        final review = reviews[index];
                        return _buildReviewItem(review);
                      } else {
                        final notification = notifications[index - 1];
                        return _buildNotificationItem(notification);
                      }
                    },
                  ),
                )
              ],
            ),

            // Fixed "Đánh dấu đã đọc" Button
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final response = await http.patch(
                      Uri.parse(
                          'http://localhost:8080/v1/review/mark-all-read'),
                    );

                    if (response.statusCode == 200) {
                      setState(() {
                        reviews = reviews
                            .map((review) => review.copyWith(isRead: true))
                            .toList();
                      });

                      Fluttertoast.showToast(
                        msg: "Tất cả đánh giá đã được đánh dấu là đã đọc",
                        backgroundColor: Colors.green,
                        toastLength:
                            Toast.LENGTH_LONG, // vẫn giữ là LONG (khoảng 3.5s)
                        gravity: ToastGravity.CENTER,
                        textColor: Colors.white,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Không thể cập nhật trạng thái đánh giá",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF007AFF),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Đánh dấu đã đọc',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required String tabValue,
    required int unreadCount,
  }) {
    final isActive = activeTab == tabValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeTab = tabValue;
          });
          if (tabValue == 'reviews') {
            fetchReviewList().then((data) {
              setState(() {
                reviews = data;
              });
            }).catchError((error) {
              print('Error loading reviews: $error');
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Color(0xFF007AFF) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Color(0xFF007AFF) : Colors.black,
              ),
              SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (unreadCount > 0) ...[
                SizedBox(width: 5),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Notification item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: notifications.indexOf(item) == notifications.length - 1
              ? BorderSide.none // Bỏ border cho item cuối
              : BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFE6F0FA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  size: 24,
                  color: Color(0xFFFF3B30),
                ),
              ),
              if (!item.read)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4),
                Text(
                  'Giảm ${item.discount}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${item.time} ${item.date}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: review.isRead == false
            ? Colors.blue[50]
            : Colors.white, // 💡 Màu nền nếu chưa đọc
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star, color: Colors.orange, size: 30),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Text(
                  'Bạn được 1 đánh giá mới từ ${review.fullName ?? "Người dùng"}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6),

                // Sản phẩm
                Text.rich(
                  TextSpan(
                    text: 'Sản phẩm: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: review.product.name ?? "Không rõ",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),

                // Nội dung bình luận
                Text.rich(
                  TextSpan(
                    text: 'Nội dung: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: '"${review.comment}"',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),

                // Đánh giá
                Text.rich(
                  TextSpan(
                    text: 'Đánh giá: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: '${review.rating} ⭐',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),

                // Thời gian
                Text.rich(
                  TextSpan(
                    text: 'Thời gian: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('dd/MM/yyyy – HH:mm')
                            .format(review.createdAt),
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
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
