class Bill {
  final String id;
  final int ship;
  final int totalPrice;
  final int? pointDiscount;
  final int state;
  final String fullName;
  final String addressShipment;
  final String phoneShipment;
  final bool isPaid;
  final List<String> lineItem;
  final String? note;
  final String? voucher;
  final String? account;
  final DateTime createdAt;

  Bill({
    required this.id,
    required this.ship,
    required this.totalPrice,
    required this.pointDiscount,
    required this.state,
    required this.fullName,
    required this.addressShipment,
    required this.phoneShipment,
    required this.isPaid,
    required this.lineItem,
    required this.voucher,
    required this.note,
    required this.account,
    required this.createdAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['_id'],
      ship: json['ship'],
      totalPrice: json['total_price'],
      pointDiscount: json['pointDiscount'] ?? 0,
      state: json['state'],
      fullName: json['fullName'],
      addressShipment: json['address_shipment'],
      phoneShipment: json['phone_shipment'],
      isPaid: json['isPaid'],
      lineItem: List<String>.from(json['lineItem'] ?? []),
      voucher: json['voucher'],
      note: json['note'],
      account: json['account'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
