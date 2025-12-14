import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/travel_api_service.dart';
import '../services/photo_card_storage_service.dart';
import '../data/mock/mock_data.dart';


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

  // 추천 API 결과
  RecommendationResponse? _recommendationResponse;
  bool _isLoadingRecommendation = false;
  String? _recommendationError;

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

  // 추천 API 결과 Getters
  RecommendationResponse? get recommendationResponse => _recommendationResponse;
  bool get isLoadingRecommendation => _isLoadingRecommendation;
  String? get recommendationError => _recommendationError;
  List<SpotWithLocation> get recommendedSpots => _recommendationResponse?.spots ?? [];
  RecommendedCourse? get recommendedCourse => _recommendationResponse?.course;

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
    // MockData에서 테스트 데이터 로드
    _photoCards = MockData.getMockPhotoCards();
    _places = MockData.getMockPlaces();
    _reviews = MockData.getMockReviews();

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

  // 추천 API Methods

  /// 여행 추천 API 호출
  /// PhotoCard의 지역 정보 + 사용자 쿼리로 추천 요청
  Future<RecommendationResponse?> fetchRecommendations({
    required String query,
    required String province,
    required String city,
  }) async {
    _isLoadingRecommendation = true;
    _recommendationError = null;
    notifyListeners();

    try {
      // province/city → area_code/sigungu_code 변환
      final codes = TravelApiService.getAreaCodes(province, city);
      final areaCode = codes['area_code'];

      if (areaCode == null) {
        throw Exception('지원하지 않는 지역입니다: $province');
      }

      // API 호출
      _recommendationResponse = await TravelApiService.getRecommendations(
        query: query,
        areaCode: areaCode,
        sigunguCode: codes['sigungu_code'],
      );

      _isLoadingRecommendation = false;
      notifyListeners();
      return _recommendationResponse;
    } catch (e) {
      _isLoadingRecommendation = false;
      _recommendationError = e.toString();
      notifyListeners();
      print('추천 API 에러: $e');
      return null;
    }
  }

  /// 추천 결과 초기화
  void clearRecommendations() {
    _recommendationResponse = null;
    _recommendationError = null;
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
