/// 코스 완료 스탬프 모델
/// 포토카드별로 코스 스탬프를 관리
class CourseStamp {
  final String id;
  final String photoCardId; // 연결된 포토카드
  final String courseTitle; // 코스 제목
  final String province;
  final String city;
  final List<StopProgress> stopProgresses; // 각 정차지 진행상황
  final DateTime createdAt;
  final DateTime? completedAt; // 코스 완료 시간

  CourseStamp({
    required this.id,
    required this.photoCardId,
    required this.courseTitle,
    required this.province,
    required this.city,
    required this.stopProgresses,
    required this.createdAt,
    this.completedAt,
  });

  /// 코스 완료 여부 (모든 정차지 완료)
  bool get isCompleted => stopProgresses.every((s) => s.isCompleted);

  /// 완료된 정차지 수
  int get completedStopCount =>
      stopProgresses.where((s) => s.isCompleted).length;

  /// 전체 정차지 수
  int get totalStopCount => stopProgresses.length;

  /// 진행률 (0.0 ~ 1.0)
  double get progressRate =>
      totalStopCount > 0 ? completedStopCount / totalStopCount : 0.0;

  /// 진행률 퍼센트
  int get progressPercent => (progressRate * 100).round();

  CourseStamp copyWith({
    String? id,
    String? photoCardId,
    String? courseTitle,
    String? province,
    String? city,
    List<StopProgress>? stopProgresses,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return CourseStamp(
      id: id ?? this.id,
      photoCardId: photoCardId ?? this.photoCardId,
      courseTitle: courseTitle ?? this.courseTitle,
      province: province ?? this.province,
      city: city ?? this.city,
      stopProgresses: stopProgresses ?? this.stopProgresses,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photoCardId': photoCardId,
      'courseTitle': courseTitle,
      'province': province,
      'city': city,
      'stopProgresses': stopProgresses.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory CourseStamp.fromJson(Map<String, dynamic> json) {
    return CourseStamp(
      id: json['id'],
      photoCardId: json['photoCardId'],
      courseTitle: json['courseTitle'],
      province: json['province'],
      city: json['city'],
      stopProgresses: (json['stopProgresses'] as List<dynamic>)
          .map((s) => StopProgress.fromJson(s as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

/// 각 정차지 진행상황
class StopProgress {
  final int order;
  final String stopName;
  final String? category;
  final bool hasCoupon; // 쿠폰 받음
  final bool hasReview; // 리뷰 작성
  final DateTime? couponReceivedAt;
  final DateTime? reviewWrittenAt;

  StopProgress({
    required this.order,
    required this.stopName,
    this.category,
    this.hasCoupon = false,
    this.hasReview = false,
    this.couponReceivedAt,
    this.reviewWrittenAt,
  });

  /// 해당 정차지 완료 여부
  /// 관광지는 리뷰만 작성하면 완료
  /// 나머지는 쿠폰 + 리뷰 모두 필요
  bool get isCompleted {
    if (category == '관광지') {
      return hasReview;
    }
    return hasCoupon && hasReview;
  }

  StopProgress copyWith({
    int? order,
    String? stopName,
    String? category,
    bool? hasCoupon,
    bool? hasReview,
    DateTime? couponReceivedAt,
    DateTime? reviewWrittenAt,
  }) {
    return StopProgress(
      order: order ?? this.order,
      stopName: stopName ?? this.stopName,
      category: category ?? this.category,
      hasCoupon: hasCoupon ?? this.hasCoupon,
      hasReview: hasReview ?? this.hasReview,
      couponReceivedAt: couponReceivedAt ?? this.couponReceivedAt,
      reviewWrittenAt: reviewWrittenAt ?? this.reviewWrittenAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'stopName': stopName,
      'category': category,
      'hasCoupon': hasCoupon,
      'hasReview': hasReview,
      'couponReceivedAt': couponReceivedAt?.toIso8601String(),
      'reviewWrittenAt': reviewWrittenAt?.toIso8601String(),
    };
  }

  factory StopProgress.fromJson(Map<String, dynamic> json) {
    return StopProgress(
      order: json['order'],
      stopName: json['stopName'],
      category: json['category'],
      hasCoupon: json['hasCoupon'] ?? false,
      hasReview: json['hasReview'] ?? false,
      couponReceivedAt: json['couponReceivedAt'] != null
          ? DateTime.parse(json['couponReceivedAt'])
          : null,
      reviewWrittenAt: json['reviewWrittenAt'] != null
          ? DateTime.parse(json['reviewWrittenAt'])
          : null,
    );
  }
}
