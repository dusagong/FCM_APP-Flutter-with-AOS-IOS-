import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/travel_api_service.dart';
import '../services/photo_card_storage_service.dart';

class AppProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  // Photo Cards
  List<PhotoCard> _photoCards = [];
  PhotoCard? _currentPhotoCard;

  // Places
  List<Place> _places = [];

  // Coupons
  final List<Coupon> _coupons = [];

  // Reviews
  List<Review> _reviews = [];
  final List<ReviewablePlace> _reviewablePlaces = [];

  // Current destination (from PhotoCard)
  String? _currentProvince;
  String? _currentCity;

  // Getters
  List<PhotoCard> get photoCards => _photoCards;
  PhotoCard? get currentPhotoCard => _currentPhotoCard;
  List<Place> get places => _places;
  List<Coupon> get coupons => _coupons;
  List<Coupon> get unusedCoupons => _coupons.where((c) => !c.isUsed).toList();
  List<Coupon> get usedCoupons => _coupons.where((c) => c.isUsed).toList();
  List<Review> get reviews => _reviews;
  List<Review> get myReviews => _reviews;
  List<ReviewablePlace> get reviewablePlaces =>
      _reviewablePlaces.where((r) => !r.hasReviewed).toList();
  String? get currentProvince => _currentProvince;
  String? get currentCity => _currentCity;

  // Stats
  int get photoCardCount => _photoCards.length;
  int get couponCount => _coupons.length;
  int get reviewCount => _reviews.length;

  AppProvider() {
    _initSampleData();
    _loadPhotoCardsFromStorage();
  }

  /// SharedPreferences에서 PhotoCard 로드
  Future<void> _loadPhotoCardsFromStorage() async {
    try {
      final storedCards = await PhotoCardStorageService.getAllPhotoCards();
      if (storedCards.isNotEmpty) {
        _photoCards = storedCards;

        // 현재 PhotoCard 설정
        final currentCard = await PhotoCardStorageService.getCurrentPhotoCard();
        if (currentCard != null) {
          _currentPhotoCard = currentCard;
          _currentProvince = currentCard.province;
          _currentCity = currentCard.city;
        }

        notifyListeners();
      }
    } catch (e) {
      print('PhotoCard 로드 에러: $e');
    }
  }

  void _initSampleData() {
    // Sample Photo Cards
    _photoCards = [
      PhotoCard(
        id: _uuid.v4(),
        message: '강릉에서의 특별한 하루',
        hashtags: ['맛집탐방', '카페투어', '해변산책'],
        province: '강원도',
        city: '강릉시',
        aiQuote: '사랑하는 사람과 함께하는 모든 순간이 기적이 됩니다',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isDefault: true,
      ),
      PhotoCard(
        id: _uuid.v4(),
        message: '부산 바다 여행',
        hashtags: ['해운대', '광안리', '야경'],
        province: '부산광역시',
        city: '해운대구',
        aiQuote: '여행은 두 사람의 마음을 더욱 가까이 만들어줍니다',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isDefault: true,
      ),
      PhotoCard(
        id: _uuid.v4(),
        message: '역사와 문화의 도시',
        hashtags: ['역사탐방', '사찰', '문화재'],
        province: '경상북도',
        city: '경주시',
        aiQuote: '함께 걷는 모든 길이 특별한 추억이 됩니다',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isDefault: true,
      ),
    ];

    // Sample Places
    _places = [
      // 강릉
      Place(
        id: 'place_1',
        name: '안목해변 커피거리',
        category: PlaceCategory.cafe,
        description: '바다를 보며 즐기는 특별한 커피 한 잔',
        rating: 4.5,
        reviewCount: 328,
        imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
        province: '강원도',
        city: '강릉시',
        couponDescription: '아메리카노 1+1',
        latitude: 37.7735,
        longitude: 128.9473,
      ),
      Place(
        id: 'place_2',
        name: '초당순두부마을',
        category: PlaceCategory.restaurant,
        description: '강릉의 명물, 부드러운 순두부의 진수',
        rating: 4.7,
        reviewCount: 542,
        imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
        province: '강원도',
        city: '강릉시',
        couponDescription: '순두부 10% 할인',
        latitude: 37.8011,
        longitude: 128.9151,
      ),
      Place(
        id: 'place_3',
        name: '정동진 해돋이',
        category: PlaceCategory.tourism,
        description: '세계에서 가장 아름다운 일출 명소',
        rating: 4.8,
        reviewCount: 892,
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        province: '강원도',
        city: '강릉시',
        latitude: 37.6902,
        longitude: 129.0345,
      ),
      Place(
        id: 'place_4',
        name: '오죽헌',
        category: PlaceCategory.culture,
        description: '율곡 이이와 신사임당의 역사가 깃든 곳',
        rating: 4.4,
        reviewCount: 267,
        imageUrl: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400',
        province: '강원도',
        city: '강릉시',
        latitude: 37.7785,
        longitude: 128.8767,
      ),
      // 부산
      Place(
        id: 'place_5',
        name: '해운대 해수욕장',
        category: PlaceCategory.tourism,
        description: '대한민국 대표 해변, 끝없이 펼쳐진 백사장',
        rating: 4.6,
        reviewCount: 1247,
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
        province: '부산광역시',
        city: '해운대구',
        latitude: 35.1587,
        longitude: 129.1604,
      ),
      Place(
        id: 'place_6',
        name: '광안리 횟집',
        category: PlaceCategory.restaurant,
        description: '신선한 회와 함께 광안대교 야경을',
        rating: 4.5,
        reviewCount: 678,
        imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
        province: '부산광역시',
        city: '수영구',
        couponDescription: '모듬회 15% 할인',
        latitude: 35.1531,
        longitude: 129.1186,
      ),
      // 경주
      Place(
        id: 'place_7',
        name: '불국사',
        category: PlaceCategory.culture,
        description: '유네스코 세계문화유산, 천년의 아름다움',
        rating: 4.9,
        reviewCount: 1532,
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
        province: '경상북도',
        city: '경주시',
        latitude: 35.7905,
        longitude: 129.3316,
      ),
      // 전주
      Place(
        id: 'place_8',
        name: '한옥마을 전통찻집',
        category: PlaceCategory.cafe,
        description: '한옥의 정취와 함께하는 전통차 한 잔',
        rating: 4.6,
        reviewCount: 445,
        imageUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=400',
        province: '전라북도',
        city: '전주시',
        couponDescription: '전통차 세트 20% 할인',
        latitude: 35.8151,
        longitude: 127.1528,
      ),
    ];

    // Sample Reviews
    _reviews = [
      Review(
        id: _uuid.v4(),
        placeId: 'place_1',
        placeName: '안목해변 커피거리',
        rating: 5,
        content: '정말 좋은 카페였어요. 바다 뷰가 환상적이고 커피 맛도 훌륭했습니다. 분위기도 너무 로맨틱해서 커플들에게 강력 추천합니다!',
        imageUrls: [
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: _uuid.v4(),
        placeId: 'place_2',
        placeName: '초당순두부마을',
        rating: 5,
        content: '순두부가 정말 부드럽고 맛있었어요. 강릉 오면 꼭 다시 올 거예요!',
        imageUrls: [
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Review(
        id: _uuid.v4(),
        placeId: 'place_3',
        placeName: '정동진 해돋이',
        rating: 5,
        content: '새벽에 일어나서 본 일출이 정말 감동적이었습니다. 연인과 함께라면 더 특별한 추억이 될 거예요.',
        imageUrls: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=400',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    notifyListeners();
  }

  // Photo Card Methods

  /// PhotoCard 생성 (API 연동)
  /// 1. 서버에 PhotoCard 생성 요청
  /// 2. 서버에서 받은 ID로 PhotoCard 생성
  /// 3. SharedPreferences에 저장
  Future<PhotoCard> createPhotoCardWithAPI({
    required String province,
    required String city,
    required String message,
    required List<String> hashtags,
    required String aiQuote,
    String? imagePath,
  }) async {
    try {
      // 1. 서버에 PhotoCard 생성 요청
      final response = await TravelApiService.createPhotoCard(
        province: province,
        city: city,
        message: message,
        hashtags: hashtags,
        aiQuote: aiQuote,
        imagePath: imagePath,
      );

      // 2. 서버 응답으로 PhotoCard 객체 생성
      final photoCard = PhotoCard(
        id: response['id'],
        province: province,
        city: city,
        message: message,
        hashtags: hashtags,
        aiQuote: aiQuote,
        imagePath: imagePath,
        createdAt: DateTime.parse(response['created_at']),
        isDefault: false,
      );

      // 3. SharedPreferences에 저장
      await PhotoCardStorageService.savePhotoCard(photoCard);

      // 4. 메모리에 추가
      _photoCards.insert(0, photoCard);
      _currentPhotoCard = photoCard;
      _currentProvince = province;
      _currentCity = city;

      notifyListeners();
      return photoCard;
    } catch (e) {
      throw Exception('PhotoCard 생성 실패: $e');
    }
  }

  /// PhotoCard 추가 (로컬 전용 - 이전 버전 호환)
  void addPhotoCard(PhotoCard card) {
    _photoCards.insert(0, card);
    notifyListeners();
  }

  /// PhotoCard 삭제
  /// 1. 로컬 스토리지에서 삭제
  /// 2. 메모리에서 삭제
  /// 참고: 서버 비활성화는 별도 호출 필요 없음 (로컬 디바이스 기반)
  Future<void> deletePhotoCard(String photoCardId) async {
    try {
      // 1. 로컬 스토리지에서 삭제
      await PhotoCardStorageService.deletePhotoCard(photoCardId);

      // 2. 메모리에서 삭제
      _photoCards.removeWhere((card) => card.id == photoCardId);

      // 3. 현재 PhotoCard가 삭제된 경우 초기화
      if (_currentPhotoCard?.id == photoCardId) {
        _currentPhotoCard = null;
        _currentProvince = null;
        _currentCity = null;
      }

      notifyListeners();
    } catch (e) {
      throw Exception('PhotoCard 삭제 실패: $e');
    }
  }

  /// PhotoCard 검증 (만남승강장 접근 전)
  /// 서버에서 PhotoCard가 유효한지 확인
  Future<bool> verifyPhotoCard(String photoCardId) async {
    try {
      return await TravelApiService.verifyPhotoCard(photoCardId);
    } catch (e) {
      print('PhotoCard 검증 에러: $e');
      return false;
    }
  }

  void setCurrentPhotoCard(PhotoCard card) {
    _currentPhotoCard = card;
    _currentProvince = card.province;
    _currentCity = card.city;
    PhotoCardStorageService.setCurrentPhotoCard(card.id);
    notifyListeners();
  }

  void clearCurrentPhotoCard() {
    _currentPhotoCard = null;
    _currentProvince = null;
    _currentCity = null;
    notifyListeners();
  }

  // Place Methods
  List<Place> getPlacesByDestination(String province, String city) {
    return _places
        .where((p) => p.province == province || p.city == city)
        .toList();
  }

  List<Place> getPlacesByCategory(PlaceCategory category) {
    return _places.where((p) => p.category == category).toList();
  }

  Place? getPlaceById(String id) {
    try {
      return _places.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Course> generateCourses(String province, String city) {
    final destinationPlaces = getPlacesByDestination(province, city);
    if (destinationPlaces.isEmpty) {
      return [];
    }

    List<Course> courses = [];

    for (var timeSlot in TimeSlot.values) {
      List<Place> coursePlaces = [];

      for (var category in timeSlot.recommendedCategories) {
        final categoryPlaces = destinationPlaces
            .where((p) => p.category == category)
            .toList();
        if (categoryPlaces.isNotEmpty) {
          coursePlaces.add(categoryPlaces.first);
        }
      }

      if (coursePlaces.isNotEmpty) {
        courses.add(Course(
          timeSlot: timeSlot,
          places: coursePlaces,
          estimatedMinutes: coursePlaces.length * 90,
        ));
      }
    }

    return courses;
  }

  // Coupon Methods
  bool hasCoupon(String placeId) {
    return _coupons.any((c) => c.placeId == placeId && !c.isUsed);
  }

  void addCoupon(Place place) {
    if (hasCoupon(place.id)) return;

    final coupon = Coupon(
      id: _uuid.v4(),
      placeId: place.id,
      placeName: place.name,
      description: place.couponDescription ?? '',
      province: place.province,
      city: place.city,
      receivedAt: DateTime.now(),
    );

    _coupons.add(coupon);
    notifyListeners();
  }

  bool useCoupon(String couponId, String pin) {
    // Prototype PIN: 1234
    if (pin != '1234') return false;

    final index = _coupons.indexWhere((c) => c.id == couponId);
    if (index == -1) return false;

    final coupon = _coupons[index];
    _coupons[index] = coupon.copyWith(
      isUsed: true,
      usedAt: DateTime.now(),
    );

    // Add to reviewable places
    _reviewablePlaces.add(ReviewablePlace(
      placeId: coupon.placeId,
      placeName: coupon.placeName,
      visitedAt: DateTime.now(),
    ));

    notifyListeners();
    return true;
  }

  // Review Methods
  List<Review> getReviewsByPlace(String placeId) {
    return _reviews.where((r) => r.placeId == placeId).toList();
  }

  double getAverageRating(String placeId) {
    final placeReviews = getReviewsByPlace(placeId);
    if (placeReviews.isEmpty) return 0;

    final sum = placeReviews.fold<int>(0, (sum, r) => sum + r.rating);
    return sum / placeReviews.length;
  }

  void addReview(Review review) {
    _reviews.insert(0, review);

    // Update place review count
    final placeIndex = _places.indexWhere((p) => p.id == review.placeId);
    if (placeIndex != -1) {
      // In a real app, we'd update the place object
    }

    // Mark reviewable place as reviewed
    final reviewableIndex = _reviewablePlaces.indexWhere(
      (r) => r.placeId == review.placeId && !r.hasReviewed,
    );
    if (reviewableIndex != -1) {
      _reviewablePlaces[reviewableIndex] = ReviewablePlace(
        placeId: _reviewablePlaces[reviewableIndex].placeId,
        placeName: _reviewablePlaces[reviewableIndex].placeName,
        visitedAt: _reviewablePlaces[reviewableIndex].visitedAt,
        hasReviewed: true,
      );
    }

    notifyListeners();
  }

  // Generate random AI quote
  String generateAIQuote() {
    return AIQuotes.getRandomQuote();
  }

  // Generate new photo card ID
  String generateId() {
    return _uuid.v4();
  }
}
