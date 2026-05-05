class ExtraContent {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String type; // 'news' or 'blog'
  final DateTime date;

  ExtraContent({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  factory ExtraContent.fromMap(Map<String, dynamic> map, String id) {
    return ExtraContent(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? 'news',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
