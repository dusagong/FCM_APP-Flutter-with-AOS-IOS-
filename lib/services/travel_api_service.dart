import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recommendation.dart';

class TravelApiService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';

  /// PhotoCard 생성 API
  /// 서버에 PhotoCard를 생성하고 UUID를 받아옴
  static Future<Map<String, dynamic>> createPhotoCard({
    required String province,
    required String city,
    required String message,
    required List<String> hashtags,
    required String aiQuote,
    String? userId,
    String? imagePath,
  }) async {
    try {
      final url = '$baseUrl/photo_cards';
      final requestBody = {
        'user_id': userId,
        'province': province,
        'city': city,
        'message': message,
        'hashtags': hashtags,
        'ai_quote': aiQuote,
        'image_path': imagePath,
      };

      print('📤 [API REQUEST] POST $url');
      print('📦 [REQUEST BODY] ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 서버 응답 시간 초과');
          throw Exception('서버 응답 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');
      print('📄 [RESPONSE BODY] ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] PhotoCard 생성 완료: ${data['id']}');
        return data;
      } else {
        print('❌ [ERROR] PhotoCard 생성 실패: ${response.statusCode}');
        print('❌ [ERROR BODY] ${utf8.decode(response.bodyBytes)}');
        throw Exception('PhotoCard 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] PhotoCard 생성 에러: $e');
      throw Exception('PhotoCard 생성 에러: $e');
    }
  }

  /// PhotoCard 조회 API
  /// 서버에서 PhotoCard 정보를 가져옴 (활성 상태 확인용)
  static Future<Map<String, dynamic>> getPhotoCard(String photoCardId) async {
    try {
      final url = '$baseUrl/photo_cards/$photoCardId';
      print('📤 [API REQUEST] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 서버 응답 시간 초과');
          throw Exception('서버 응답 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');
      print('📄 [RESPONSE BODY] ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] PhotoCard 조회 완료');
        return data;
      } else if (response.statusCode == 404) {
        print('❌ [ERROR] PhotoCard를 찾을 수 없습니다');
        throw Exception('PhotoCard를 찾을 수 없습니다');
      } else {
        print('❌ [ERROR] PhotoCard 조회 실패: ${response.statusCode}');
        throw Exception('PhotoCard 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] PhotoCard 조회 에러: $e');
      throw Exception('PhotoCard 조회 에러: $e');
    }
  }

  /// PhotoCard 검증 API
  /// 만남승강장 접근 전 PhotoCard가 유효한지 확인
  static Future<bool> verifyPhotoCard(String photoCardId) async {
    try {
      final url = '$baseUrl/photo_cards/$photoCardId/verify';
      print('📤 [API REQUEST] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 서버 응답 시간 초과');
          throw Exception('서버 응답 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');
      print('📄 [RESPONSE BODY] ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final result = jsonDecode(utf8.decode(response.bodyBytes));
        final isValid = result['valid'] == true;
        print(isValid ? '✅ [SUCCESS] PhotoCard 검증 성공' : '❌ [FAIL] PhotoCard 검증 실패');
        return isValid;
      } else {
        print('❌ [ERROR] PhotoCard 검증 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 [EXCEPTION] PhotoCard 검증 에러: $e');
      return false;
    }
  }

  /// 여행 추천 API
  /// area_code와 sigungu_code를 함께 전달하여 정확한 추천을 받음
  ///
  /// 응답 구조:
  /// - spots: 리스트 뷰용 (전체 검색 결과, 지도 좌표 포함)
  /// - course: 코스 뷰용 (LLM이 큐레이션한 동선)
  static Future<RecommendationResponse> getRecommendations({
    required String query,
    required String areaCode,
    String? sigunguCode,
  }) async {
    try {
      final url = '$baseUrl/ask';
      final requestBody = {
        'query': query,
        'area_code': areaCode,
        if (sigunguCode != null) 'sigungu_code': sigunguCode,
      };

      print('📤 [API REQUEST] POST $url');
      print('📦 [REQUEST BODY] ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(minutes: 5), // LLM + MCP 처리 시간 고려
        onTimeout: () {
          print('⏱️ [TIMEOUT] 추천 요청 시간 초과 (5분)');
          throw Exception('추천 요청 시간 초과 (5분)');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] 추천 완료: ${data['spots']?.length ?? 0}개 장소');
        return RecommendationResponse.fromJson(data);
      } else {
        print('❌ [ERROR] 추천 요청 실패: ${response.statusCode}');
        throw Exception('추천 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] 추천 요청 에러: $e');
      throw Exception('추천 요청 에러: $e');
    }
  }

  /// 여행 추천 API (Raw Map 반환 - 하위 호환용)
  static Future<Map<String, dynamic>> getRecommendationsRaw({
    required String query,
    required String areaCode,
    String? sigunguCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ask'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'query': query,
          'area_code': areaCode,
          if (sigunguCode != null) 'sigungu_code': sigunguCode,
        }),
      ).timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw Exception('추천 요청 시간 초과 (5분)');
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('추천 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('추천 요청 에러: $e');
    }
  }

  /// Province → area_code 매핑
  static const Map<String, String> provinceToAreaCode = {
    '서울특별시': '1',
    '인천광역시': '2',
    '대전광역시': '3',
    '대구광역시': '4',
    '광주광역시': '5',
    '부산광역시': '6',
    '울산광역시': '7',
    '세종특별자치시': '8',
    '경기도': '31',
    '강원도': '32',
    '강원특별자치도': '32',
    '충청북도': '33',
    '충청남도': '34',
    '경상북도': '35',
    '경상남도': '36',
    '전라북도': '37',
    '전북특별자치도': '37',
    '전라남도': '38',
    '제주특별자치도': '39',
    '제주도': '39',
  };

  /// City → sigungu_code 매핑 (강원도)
  /// TODO: 나머지 지역 코드 추가 필요
  static const Map<String, Map<String, String>> citySigunguCodeMap = {
    '강원도': {
      '강릉시': '1',
      '동해시': '2',
      '삼척시': '3',
      '속초시': '4',
      '원주시': '5',
      '춘천시': '6',
      '태백시': '7',
      '고성군': '8',
      '양구군': '9',
      '양양군': '10',
      '영월군': '11',
      '인제군': '12',
      '정선군': '13',
      '철원군': '14',
      '평창군': '15',
      '홍천군': '16',
      '화천군': '17',
      '횡성군': '18',
    },
    '제주도': {
      '제주시': '1',
      '서귀포시': '2',
    },
    '제주특별자치도': {
      '제주시': '1',
      '서귀포시': '2',
    },
  };

  /// Province와 City로 area_code와 sigungu_code 가져오기
  static Map<String, String?> getAreaCodes(String province, String city) {
    final areaCode = provinceToAreaCode[province];
    final sigunguCode = citySigunguCodeMap[province]?[city];

    return {
      'area_code': areaCode,
      'sigungu_code': sigunguCode,
    };
  }
}
