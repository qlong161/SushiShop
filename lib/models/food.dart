class Food {
  final String? id;
  final String name;
  final String price;
  final String imagePath;
  final String rating;
  final String description;

  Food({
    this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.rating,
    required this.description,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      price: map['price']?.toString() ?? '0.00',
      imagePath: map['imagePath'] ?? '',
      rating: map['rating']?.toString() ?? '0.0',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'rating': rating,
      'description': description,
    };
  }
}
