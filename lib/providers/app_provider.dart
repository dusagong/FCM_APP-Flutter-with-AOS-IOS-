import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/travel_api_service.dart';
import '../services/photo_card_storage_service.dart';
import '../services/stamp_storage_service.dart';


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

  // Stamps (코스 스탬프)
  List<CourseStamp> _stamps = [];

  // Current destination (from PhotoCard)
  String? _currentProvince;
  String? _currentCity;
  
  // User Profile
  String? _userProfileImage;

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
  String? get userProfileImage => _userProfileImage;

  // 추천 API 결과 Getters
  RecommendationResponse? get recommendationResponse => _recommendationResponse;
  bool get isLoadingRecommendation => _isLoadingRecommendation;
  String? get recommendationError => _recommendationError;
  List<SpotWithLocation> get recommendedSpots => _recommendationResponse?.spots ?? [];
  RecommendedCourse? get recommendedCourse => _recommendationResponse?.course;

  // Stamp Getters
  List<CourseStamp> get stamps => _stamps;
  List<CourseStamp> get completedStamps => _stamps.where((s) => s.isCompleted).toList();
  List<CourseStamp> get inProgressStamps => _stamps.where((s) => !s.isCompleted).toList();
  int get stampCount => _stamps.length;
  int get completedStampCount => completedStamps.length;

  // Stats
  int get photoCardCount => _photoCards.length;
  int get couponCount => _coupons.length;
  int get reviewCount => _reviews.length;

  AppProvider() {
    _initSampleData();
    _loadPhotoCardsFromStorage();
    _loadStampsFromStorage();
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

        // 프로필 이미지 로드
        _userProfileImage = await PhotoCardStorageService.getUserProfileImage();

        notifyListeners();
      }
    } catch (e) {
      print('PhotoCard 로드 에러: $e');
    }
  }

  void _initSampleData() {
    // 목업 데이터 제거 - 실제 데이터만 사용
    _photoCards = [];
    _places = [];
    _reviews = [];

    notifyListeners();
  }

  /// SharedPreferences에서 스탬프 로드
  Future<void> _loadStampsFromStorage() async {
    try {
      final storedStamps = await StampStorageService.getAllStamps();
      if (storedStamps.isNotEmpty) {
        _stamps = storedStamps;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('스탬프 로드 에러: $e');
    }
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
      String? savedImagePath;

      // 이미지 영구 저장 처리
      if (imagePath != null) {
        final File sourceFile = File(imagePath);
        if (await sourceFile.exists()) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = 'photocard_${_uuid.v4()}.jpg'; // Unique name
          final savedImage = await sourceFile.copy('${directory.path}/$fileName');
          savedImagePath = savedImage.path;
          print('✅ [IMAGE SAVED] Saved to: $savedImagePath');
        } else {
          print('⚠️ [IMAGE WARNING] Source file does not exist: $imagePath');
        }
      }

      // 1. area_code, sigungu_code 변환
      final codes = TravelApiService.getAreaCodes(province, city);
      final areaCode = codes['area_code'];
      final sigunguCode = codes['sigungu_code'];

      // 2. 서버에 PhotoCard 생성 요청
      // area_code + sigungu_code를 함께 전달하면 백그라운드에서 추천 요청이 시작됨
      final response = await TravelApiService.createPhotoCard(
        province: province,
        city: city,
        message: message,
        hashtags: hashtags,
        aiQuote: aiQuote,
        imagePath: savedImagePath ?? imagePath,
        areaCode: areaCode,
        sigunguCode: sigunguCode,
      );

      // 2. 서버 응답으로 PhotoCard 객체 생성
      final photoCard = PhotoCard(
        id: response['id'],
        province: province,
        city: city,
        message: message,
        hashtags: hashtags,
        aiQuote: aiQuote,
        imagePath: savedImagePath ?? imagePath, // Use persistence path
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

  /// 추천 결과 직접 설정 (preloaded 데이터용)
  void setRecommendationResponse(RecommendationResponse response) {
    _recommendationResponse = response;
    _recommendationError = null;
    _isLoadingRecommendation = false;
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

  /// 장소 이름으로 쿠폰 소유 여부 확인 (API 장소용)
  bool hasCouponByName(String placeName) {
    return _coupons.any((c) => c.placeName == placeName && !c.isUsed);
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

  /// 장소 이름으로 쿠폰 추가 (API 장소용)
  void addCouponByName(String placeName, String category) {
    if (hasCouponByName(placeName)) return;

    final coupon = Coupon(
      id: _uuid.v4(),
      placeId: 'api_${_uuid.v4()}', // API 장소용 임시 ID
      placeName: placeName,
      description: '10% 할인',
      province: _currentProvince ?? '',
      city: _currentCity ?? '',
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

  /// 서버에서 장소별 리뷰 로드
  Future<List<Review>> loadReviewsByPlace(String placeId) async {
    try {
      final result = await TravelApiService.getReviewsByPlace(placeId);
      // 로컬 캐시 업데이트 (해당 장소 리뷰만)
      _reviews.removeWhere((r) => r.placeId == placeId);
      _reviews.insertAll(0, result.reviews);
      notifyListeners();
      return result.reviews;
    } catch (e) {
      print('리뷰 로드 에러: $e');
      return [];
    }
  }

  /// 서버에서 내 리뷰 로드
  Future<List<Review>> loadMyReviews(String userId) async {
    try {
      final result = await TravelApiService.getMyReviews(userId);
      // 로컬 캐시 업데이트
      _reviews = result.reviews;
      notifyListeners();
      return result.reviews;
    } catch (e) {
      print('내 리뷰 로드 에러: $e');
      return [];
    }
  }

  /// 서버에서 전체 리뷰 로드
  Future<List<Review>> loadAllReviews({int limit = 50, int offset = 0}) async {
    try {
      final result = await TravelApiService.getAllReviews(limit: limit, offset: offset);
      if (offset == 0) {
        _reviews = result.reviews;
      } else {
        _reviews.addAll(result.reviews);
      }
      notifyListeners();
      return result.reviews;
    } catch (e) {
      print('전체 리뷰 로드 에러: $e');
      return [];
    }
  }

  /// 로컬 캐시에서 장소별 리뷰 가져오기
  List<Review> getReviewsByPlace(String placeId) {
    return _reviews.where((r) => r.placeId == placeId).toList();
  }

  /// 리뷰 생성 (서버 연동)
  Future<Review?> createReview({
    required String placeId,
    required String placeName,
    required int rating,
    required String content,
    List<String> imagePaths = const [],
    String? userId,
    String? photoCardId,
  }) async {
    try {
      // 이미지 경로를 File 객체로 변환
      final images = imagePaths.map((path) => File(path)).toList();

      final review = await TravelApiService.createReview(
        placeId: placeId,
        placeName: placeName,
        rating: rating,
        content: content,
        images: images,
        userId: userId,
        photoCardId: photoCardId ?? _currentPhotoCard?.id,
      );

      // 로컬 캐시에 추가
      _reviews.insert(0, review);

      // Mark reviewable place as reviewed
      final reviewableIndex = _reviewablePlaces.indexWhere(
        (r) => (r.placeId == placeId || r.placeName == placeName) && !r.hasReviewed,
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
      return review;
    } catch (e) {
      print('리뷰 생성 에러: $e');
      return null;
    }
  }

  /// 리뷰 삭제 (서버 연동)
  Future<bool> deleteReview(String reviewId) async {
    try {
      final success = await TravelApiService.deleteReview(reviewId);
      if (success) {
        _reviews.removeWhere((r) => r.id == reviewId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('리뷰 삭제 에러: $e');
      return false;
    }
  }

  /// 리뷰 추가 (로컬 전용 - 이전 버전 호환)
  void addReview(Review review) {
    _reviews.insert(0, review);

    // Mark reviewable place as reviewed (placeId 또는 placeName으로 매칭)
    final reviewableIndex = _reviewablePlaces.indexWhere(
      (r) => (r.placeId == review.placeId || r.placeName == review.placeName) && !r.hasReviewed,
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

  // User Profile Method
  Future<void> updateUserProfileImage(String imagePath) async {
    try {
      final File sourceFile = File(imagePath);
      if (await sourceFile.exists()) {
        // 영구 저장소로 복사
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'user_profile_${_uuid.v4()}.jpg';
        final savedImage = await sourceFile.copy('${directory.path}/$fileName');
        
        // 상태 업데이트
        _userProfileImage = savedImage.path;
        
        // 스토리지 저장
        await PhotoCardStorageService.saveUserProfileImage(_userProfileImage!);
        
        notifyListeners();
      }
    } catch (e) {
      print('프로필 이미지 업데이트 실패: $e');
      throw e;
    }
  }

  // Generate random AI quote
  String generateAIQuote() {
    return AIQuotes.getRandomQuote();
  }

  // Generate new photo card ID
  String generateId() {
    return _uuid.v4();
  }

  // ========== Stamp Methods ==========

  /// 포토카드별 스탬프 조회
  List<CourseStamp> getStampsByPhotoCard(String photoCardId) {
    return _stamps.where((s) => s.photoCardId == photoCardId).toList();
  }

  /// 코스 스탬프 생성 (만남승강장에서 코스 추천 받을 때 호출)
  Future<CourseStamp> createCourseStamp({
    required String photoCardId,
    required RecommendedCourse course,
    required String province,
    required String city,
  }) async {
    // 이미 같은 포토카드 + 코스 조합의 스탬프가 있는지 확인
    final existingStamp = _stamps.firstWhere(
      (s) => s.photoCardId == photoCardId && s.courseTitle == course.title,
      orElse: () => CourseStamp(
        id: '',
        photoCardId: '',
        courseTitle: '',
        province: '',
        city: '',
        stopProgresses: [],
        createdAt: DateTime.now(),
      ),
    );

    if (existingStamp.id.isNotEmpty) {
      return existingStamp; // 이미 존재하면 기존 스탬프 반환
    }

    // 새 스탬프 생성
    final stamp = CourseStamp(
      id: _uuid.v4(),
      photoCardId: photoCardId,
      courseTitle: course.title,
      province: province,
      city: city,
      stopProgresses: course.stops.map((stop) => StopProgress(
        order: stop.order,
        stopName: stop.name,
        category: stop.category,
      )).toList(),
      createdAt: DateTime.now(),
    );

    _stamps.insert(0, stamp);
    await StampStorageService.saveStamp(stamp);
    notifyListeners();

    return stamp;
  }

  /// 스탬프 쿠폰 진행상황 업데이트
  Future<void> updateStampCouponProgress(String stopName) async {
    // 현재 포토카드의 스탬프들에서 해당 장소 찾기
    if (_currentPhotoCard == null) return;

    for (var i = 0; i < _stamps.length; i++) {
      final stamp = _stamps[i];
      if (stamp.photoCardId != _currentPhotoCard!.id) continue;

      final stopIndex = stamp.stopProgresses.indexWhere(
        (s) => s.stopName == stopName,
      );

      if (stopIndex != -1) {
        final updatedProgresses = List<StopProgress>.from(stamp.stopProgresses);
        updatedProgresses[stopIndex] = updatedProgresses[stopIndex].copyWith(
          hasCoupon: true,
          couponReceivedAt: DateTime.now(),
        );

        // 완료 시점 설정: 이미 완료된 적 있으면 기존 값 유지, 처음 완료되면 현재 시간
        DateTime? newCompletedAt = stamp.completedAt;
        if (newCompletedAt == null && _checkStampCompletion(updatedProgresses)) {
          newCompletedAt = DateTime.now();
        }

        final updatedStamp = stamp.copyWith(
          stopProgresses: updatedProgresses,
          completedAt: newCompletedAt,
        );

        _stamps[i] = updatedStamp;
        await StampStorageService.saveStamp(updatedStamp);
        notifyListeners();
        break;
      }
    }
  }

  /// 스탬프 리뷰 진행상황 업데이트
  Future<void> updateStampReviewProgress(String stopName) async {
    // 현재 포토카드의 스탬프들에서 해당 장소 찾기
    if (_currentPhotoCard == null) return;

    for (var i = 0; i < _stamps.length; i++) {
      final stamp = _stamps[i];
      if (stamp.photoCardId != _currentPhotoCard!.id) continue;

      final stopIndex = stamp.stopProgresses.indexWhere(
        (s) => s.stopName == stopName,
      );

      if (stopIndex != -1) {
        final updatedProgresses = List<StopProgress>.from(stamp.stopProgresses);
        updatedProgresses[stopIndex] = updatedProgresses[stopIndex].copyWith(
          hasReview: true,
          reviewWrittenAt: DateTime.now(),
        );

        // 완료 시점 설정: 이미 완료된 적 있으면 기존 값 유지, 처음 완료되면 현재 시간
        DateTime? newCompletedAt = stamp.completedAt;
        if (newCompletedAt == null && _checkStampCompletion(updatedProgresses)) {
          newCompletedAt = DateTime.now();
        }

        final updatedStamp = stamp.copyWith(
          stopProgresses: updatedProgresses,
          completedAt: newCompletedAt,
        );

        _stamps[i] = updatedStamp;
        await StampStorageService.saveStamp(updatedStamp);
        notifyListeners();
        break;
      }
    }
  }

  /// 스탬프 완료 여부 체크
  bool _checkStampCompletion(List<StopProgress> progresses) {
    return progresses.every((p) => p.isCompleted);
  }

  /// 스탬프 삭제
  Future<void> deleteStamp(String stampId) async {
    _stamps.removeWhere((s) => s.id == stampId);
    await StampStorageService.deleteStamp(stampId);
    notifyListeners();
  }

  /// 특정 스탬프 조회
  CourseStamp? getStampById(String stampId) {
    try {
      return _stamps.firstWhere((s) => s.id == stampId);
    } catch (e) {
      return null;
    }
  }
}
