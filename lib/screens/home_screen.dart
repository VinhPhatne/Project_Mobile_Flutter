import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/review.dart';
import '../models/OrderNotification .dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';
import 'order_detail_screen.dart';

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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

List<Review> reviews = [];
List<OrderNotification> orderNotifications = [];

class _HomeScreenState extends State<HomeScreen> {
  String activeTab = "orders"; // "orders" hoặc "reviews"

  @override
  void initState() {
    super.initState();
    if (activeTab == 'orders') {
      fetchOrderNotificationList().then((data) {
        setState(() {
          orderNotifications = data;
        });
      }).catchError((error) {
        print('Error loading order notifications: $error');
      });
    }
    connectSocket();
    _checkLoginStatus();

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

    socket.on("billCreated", (data) {
      final message = "Bạn có một đơn hàng mới";
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      loadOrderNotifications();
    });
    socket.on("review_notification", (data) {
      final fullName = data['data']['review']['fullName'] ?? "Người dùng";

      // Hiện thông báo toast
      Fluttertoast.showToast(
        msg: "Bạn nhận được một đánh giá mới từ $fullName!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      loadReviews();
    });

    socket.onDisconnect((_) {
      print("Socket disconnected ");
    });

    socket.onError((error) {
      print("Socket error: $error");
    });
  }

  Future<void> loadOrderNotifications() async {
    try {
      final result = await fetchOrderNotificationList();
      setState(() {
        orderNotifications = result;
      });
    } catch (e) {
      print("Lỗi khi tải order notifications: $e");
    }
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

  Future<List<OrderNotification>> fetchOrderNotificationList() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/v1/order-notify/list'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => OrderNotification.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load order notifications');
    }
  }

  Future<void> updateNotificationStatus(String notificationId) async {
    final url =
        'http://localhost:8080/v1/order-notify/update-isRead/$notificationId';

    try {
      final response = await http.patch(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        print('Notification updated successfully');
      } else {
        print('Failed to update notification');
      }
    } catch (e) {
      print('Error updating notification: $e');
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
  int get unreadOrdersCount => orderNotifications
      .where((orderNotification) => !orderNotification.isRead)
      .length;
  int get unreadReviewsCount =>
      reviews.where((review) => !review.isRead).length;

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
                        : orderNotifications.length + 1,
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
                        if (index - 1 < orderNotifications.length) {
                          final orderNotification =
                              orderNotifications[index - 1];
                          return _buildNotificationItem(orderNotification);
                        } else {
                          return SizedBox(); // fallback tránh lỗi
                        }
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
                  String url = '';
                  String successMessage = '';
                  String errorMessage = '';

                  if (activeTab == 'reviews') {
                    url = 'http://localhost:8080/v1/review/mark-all-read';
                    successMessage =
                        'Tất cả đánh giá đã được đánh dấu là đã đọc';
                    errorMessage = 'Không thể cập nhật trạng thái đánh giá';
                  } else if (activeTab == 'orders') {
                    url =
                        'http://localhost:8080/v1/order-notify/update-all-isRead';
                    successMessage =
                        'Tất cả thông báo đơn hàng đã được đánh dấu là đã đọc';
                    errorMessage =
                        'Không thể cập nhật trạng thái thông báo đơn hàng';
                  } else {
                    Fluttertoast.showToast(
                      msg: "Tab không hợp lệ",
                      backgroundColor: Colors.orange,
                      textColor: Colors.white,
                    );
                    return;
                  }

                  try {
                    final response = await http.patch(Uri.parse(url));

                    if (response.statusCode == 200) {
                      setState(() {
                        if (activeTab == 'reviews') {
                          reviews = reviews
                              .map((review) => review.copyWith(isRead: true))
                              .toList();
                        } else if (activeTab == 'orders') {
                          orderNotifications = orderNotifications
                              .map((notify) => notify.copyWith(isRead: true))
                              .toList();
                        }
                      });

                      Fluttertoast.showToast(
                        msg: successMessage,
                        backgroundColor: Colors.green,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        textColor: Colors.white,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: errorMessage,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  } catch (e) {
                    print("Lỗi gọi API: $e");
                    Fluttertoast.showToast(
                      msg: "Lỗi mạng, vui lòng thử lại",
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
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
            ),
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
          } else if (tabValue == 'orders') {
            fetchOrderNotificationList().then((data) {
              setState(() {
                orderNotifications = data;
              });
            }).catchError((error) {
              print('Error loading order notifications: $error');
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

  Widget _buildNotificationItem(OrderNotification item) {
    final DateFormat formatter = DateFormat('HH:mm dd/MM/yyyy');

    return GestureDetector(
      onTap: () async {
        print("Tapped on notification");

        // Gọi API cập nhật trạng thái isRead
        await updateNotificationStatus(item.id);

        // Điều hướng đến chi tiết đơn hàng và chờ người dùng quay lại
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: item.bill.id),
          ),
        );

        // Sau khi quay về từ OrderDetailScreen, gọi lại fetch để làm mới danh sách
        // fetchOrderNotificationList(); // Gọi lại API để cập nhật UI
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F0FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 22,
                    color: Color(0xFF007AFF),
                  ),
                ),
                if (!item.isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.receipt_long,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        'Hóa đơn: ${item.bill.id}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        'Tổng tiền: ${item.bill.totalPrice.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter.format(item.createdAt),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
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
