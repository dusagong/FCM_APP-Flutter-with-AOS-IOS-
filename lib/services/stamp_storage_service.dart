import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/stamp.dart';

/// 스탬프 로컬 저장소 서비스
class StampStorageService {
  static const String _stampsKey = 'course_stamps_list';

  /// 스탬프 저장
  static Future<void> saveStamp(CourseStamp stamp) async {
    final prefs = await SharedPreferences.getInstance();
    final stamps = await getAllStamps();

    // 기존에 같은 ID가 있으면 업데이트, 없으면 추가
    final existingIndex = stamps.indexWhere((s) => s.id == stamp.id);
    if (existingIndex != -1) {
      stamps[existingIndex] = stamp;
    } else {
      stamps.insert(0, stamp);
    }

    final stampsJson = stamps.map((s) => s.toJson()).toList();
    await prefs.setString(_stampsKey, jsonEncode(stampsJson));
  }

  /// 모든 스탬프 조회
  static Future<List<CourseStamp>> getAllStamps() async {
    final prefs = await SharedPreferences.getInstance();
    final stampsString = prefs.getString(_stampsKey);

    if (stampsString == null) {
      return [];
    }

    try {
      final List<dynamic> stampsJson = jsonDecode(stampsString);
      return stampsJson
          .map((json) => CourseStamp.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('스탬프 로드 에러: $e');
      return [];
    }
  }

  /// 포토카드별 스탬프 조회
  static Future<List<CourseStamp>> getStampsByPhotoCard(String photoCardId) async {
    final stamps = await getAllStamps();
    return stamps.where((s) => s.photoCardId == photoCardId).toList();
  }

  /// 특정 스탬프 조회 (ID로)
  static Future<CourseStamp?> getStampById(String id) async {
    final stamps = await getAllStamps();
    try {
      return stamps.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 스탬프 삭제
  static Future<void> deleteStamp(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stamps = await getAllStamps();

    stamps.removeWhere((s) => s.id == id);

    final stampsJson = stamps.map((s) => s.toJson()).toList();
    await prefs.setString(_stampsKey, jsonEncode(stampsJson));
  }

  /// 모든 스탬프 삭제
  static Future<void> clearAllStamps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stampsKey);
  }

  /// 완료된 스탬프만 조회
  static Future<List<CourseStamp>> getCompletedStamps() async {
    final stamps = await getAllStamps();
    return stamps.where((s) => s.isCompleted).toList();
  }

  /// 진행 중인 스탬프만 조회
  static Future<List<CourseStamp>> getInProgressStamps() async {
    final stamps = await getAllStamps();
    return stamps.where((s) => !s.isCompleted).toList();
  }
}
