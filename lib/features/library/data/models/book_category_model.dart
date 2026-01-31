// book_category_model.dart
class BookCategory {
  final String id;
  final String name;
  final String color;

  BookCategory({
    required this.id,
    required this.name,
    required this.color,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['_id'],
      name: json['name'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'color': color,
    };
  }
}