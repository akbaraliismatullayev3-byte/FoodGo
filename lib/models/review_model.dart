class Review {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String comment;
  final double rating;
  final DateTime date;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.comment,
    required this.rating,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'comment': comment,
      'rating': rating,
      'date': date.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userImageUrl: map['userImageUrl'] ?? '',
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
