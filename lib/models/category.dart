class Category {

  final String id;
  final String title;
  final String imageUrl;
  final int preference;

  const Category({this.id, this.title, this.imageUrl, this.preference});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json['_id'],
        title: json['title'],
        imageUrl: json['imageUrl'],
        preference: json['preference']
    );
  }
}