import 'product.dart';

class Review {
  final String id;
  final Product product; // <-- thay vì String
  final String fullName;
  final String phoneNumber;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;

  Review({
    required this.id,
    required this.product,
    required this.fullName,
    required this.phoneNumber,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'],
      product: Product.fromJson(json['product']), // <-- gán product
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isRead: json['isRead'] ?? false,
    );
  }

   Review copyWith({bool? isRead}) {
    return Review(
      id: id,
      product: product,
      fullName: fullName,
      phoneNumber: phoneNumber,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
