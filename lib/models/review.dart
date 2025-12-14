class Review {
  final String id;
  final String placeId;
  final String placeName;

  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final String? userId;

  Review({
    required this.id,
    required this.placeId,
    required this.placeName,

    required this.content,
    required this.imageUrls,
    required this.createdAt,
    this.userId,
  });

  String get formattedDate {
    return '${createdAt.year}년 ${createdAt.month}월 ${createdAt.day}일';
  }

  Review copyWith({
    String? id,
    String? placeId,
    String? placeName,

    String? content,
    List<String>? imageUrls,
    DateTime? createdAt,
    String? userId,
  }) {
    return Review(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,

      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'placeName': placeName,

      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      placeId: json['placeId'],
      placeName: json['placeName'],

      content: json['content'],
      imageUrls: List<String>.from(json['imageUrls']),
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
    );
  }
}

// 리뷰 작성 가능한 장소 (쿠폰 사용 후 미리뷰 장소)
class ReviewablePlace {
  final String placeId;
  final String placeName;
  final DateTime visitedAt;
  final bool hasReviewed;

  ReviewablePlace({
    required this.placeId,
    required this.placeName,
    required this.visitedAt,
    this.hasReviewed = false,
  });

  String get formattedVisitDate {
    return '${visitedAt.year}년 ${visitedAt.month}월 ${visitedAt.day}일';
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'placeName': placeName,
      'visitedAt': visitedAt.toIso8601String(),
      'hasReviewed': hasReviewed,
    };
  }

  factory ReviewablePlace.fromJson(Map<String, dynamic> json) {
    return ReviewablePlace(
      placeId: json['placeId'],
      placeName: json['placeName'],
      visitedAt: DateTime.parse(json['visitedAt']),
      hasReviewed: json['hasReviewed'] ?? false,
    );
  }
}
