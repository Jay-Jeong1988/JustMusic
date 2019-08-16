import 'dart:convert';

class Category {

  final String id;
  final String title;
  final String imageUrl;

  const Category({this.id, this.title, this.imageUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json['_id'],
        title: json['title'],
        imageUrl: json['imageUrl'],
    );
  }

  static toJson(Category category) {
    dynamic categoryMap = {};
    categoryMap['_id'] = category.id;
    categoryMap['title'] = category.title;
    categoryMap['imageUrl'] = category.imageUrl;
    return categoryMap;
  }

}