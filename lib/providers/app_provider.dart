import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
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
  }

  void _initSampleData() {
    // MockData에서 테스트 데이터 로드
    _photoCards = MockData.getMockPhotoCards();
    _places = MockData.getMockPlaces();
    _reviews = MockData.getMockReviews();

    notifyListeners();
  }

  // Photo Card Methods
  void addPhotoCard(PhotoCard card) {
    _photoCards.insert(0, card);
    notifyListeners();
  }

  void setCurrentPhotoCard(PhotoCard card) {
    _currentPhotoCard = card;
    _currentProvince = card.province;
    _currentCity = card.city;
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
