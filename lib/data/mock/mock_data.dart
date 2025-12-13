// 테스트용 가상 데이터 - 나중에 삭제 예정

import '../../models/models.dart';

class MockData {
  // 강원특별자치도 강릉시 테스트 데이터
  static const String testProvince = '강원특별자치도';
  static const String testCity = '강릉시';

  static List<Place> getMockPlaces() {
    return [
      // 카페
      Place(
        id: 'mock_cafe_1',
        name: '안목해변 테라로사',
        category: PlaceCategory.cafe,
        description: '강릉 커피거리의 대표 카페, 바다를 보며 즐기는 스페셜티 커피',
        rating: 4.7,
        reviewCount: 1542,
        imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
        province: testProvince,
        city: testCity,
        couponDescription: '아메리카노 1+1',
        latitude: 37.7735,
        longitude: 128.9473,
      ),
      Place(
        id: 'mock_cafe_2',
        name: '보헤미안 커피',
        category: PlaceCategory.cafe,
        description: '강릉 커피 명가, 직접 로스팅한 신선한 원두',
        rating: 4.5,
        reviewCount: 876,
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
        province: testProvince,
        city: testCity,
        couponDescription: '음료 15% 할인',
        latitude: 37.7892,
        longitude: 128.9234,
      ),
      Place(
        id: 'mock_cafe_3',
        name: '산토리니 카페',
        category: PlaceCategory.cafe,
        description: '그리스 풍 인테리어와 오션뷰가 아름다운 카페',
        rating: 4.3,
        reviewCount: 654,
        imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400',
        province: testProvince,
        city: testCity,
        couponDescription: '디저트 세트 20% 할인',
        latitude: 37.7801,
        longitude: 128.9512,
      ),

      // 맛집
      Place(
        id: 'mock_restaurant_1',
        name: '초당순두부 본점',
        category: PlaceCategory.restaurant,
        description: '50년 전통 강릉 순두부의 원조',
        rating: 4.8,
        reviewCount: 2341,
        imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
        province: testProvince,
        city: testCity,
        couponDescription: '순두부정식 10% 할인',
        latitude: 37.8011,
        longitude: 128.9151,
      ),
      Place(
        id: 'mock_restaurant_2',
        name: '동화가든',
        category: PlaceCategory.restaurant,
        description: '강릉 대표 장칼국수 맛집, 직접 뽑은 면발',
        rating: 4.6,
        reviewCount: 1876,
        imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
        province: testProvince,
        city: testCity,
        couponDescription: '칼국수 주문시 만두 서비스',
        latitude: 37.7654,
        longitude: 128.8923,
      ),
      Place(
        id: 'mock_restaurant_3',
        name: '해변횟집',
        category: PlaceCategory.restaurant,
        description: '싱싱한 동해 활어회 전문점',
        rating: 4.4,
        reviewCount: 987,
        imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
        province: testProvince,
        city: testCity,
        couponDescription: '모듬회 15% 할인',
        latitude: 37.7723,
        longitude: 128.9567,
      ),

      // 관광
      Place(
        id: 'mock_tourism_1',
        name: '정동진 해돋이공원',
        category: PlaceCategory.tourism,
        description: '세계에서 바다와 가장 가까운 역, 일출 명소',
        rating: 4.9,
        reviewCount: 3254,
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        province: testProvince,
        city: testCity,
        latitude: 37.6902,
        longitude: 129.0345,
      ),
      Place(
        id: 'mock_tourism_2',
        name: '경포해변',
        category: PlaceCategory.tourism,
        description: '강릉을 대표하는 아름다운 백사장 해변',
        rating: 4.7,
        reviewCount: 4521,
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
        province: testProvince,
        city: testCity,
        latitude: 37.8056,
        longitude: 128.9089,
      ),
      Place(
        id: 'mock_tourism_3',
        name: '주문진항',
        category: PlaceCategory.tourism,
        description: '방파제 위 BTS 버스정류장으로 유명한 항구',
        rating: 4.5,
        reviewCount: 2187,
        imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
        province: testProvince,
        city: testCity,
        latitude: 37.8934,
        longitude: 128.8312,
      ),

      // 문화
      Place(
        id: 'mock_culture_1',
        name: '오죽헌',
        category: PlaceCategory.culture,
        description: '율곡 이이와 신사임당의 역사가 깃든 곳',
        rating: 4.6,
        reviewCount: 1876,
        imageUrl: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400',
        province: testProvince,
        city: testCity,
        latitude: 37.7785,
        longitude: 128.8767,
      ),
      Place(
        id: 'mock_culture_2',
        name: '강릉선교장',
        category: PlaceCategory.culture,
        description: '조선시대 사대부 가옥의 아름다움을 간직한 곳',
        rating: 4.5,
        reviewCount: 1234,
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
        province: testProvince,
        city: testCity,
        latitude: 37.8012,
        longitude: 128.8654,
      ),
      Place(
        id: 'mock_culture_3',
        name: '하슬라아트월드',
        category: PlaceCategory.culture,
        description: '바다와 예술이 어우러진 야외 조각 공원',
        rating: 4.4,
        reviewCount: 1567,
        imageUrl: 'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=400',
        province: testProvince,
        city: testCity,
        latitude: 37.7123,
        longitude: 129.0123,
      ),
    ];
  }

  static List<PhotoCard> getMockPhotoCards() {
    return [
      PhotoCard(
        id: 'mock_photocard_1',
        message: '강릉에서의 특별한 하루',
        hashtags: ['강릉여행', '커피거리', '바다'],
        province: testProvince,
        city: testCity,
        aiQuote: '사랑하는 사람과 함께하는 모든 순간이 기적이 됩니다',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
    ];
  }

  static List<Review> getMockReviews() {
    return [
      Review(
        id: 'mock_review_1',
        placeId: 'mock_cafe_1',
        placeName: '안목해변 테라로사',
        rating: 5,
        content: '바다를 보면서 마시는 커피가 정말 좋았어요! 연인과 함께 오기 딱 좋은 분위기입니다.',
        imageUrls: [
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Review(
        id: 'mock_review_2',
        placeId: 'mock_restaurant_1',
        placeName: '초당순두부 본점',
        rating: 5,
        content: '순두부가 정말 부드럽고 맛있었어요. 양도 많고 가성비 최고!',
        imageUrls: [
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: 'mock_review_3',
        placeId: 'mock_tourism_1',
        placeName: '정동진 해돋이공원',
        rating: 5,
        content: '새벽에 일어나서 본 일출이 정말 감동적이었어요. 커플 여행으로 강추합니다!',
        imageUrls: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
