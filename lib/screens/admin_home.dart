import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Xóa token
    Navigator.pushReplacementNamed(context, '/login'); // Chuyển về LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: Colors.red, // Màu đỏ giống phong cách KFC
        title: Text(
          'Quản lý cửa hàng',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/notification');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Card: Quản lý đơn hàng
            _buildManagementCard(
              context: context,
              title: 'Quản lý đơn hàng',
              description: 'Xem và xử lý các đơn hàng từ khách hàng.',
              icon: Icons.fastfood,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chuyển đến Quản lý đơn hàng')),
                );
              },
            ),
            SizedBox(height: 16),
            // Card: Quản lý sản phẩm
            _buildManagementCard(
              context: context,
              title: 'Quản lý sản phẩm',
              description: 'Thêm, sửa, xóa các món ăn trong menu.',
              icon: Icons.menu_book,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chuyển đến Quản lý sản phẩm')),
                );
              },
            ),
            SizedBox(height: 16),
            // Card: Quản lý nhân viên
            _buildManagementCard(
              context: context,
              title: 'Quản lý nhân viên',
              description: 'Quản lý thông tin và lịch làm việc của nhân viên.',
              icon: Icons.people,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chuyển đến Quản lý nhân viên')),
                );
              },
            ),
            SizedBox(height: 16),
            // Card: Quản lý doanh thu
            _buildManagementCard(
              context: context,
              title: 'Quản lý doanh thu',
              description: 'Xem báo cáo doanh thu và lợi nhuận.',
              icon: Icons.attach_money,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chuyển đến Quản lý doanh thu')),
                );
              },
            ),
            SizedBox(height: 16),
            // Nút đăng xuất
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: 0, // Mặc định chọn tab Trang chủ
        onTap: (index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chuyển đến tab $index')),
          );
        },
      ),
    );
  }

  // Hàm tạo card cho các chức năng quản lý
  Widget _buildManagementCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.red, // Màu đỏ giống phong cách KFC
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
