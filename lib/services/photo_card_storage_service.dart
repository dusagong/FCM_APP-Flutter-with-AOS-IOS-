import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/photo_card.dart';

/// PhotoCard 로컬 저장소 서비스
/// SharedPreferences를 사용하여 디바이스에 PhotoCard 저장
/// 이미지는 저장하지 않음 (나중에 S3 연동 예정)
class PhotoCardStorageService {
  static const String _photoCardsKey = 'photo_cards_list';
  static const String _currentPhotoCardIdKey = 'current_photo_card_id';

  /// PhotoCard 저장
  /// 서버에서 받은 ID와 함께 로컬에 저장
  static Future<void> savePhotoCard(PhotoCard photoCard) async {
    final prefs = await SharedPreferences.getInstance();

    // 기존 PhotoCard 목록 가져오기
    final photoCards = await getAllPhotoCards();

    // 새 PhotoCard 추가 (맨 앞에)
    photoCards.insert(0, photoCard);

    // JSON으로 변환하여 저장
    final photoCardsJson = photoCards.map((card) => card.toJson()).toList();
    await prefs.setString(_photoCardsKey, jsonEncode(photoCardsJson));

    // 현재 PhotoCard로 설정
    await prefs.setString(_currentPhotoCardIdKey, photoCard.id);
  }

  /// 모든 PhotoCard 조회
  static Future<List<PhotoCard>> getAllPhotoCards() async {
    final prefs = await SharedPreferences.getInstance();
    final photoCardsString = prefs.getString(_photoCardsKey);

    if (photoCardsString == null) {
      return [];
    }

    try {
      final List<dynamic> photoCardsJson = jsonDecode(photoCardsString);
      return photoCardsJson
          .map((json) => PhotoCard.fromJson(json))
          .toList();
    } catch (e) {
      print('PhotoCard 로드 에러: $e');
      return [];
    }
  }

  /// 특정 PhotoCard 조회 (ID로)
  static Future<PhotoCard?> getPhotoCardById(String id) async {
    final photoCards = await getAllPhotoCards();
    try {
      return photoCards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 현재 PhotoCard ID 가져오기
  static Future<String?> getCurrentPhotoCardId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentPhotoCardIdKey);
  }

  /// 현재 PhotoCard 가져오기
  static Future<PhotoCard?> getCurrentPhotoCard() async {
    final currentId = await getCurrentPhotoCardId();
    if (currentId == null) return null;
    return await getPhotoCardById(currentId);
  }

  /// 현재 PhotoCard 설정
  static Future<void> setCurrentPhotoCard(String photoCardId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentPhotoCardIdKey, photoCardId);
  }

  /// PhotoCard 삭제 (로컬에서만)
  /// 서버에는 비활성화 API를 별도로 호출해야 함
  static Future<void> deletePhotoCard(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final photoCards = await getAllPhotoCards();

    // 해당 PhotoCard 제거
    photoCards.removeWhere((card) => card.id == id);

    // 저장
    final photoCardsJson = photoCards.map((card) => card.toJson()).toList();
    await prefs.setString(_photoCardsKey, jsonEncode(photoCardsJson));

    // 현재 PhotoCard가 삭제된 경우 초기화
    final currentId = await getCurrentPhotoCardId();
    if (currentId == id) {
      await prefs.remove(_currentPhotoCardIdKey);
    }
  }

  /// PhotoCard 업데이트
  static Future<void> updatePhotoCard(PhotoCard photoCard) async {
    final prefs = await SharedPreferences.getInstance();
    final photoCards = await getAllPhotoCards();

    // 해당 PhotoCard 찾아서 업데이트
    final index = photoCards.indexWhere((card) => card.id == photoCard.id);
    if (index != -1) {
      photoCards[index] = photoCard;

      // 저장
      final photoCardsJson = photoCards.map((card) => card.toJson()).toList();
      await prefs.setString(_photoCardsKey, jsonEncode(photoCardsJson));
    }
  }

  /// 모든 PhotoCard 삭제 (초기화)
  static Future<void> clearAllPhotoCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_photoCardsKey);
    await prefs.remove(_currentPhotoCardIdKey);
  }

  /// PhotoCard 개수
  static Future<int> getPhotoCardCount() async {
    final photoCards = await getAllPhotoCards();
    return photoCards.length;
  }
}
