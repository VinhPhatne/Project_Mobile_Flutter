import 'bill.dart';

class OrderNotification {
  final String id;
  final Bill bill;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  OrderNotification({
    required this.id,
    required this.bill,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory OrderNotification.fromJson(Map<String, dynamic> json) {
    return OrderNotification(
      id: json['_id'],
      bill: Bill.fromJson(json['billId']),
      message: json['message'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  OrderNotification copyWith({
    String? id,
    Bill? bill,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return OrderNotification(
      id: id ?? this.id,
      bill: bill ?? this.bill,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
