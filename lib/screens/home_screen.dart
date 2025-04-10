import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  String activeTab = "orders"; // "orders" hoặc "reviews"

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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
  int get unreadReviewsCount => mockReviewNotifications
      .where((notification) => !notification.read)
      .length;

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
                            color: Colors.black,
                            size: 24), // Đổi màu icon để dễ nhìn
                        onPressed: _logout,
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
                    itemCount: notifications.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
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
                      final notification = notifications[index - 1];
                      return _buildNotificationItem(notification);
                    },
                  ),
                ),
              ],
            ),

            // Fixed "Đánh dấu đã đọc" Button
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: ElevatedButton(
                onPressed: () {},
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
                        color: Colors
                            .white, // Giữ màu trắng để tương phản với nền nút
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
                color:
                    isActive ? Color(0xFF007AFF) : Colors.black, // Đổi màu icon
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
    print('Rendering notification: ${item.title}'); // Debug để kiểm tra render
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFeee), width: 1),
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
}
