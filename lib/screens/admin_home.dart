import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import màn hình thông báo

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: Colors.red, // Màu đỏ giống phong cách KFC
        title: Text(
          'Quản lý cửa hàng KFC',
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
              // Chuyển hướng đến màn hình thông báo
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
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
                // Placeholder: Chuyển đến màn hình quản lý đơn hàng
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
                // Placeholder: Chuyển đến màn hình quản lý sản phẩm
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
                // Placeholder: Chuyển đến màn hình quản lý nhân viên
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
                // Placeholder: Chuyển đến màn hình quản lý doanh thu
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chuyển đến Quản lý doanh thu')),
                );
              },
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
          // Placeholder: Xử lý khi nhấn vào các tab
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
