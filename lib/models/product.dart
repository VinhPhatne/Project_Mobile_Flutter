class Product {
  final String id;
  final String name;
  final String picture;
  final String description;
  final int price;
  final int currentPrice;

  Product({
    required this.id,
    required this.name,
    required this.picture,
    required this.description,
    required this.price,
    required this.currentPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      picture: json['picture'],
      description: json['description'],
      price: json['price'],
      currentPrice: json['currentPrice'],
    );
  }
}
