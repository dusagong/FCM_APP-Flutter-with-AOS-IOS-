enum PlaceCategory {
  cafe,
  restaurant,
  tourism,
  culture,
}

extension PlaceCategoryExtension on PlaceCategory {
  String get label {
    switch (this) {
      case PlaceCategory.cafe:
        return '카페';
      case PlaceCategory.restaurant:
        return '맛집';
      case PlaceCategory.tourism:
        return '관광';
      case PlaceCategory.culture:
        return '문화';
    }
  }

  String get emoji {
    switch (this) {
      case PlaceCategory.cafe:
        return '☕';
      case PlaceCategory.restaurant:
        return '🍽️';
      case PlaceCategory.tourism:
        return '🏞️';
      case PlaceCategory.culture:
        return '🏛️';
    }
  }

  bool get hasCoupon {
    return this == PlaceCategory.cafe || this == PlaceCategory.restaurant;
  }
}

class Place {
  final String id;
  final String name;
  final PlaceCategory category;
  final String description;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String province;
  final String city;
  final String? couponDescription;
  final double? latitude;
  final double? longitude;

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.province,
    required this.city,
    this.couponDescription,
    this.latitude,
    this.longitude,
  });

  String get location => '$province $city';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'description': description,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'province': province,
      'city': city,
      'couponDescription': couponDescription,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      category: PlaceCategory.values[json['category']],
      description: json['description'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      imageUrl: json['imageUrl'],
      province: json['province'],
      city: json['city'],
      couponDescription: json['couponDescription'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

// 시간대별 코스
enum TimeSlot {
  morning,
  lunch,
  afternoon,
  evening,
}

extension TimeSlotExtension on TimeSlot {
  String get label {
    switch (this) {
      case TimeSlot.morning:
        return '오전';
      case TimeSlot.lunch:
        return '점심';
      case TimeSlot.afternoon:
        return '오후';
      case TimeSlot.evening:
        return '저녁';
    }
  }

  String get timeRange {
    switch (this) {
      case TimeSlot.morning:
        return '09:00 - 12:00';
      case TimeSlot.lunch:
        return '12:00 - 15:00';
      case TimeSlot.afternoon:
        return '15:00 - 18:00';
      case TimeSlot.evening:
        return '18:00 - 21:00';
    }
  }

  String get emoji {
    switch (this) {
      case TimeSlot.morning:
        return '☀️';
      case TimeSlot.lunch:
        return '🌤️';
      case TimeSlot.afternoon:
        return '⛅';
      case TimeSlot.evening:
        return '🌙';
    }
  }

  String get title {
    switch (this) {
      case TimeSlot.morning:
        return '상쾌한 아침 코스';
      case TimeSlot.lunch:
        return '맛있는 점심 코스';
      case TimeSlot.afternoon:
        return '여유로운 오후 코스';
      case TimeSlot.evening:
        return '로맨틱한 저녁 코스';
    }
  }

  String get description {
    switch (this) {
      case TimeSlot.morning:
        return '아침 일찍 시작하는 활기찬 데이트';
      case TimeSlot.lunch:
        return '맛집 탐방과 문화 체험';
      case TimeSlot.afternoon:
        return '카페에서의 휴식과 산책';
      case TimeSlot.evening:
        return '맛있는 저녁 식사와 야경 감상';
    }
  }

  List<PlaceCategory> get recommendedCategories {
    switch (this) {
      case TimeSlot.morning:
        return [PlaceCategory.tourism, PlaceCategory.cafe];
      case TimeSlot.lunch:
        return [PlaceCategory.restaurant, PlaceCategory.tourism];
      case TimeSlot.afternoon:
        return [PlaceCategory.cafe, PlaceCategory.tourism];
      case TimeSlot.evening:
        return [PlaceCategory.restaurant, PlaceCategory.tourism];
    }
  }
}

class Course {
  final TimeSlot timeSlot;
  final List<Place> places;
  final int estimatedMinutes;

  Course({
    required this.timeSlot,
    required this.places,
    required this.estimatedMinutes,
  });

  String get estimatedTime {
    final hours = estimatedMinutes ~/ 60;
    final minutes = estimatedMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '약 $hours시간 $minutes분';
    } else if (hours > 0) {
      return '약 $hours시간';
    } else {
      return '약 $minutes분';
    }
  }
}
