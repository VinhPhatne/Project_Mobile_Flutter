import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OrderDetailScreen(
          orderId: '6768cff29bdb826320f612a1'), // Replace with actual orderId
    );
  }
}

class Stage {
  final String label;
  final int state;

  Stage({required this.label, required this.state});
}

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? order;
  bool isLoading = true;
  String? error;

  late IO.Socket socket;
  String orderStatus = "Chưa thanh toán"; // Initial status
  int currentState = 0;

  @override
  void initState() {
    super.initState();

    socket = IO.io(
      'http://localhost:8080',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    // Connect the socket
    socket.connect();

    socket.on('order_status_updated', (data) {
      if (!mounted) return;
      setState(() {
        order?['state'] = data['newState']; // ← CẬP NHẬT LẠI STATE TRONG ORDER
        orderStatus = data['newState'].toString();
        currentState = int.tryParse(orderStatus) ?? 0;
      });

      Fluttertoast.showToast(
        msg: "Trạng thái đơn hàng đã được cập nhật thành công!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });

    // Fetch order details
    fetchOrder();
  }

  @override
  void dispose() {
    // Disconnect the socket when the widget is disposed
    socket.disconnect();
    super.dispose();
  }

  void updateOrderStatus(String orderId) {
    int newState = currentState + 1;

    final payload = {
      'billId': orderId,
      'state': newState,
    };

    socket.emit('updateOrderStatus', payload);
  }

  void cancelOrder(String orderId) {
    final payload = {
      'billId': orderId,
      'state': -1, // Trạng thái hủy đơn
    };

    socket.emit('updateOrderStatus', payload);
  }

  Future<void> fetchOrder() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/v1/bill/get/${widget.orderId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];

        setState(() {
          order = data;
          orderStatus = data['state'].toString(); // để hiển thị
          currentState = data['state'] is int
              ? data['state']
              : int.tryParse(data['state']) ?? 0; // để dùng logic
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load order');
      }
    } catch (err) {
      setState(() {
        error = 'Lỗi khi tải hóa đơn. Vui lòng thử lại!';
        isLoading = false;
      });
      print('Lỗi khi tải hóa đơn: $err');
    }
  }

  Widget getOrderStatusLine(int state) {
    if (state == -1) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        alignment: Alignment.center,
        child: Text(
          'Đơn hàng đã bị hủy',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final stages = [
      Stage(label: 'Đang xử lí', state: 1),
      Stage(label: 'Đang thực hiện', state: 2),
      Stage(label: 'Đang giao hàng', state: 3),
      Stage(label: 'Hoàn thành', state: 4),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final circleRadius = 10.0;
          final lineSegmentWidth =
              (totalWidth - (stages.length * circleRadius * 2)) /
                  (stages.length - 1);

          if (lineSegmentWidth <= 0) {
            return SizedBox.shrink();
          }

          return Column(
            children: [
              CustomPaint(
                size: Size(totalWidth, circleRadius * 2),
                painter: StatusLinePainter(
                  stages: stages,
                  state: state,
                  lineSegmentWidth: lineSegmentWidth,
                  circleRadius: circleRadius,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: stages.map((stage) {
                  bool isCompleted = state >= stage.state;
                  return SizedBox(
                    width: totalWidth / stages.length,
                    child: Text(
                      stage.label,
                      style: TextStyle(
                        color: isCompleted ? Color(0xFF00B894) : Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  void handleReorder() {
    if (order != null && order!['lineItem'] != null) {
      for (var item in order!['lineItem']) {
        List<Map<String, dynamic>> formattedOptions = [];
        if (item['options'] != null) {
          formattedOptions = (item['options'] as List).map((option) {
            return {
              'optionId': option['option']['_id'],
              'choiceId': option['choices']['_id'],
              'addPrice': option['choices']['additionalPrice'] ?? 0,
            };
          }).toList();
        }

        final productData = {
          '_id': item['product']['_id'],
          'name': item['product']['name'],
          'price': item['product']['currentPrice'],
          'picture': item['product']['picture'],
          'options': formattedOptions,
        };

        print('Adding to cart: $productData, Quantity: ${item['quantity']}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đã thêm ${order!['lineItem'].length} sản phẩm vào giỏ hàng!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF3498DB)),
              SizedBox(height: 8),
              Text(
                'Đang tải đơn hàng...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            error!,
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (order == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Không tìm thấy đơn hàng!',
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin đơn hàng',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text('👤 ${order!['fullName']}',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    Text('📞 ${order!['phone_shipment']}',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    Text(
                      '🚚 Phí vận chuyển: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(order!['ship'])}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Text(
                      '🎟 Voucher: ${order!['voucher'] != null ? order!['voucher']['code'] : 'Không có'} - ${order!['voucher'] != null ? NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(order!['voucher']['discount']) : '0đ'}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Text(
                      '💎 Điểm giảm giá: -${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(order!['pointDiscount'])}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Text(
                      '💳 Trạng thái: ${order!['isPaid'] ? '✅ Đã thanh toán' : '❌ Chưa thanh toán'}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Text(
                      '📌 Trạng thái giao hàng:',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    getOrderStatusLine(order!['state']),

                    // Thêm Row chứa 2 button
                    SizedBox(
                        height:
                            16), // Khoảng cách giữa trạng thái giao hàng và các nút
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: (currentState == 4 || currentState == -1)
                              ? null // Vô hiệu hóa nếu state là 4 hoặc -1
                              : () {
                                  updateOrderStatus(widget
                                      .orderId); // Gọi cập nhật trạng thái
                                },
                          child: Text('Cập nhật'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.grey, // Màu khi bị vô hiệu hóa
                            disabledForegroundColor: Colors.white70,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (order?['state'] == 4 ||
                                  order?['state'] == -1)
                              ? null // Vô hiệu hóa nếu state là 4 hoặc -1
                              : () {
                                  cancelOrder(widget.orderId); // Gọi huỷ đơn
                                },
                          child: Text('Hủy đơn'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )),
          ...(order!['lineItem'] as List).map((item) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item['product']['picture'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['product']['name'],
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          Text(
                            '🔢 Số lượng: ${item['quantity']}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            '💵 Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item['product']['currentPrice'])}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            '🛒 Thành tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item['subtotal'])}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          if (item['options'] != null &&
                              (item['options'] as List).isNotEmpty) ...[
                            Text(
                              '🎯 Tùy chọn:',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            ...(item['options'] as List).map((opt) {
                              return Text(
                                '- ${opt['option']['name']}: ${opt['choices']['name']} (+${opt['choices']['additionalPrice']}đ)',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '💰 Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(order!['total_price'])}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
            ),
          ),
          // ElevatedButton(
          //   onPressed: handleReorder,
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Color(0xFFFF6B6B),
          //     padding: EdgeInsets.symmetric(vertical: 20),
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10)),
          //   ),
          //   child: Text(
          //     'Đặt lại',
          //     style: TextStyle(
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.white),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class StatusLinePainter extends CustomPainter {
  final List<Stage> stages;
  final int state;
  final double lineSegmentWidth;
  final double circleRadius;

  StatusLinePainter({
    required this.stages,
    required this.state,
    required this.lineSegmentWidth,
    required this.circleRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Paint circlePaint = Paint()..style = PaintingStyle.fill;

    final Paint circleBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final isCompleted = state >= stage.state;
      final xPosition =
          i * (lineSegmentWidth + circleRadius * 2) + circleRadius;

      if (i < stages.length - 1) {
        linePaint.color = state > stage.state ? Color(0xFF00B894) : Colors.grey;
        final startX = xPosition + circleRadius;
        final endX = startX + lineSegmentWidth;
        canvas.drawLine(
          Offset(startX, circleRadius),
          Offset(endX, circleRadius),
          linePaint,
        );
      }

      // Draw the circle
      circlePaint.color = isCompleted ? Color(0xFF00B894) : Colors.white;
      circleBorderPaint.color = isCompleted ? Color(0xFF00B894) : Colors.grey;
      canvas.drawCircle(
        Offset(xPosition, circleRadius),
        circleRadius,
        circlePaint,
      );
      canvas.drawCircle(
        Offset(xPosition, circleRadius),
        circleRadius,
        circleBorderPaint,
      );

      if (isCompleted) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '✓',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(xPosition - textPainter.width / 2,
              circleRadius - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
