class CollectionModel {
  final String id;
  final String title;
  final String titleJP;
  final String coverUrl;
  final String emoji;
  final int price; // VNĐ, 0 = miễn phí
  final bool isUnlocked;

  const CollectionModel({
    required this.id,
    required this.title,
    required this.titleJP,
    required this.coverUrl,
    required this.emoji,
    required this.price,
    this.isUnlocked = false,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleJP: json['titleJP'] as String,
      coverUrl: json['coverUrl'] as String,
      emoji: json['emoji'] as String,
      price: json['price'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  CollectionModel copyWith({bool? isUnlocked}) {
    return CollectionModel(
      id: id,
      title: title,
      titleJP: titleJP,
      coverUrl: coverUrl,
      emoji: emoji,
      price: price,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}