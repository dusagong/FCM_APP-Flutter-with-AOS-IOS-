class Review {
  final String id;
  final String placeId;
  final String placeName;

  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final String? userId;
  final String? photoCardId;

  Review({
    required this.id,
    required this.placeId,
    required this.placeName,

    required this.content,
    required this.imageUrls,
    required this.createdAt,
    this.userId,
    this.photoCardId,
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
    String? photoCardId,
  }) {
    return Review(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      photoCardId: photoCardId ?? this.photoCardId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'place_name': placeName,
      'content': content,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'photo_card_id': photoCardId,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    // 서버 API (snake_case) 또는 로컬 (camelCase) 둘 다 지원
    return Review(
      id: json['id'] ?? '',
      placeId: json['place_id'] ?? json['placeId'] ?? '',
      placeName: json['place_name'] ?? json['placeName'] ?? '',
      content: json['content'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? json['imageUrls'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now()),
      userId: json['user_id'] ?? json['userId'],
      photoCardId: json['photo_card_id'] ?? json['photoCardId'],
    );
  }
}

/// 리뷰 목록 결과 (서버 API 응답용)
class ReviewListResult {
  final List<Review> reviews;
  final int totalCount;

  ReviewListResult({
    required this.reviews,
    required this.totalCount,
  });

  factory ReviewListResult.fromJson(Map<String, dynamic> json) {
    return ReviewListResult(
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
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
