/// 여행 추천 API 응답 모델
/// travel-server /api/v1/ask 엔드포인트용

/// 리스트 뷰용 - 지도 연동 가능한 장소 정보
class SpotWithLocation {
  final String name;
  final String? address;
  final String? category;
  final String? imageUrl;
  final String? mapx; // 경도 (지도 API용)
  final String? mapy; // 위도 (지도 API용)
  final String? tel;
  final String? contentId; // 상세정보 조회용

  SpotWithLocation({
    required this.name,
    this.address,
    this.category,
    this.imageUrl,
    this.mapx,
    this.mapy,
    this.tel,
    this.contentId,
  });

  factory SpotWithLocation.fromJson(Map<String, dynamic> json) {
    return SpotWithLocation(
      name: json['name'] ?? '',
      address: json['address'],
      category: json['category'],
      imageUrl: json['image_url'],
      mapx: json['mapx'],
      mapy: json['mapy'],
      tel: json['tel'],
      contentId: json['content_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'category': category,
      'image_url': imageUrl,
      'mapx': mapx,
      'mapy': mapy,
      'tel': tel,
      'content_id': contentId,
    };
  }

  /// 위도 (double 변환)
  double? get latitude => mapy != null ? double.tryParse(mapy!) : null;

  /// 경도 (double 변환)
  double? get longitude => mapx != null ? double.tryParse(mapx!) : null;

  /// 좌표 유효 여부
  bool get hasLocation => latitude != null && longitude != null;
}

/// 코스 뷰용 - 동선이 정리된 각 정차지
class CourseStop {
  final int order;
  final String name;
  final String? address;
  final String? mapx;
  final String? mapy;
  final String? contentId;
  final String? category;
  final String? time; // "오전 10시"
  final String? duration; // "1시간"
  final String? reason; // 커플에게 추천하는 이유
  final String? tip; // 방문 팁

  CourseStop({
    required this.order,
    required this.name,
    this.address,
    this.mapx,
    this.mapy,
    this.contentId,
    this.category,
    this.time,
    this.duration,
    this.reason,
    this.tip,
  });

  factory CourseStop.fromJson(Map<String, dynamic> json) {
    return CourseStop(
      order: json['order'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
      mapx: json['mapx'],
      mapy: json['mapy'],
      contentId: json['content_id'],
      category: json['category'],
      time: json['time'],
      duration: json['duration'],
      reason: json['reason'],
      tip: json['tip'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'name': name,
      'address': address,
      'mapx': mapx,
      'mapy': mapy,
      'content_id': contentId,
      'category': category,
      'time': time,
      'duration': duration,
      'reason': reason,
      'tip': tip,
    };
  }

  /// 위도 (double 변환)
  double? get latitude => mapy != null ? double.tryParse(mapy!) : null;

  /// 경도 (double 변환)
  double? get longitude => mapx != null ? double.tryParse(mapx!) : null;

  /// 좌표 유효 여부
  bool get hasLocation => latitude != null && longitude != null;
}

/// 코스 뷰용 - LLM이 큐레이션한 전체 코스
class RecommendedCourse {
  final String title;
  final List<CourseStop> stops;
  final String? totalDuration;
  final String? summary;

  RecommendedCourse({
    required this.title,
    required this.stops,
    this.totalDuration,
    this.summary,
  });

  factory RecommendedCourse.fromJson(Map<String, dynamic> json) {
    return RecommendedCourse(
      title: json['title'] ?? '추천 여행 코스',
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => CourseStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalDuration: json['total_duration'],
      summary: json['summary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'stops': stops.map((e) => e.toJson()).toList(),
      'total_duration': totalDuration,
      'summary': summary,
    };
  }
}

/// /api/v1/ask 응답 전체 모델
class RecommendationResponse {
  final bool success;
  final String query;
  final String? areaCode;
  final String? sigunguCode;
  final List<SpotWithLocation> spots; // 리스트 뷰용
  final RecommendedCourse? course; // 코스 뷰용
  final String message;

  RecommendationResponse({
    required this.success,
    required this.query,
    this.areaCode,
    this.sigunguCode,
    required this.spots,
    this.course,
    required this.message,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      success: json['success'] ?? false,
      query: json['query'] ?? '',
      areaCode: json['area_code'],
      sigunguCode: json['sigungu_code'],
      spots: (json['spots'] as List<dynamic>?)
              ?.map((e) => SpotWithLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      course: json['course'] != null
          ? RecommendedCourse.fromJson(json['course'] as Map<String, dynamic>)
          : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'query': query,
      'area_code': areaCode,
      'sigungu_code': sigunguCode,
      'spots': spots.map((e) => e.toJson()).toList(),
      'course': course?.toJson(),
      'message': message,
    };
  }

  /// 추천 성공 여부
  bool get hasResults => spots.isNotEmpty || course != null;

  /// 지도에 표시할 좌표가 있는 장소만 필터링
  List<SpotWithLocation> get spotsWithLocation =>
      spots.where((s) => s.hasLocation).toList();
}
