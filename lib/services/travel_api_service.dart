import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recommendation.dart';
import '../models/review.dart';

class TravelApiService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';

  /// PhotoCard 생성 API
  /// 서버에 PhotoCard를 생성하고 UUID를 받아옴
  /// area_code와 sigungu_code를 함께 전달하면 백그라운드에서 추천 요청이 시작됨
  static Future<Map<String, dynamic>> createPhotoCard({
    required String province,
    required String city,
    required String message,
    required List<String> hashtags,
    required String aiQuote,
    String? userId,
    String? imagePath,
    String? areaCode,
    String? sigunguCode,
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
        if (areaCode != null) 'area_code': areaCode,
        if (sigunguCode != null) 'sigungu_code': sigunguCode,
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

  /// City → sigungu_code 매핑 (전체 지역)
  static const Map<String, Map<String, String>> citySigunguCodeMap = {
    // 서울특별시 (area_code: 1)
    '서울특별시': {
      '강남구': '1',
      '강동구': '2',
      '강북구': '3',
      '강서구': '4',
      '관악구': '5',
      '광진구': '6',
      '구로구': '7',
      '금천구': '8',
      '노원구': '9',
      '도봉구': '10',
      '동대문구': '11',
      '동작구': '12',
      '마포구': '13',
      '서대문구': '14',
      '서초구': '15',
      '성동구': '16',
      '성북구': '17',
      '송파구': '18',
      '양천구': '19',
      '영등포구': '20',
      '용산구': '21',
      '은평구': '22',
      '종로구': '23',
      '중구': '24',
      '중랑구': '25',
    },
    // 인천광역시 (area_code: 2)
    '인천광역시': {
      '강화군': '1',
      '계양구': '2',
      '미추홀구': '3',
      '남동구': '4',
      '동구': '5',
      '부평구': '6',
      '서구': '7',
      '연수구': '8',
      '옹진군': '9',
      '중구': '10',
    },
    // 대전광역시 (area_code: 3)
    '대전광역시': {
      '대덕구': '1',
      '동구': '2',
      '서구': '3',
      '유성구': '4',
      '중구': '5',
    },
    // 대구광역시 (area_code: 4)
    '대구광역시': {
      '남구': '1',
      '달서구': '2',
      '달성군': '3',
      '동구': '4',
      '북구': '5',
      '서구': '6',
      '수성구': '7',
      '중구': '8',
      '군위군': '9',
    },
    // 광주광역시 (area_code: 5)
    '광주광역시': {
      '광산구': '1',
      '남구': '2',
      '동구': '3',
      '북구': '4',
      '서구': '5',
    },
    // 부산광역시 (area_code: 6)
    '부산광역시': {
      '강서구': '1',
      '금정구': '2',
      '기장군': '3',
      '남구': '4',
      '동구': '5',
      '동래구': '6',
      '부산진구': '7',
      '북구': '8',
      '사상구': '9',
      '사하구': '10',
      '서구': '11',
      '수영구': '12',
      '연제구': '13',
      '영도구': '14',
      '중구': '15',
      '해운대구': '16',
    },
    // 울산광역시 (area_code: 7)
    '울산광역시': {
      '중구': '1',
      '남구': '2',
      '동구': '3',
      '북구': '4',
      '울주군': '5',
    },
    // 경기도 (area_code: 31)
    '경기도': {
      '가평군': '1',
      '고양시': '2',
      '과천시': '3',
      '광명시': '4',
      '광주시': '5',
      '구리시': '6',
      '군포시': '7',
      '김포시': '8',
      '남양주시': '9',
      '동두천시': '10',
      '부천시': '11',
      '성남시': '12',
      '수원시': '13',
      '시흥시': '14',
      '안산시': '15',
      '안성시': '16',
      '안양시': '17',
      '양주시': '18',
      '양평군': '19',
      '여주시': '20',
      '연천군': '21',
      '오산시': '22',
      '용인시': '23',
      '의왕시': '24',
      '의정부시': '25',
      '이천시': '26',
      '파주시': '27',
      '평택시': '28',
      '포천시': '29',
      '하남시': '30',
      '화성시': '31',
    },
    // 강원특별자치도 (area_code: 32) - API 기준 정확한 매핑
    '강원도': {
      '강릉시': '1',
      '고성군': '2',
      '동해시': '3',
      '삼척시': '4',
      '속초시': '5',
      '양구군': '6',
      '양양군': '7',
      '영월군': '8',
      '원주시': '9',
      '인제군': '10',
      '정선군': '11',
      '철원군': '12',
      '춘천시': '13',
      '태백시': '14',
      '평창군': '15',
      '홍천군': '16',
      '화천군': '17',
      '횡성군': '18',
    },
    '강원특별자치도': {
      '강릉시': '1',
      '고성군': '2',
      '동해시': '3',
      '삼척시': '4',
      '속초시': '5',
      '양구군': '6',
      '양양군': '7',
      '영월군': '8',
      '원주시': '9',
      '인제군': '10',
      '정선군': '11',
      '철원군': '12',
      '춘천시': '13',
      '태백시': '14',
      '평창군': '15',
      '홍천군': '16',
      '화천군': '17',
      '횡성군': '18',
    },
    // 충청북도 (area_code: 33)
    '충청북도': {
      '괴산군': '1',
      '단양군': '2',
      '보은군': '3',
      '영동군': '4',
      '옥천군': '5',
      '음성군': '6',
      '제천시': '7',
      '진천군': '8',
      '청원군': '9',
      '청주시': '10',
      '충주시': '11',
      '증평군': '12',
    },
    // 충청남도 (area_code: 34)
    '충청남도': {
      '공주시': '1',
      '금산군': '2',
      '논산시': '3',
      '당진시': '4',
      '보령시': '5',
      '부여군': '6',
      '서산시': '7',
      '서천군': '8',
      '아산시': '9',
      '예산군': '11',
      '천안시': '12',
      '청양군': '13',
      '태안군': '14',
      '홍성군': '15',
      '계룡시': '16',
    },
    // 경상북도 (area_code: 35)
    '경상북도': {
      '경산시': '1',
      '경주시': '2',
      '고령군': '3',
      '구미시': '4',
      '김천시': '6',
      '문경시': '7',
      '봉화군': '8',
      '상주시': '9',
      '성주군': '10',
      '안동시': '11',
      '영덕군': '12',
      '영양군': '13',
      '영주시': '14',
      '영천시': '15',
      '예천군': '16',
      '울릉군': '17',
      '울진군': '18',
      '의성군': '19',
      '청도군': '20',
      '청송군': '21',
      '칠곡군': '22',
      '포항시': '23',
    },
    // 경상남도 (area_code: 36)
    '경상남도': {
      '거제시': '1',
      '거창군': '2',
      '고성군': '3',
      '김해시': '4',
      '남해군': '5',
      '마산시': '6',
      '밀양시': '7',
      '사천시': '8',
      '산청군': '9',
      '양산시': '10',
      '의령군': '12',
      '진주시': '13',
      '진해시': '14',
      '창녕군': '15',
      '창원시': '16',
      '통영시': '17',
      '하동군': '18',
      '함안군': '19',
      '함양군': '20',
      '합천군': '21',
    },
    // 전라북도 / 전북특별자치도 (area_code: 37)
    '전라북도': {
      '고창군': '1',
      '군산시': '2',
      '김제시': '3',
      '남원시': '4',
      '무주군': '5',
      '부안군': '6',
      '순창군': '7',
      '완주군': '8',
      '익산시': '9',
      '임실군': '10',
      '장수군': '11',
      '전주시': '12',
      '정읍시': '13',
      '진안군': '14',
    },
    '전북특별자치도': {
      '고창군': '1',
      '군산시': '2',
      '김제시': '3',
      '남원시': '4',
      '무주군': '5',
      '부안군': '6',
      '순창군': '7',
      '완주군': '8',
      '익산시': '9',
      '임실군': '10',
      '장수군': '11',
      '전주시': '12',
      '정읍시': '13',
      '진안군': '14',
    },
    // 전라남도 (area_code: 38)
    '전라남도': {
      '강진군': '1',
      '고흥군': '2',
      '곡성군': '3',
      '광양시': '4',
      '구례군': '5',
      '나주시': '6',
      '담양군': '7',
      '목포시': '8',
      '무안군': '9',
      '보성군': '10',
      '순천시': '11',
      '신안군': '12',
      '여수시': '13',
      '영광군': '16',
      '영암군': '17',
      '완도군': '18',
      '장성군': '19',
      '장흥군': '20',
      '진도군': '21',
      '함평군': '22',
      '해남군': '23',
      '화순군': '24',
    },
    // 제주특별자치도 (area_code: 39) - API 기준 정확한 매핑
    '제주도': {
      '남제주군': '1',
      '북제주군': '2',
      '서귀포시': '3',
      '제주시': '4',
    },
    '제주특별자치도': {
      '남제주군': '1',
      '북제주군': '2',
      '서귀포시': '3',
      '제주시': '4',
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

  // ============ Session API (추천 상태 조회) ============

  /// 세션 상태 조회 (polling용)
  /// status: pending, processing, completed, failed
  static Future<Map<String, dynamic>> getSessionStatus(String photoCardId) async {
    try {
      final url = '$baseUrl/sessions/status/$photoCardId';
      print('📤 [API REQUEST] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 세션 상태 조회 시간 초과');
          throw Exception('세션 상태 조회 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] 세션 상태: ${data['status']}');
        return data;
      } else if (response.statusCode == 404) {
        print('❌ [ERROR] 세션을 찾을 수 없습니다');
        return {'status': 'not_found', 'message': '세션을 찾을 수 없습니다'};
      } else {
        print('❌ [ERROR] 세션 상태 조회 실패: ${response.statusCode}');
        throw Exception('세션 상태 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] 세션 상태 조회 에러: $e');
      throw Exception('세션 상태 조회 에러: $e');
    }
  }

  /// 세션 추천 결과 조회
  /// status가 completed일 때 spots, course 데이터 포함
  static Future<Map<String, dynamic>> getSessionRecommendation(String photoCardId) async {
    try {
      final url = '$baseUrl/sessions/recommendation/$photoCardId';
      print('📤 [API REQUEST] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 추천 결과 조회 시간 초과');
          throw Exception('추천 결과 조회 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] 추천 결과 조회: ${data['status']}');
        return data;
      } else if (response.statusCode == 404) {
        print('❌ [ERROR] 세션을 찾을 수 없습니다');
        return {'status': 'not_found', 'message': '세션을 찾을 수 없습니다', 'spots': [], 'course': null};
      } else {
        print('❌ [ERROR] 추천 결과 조회 실패: ${response.statusCode}');
        throw Exception('추천 결과 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] 추천 결과 조회 에러: $e');
      throw Exception('추천 결과 조회 에러: $e');
    }
  }

  // ============ Review API ============

  /// 리뷰 생성 (이미지 포함)
  /// multipart/form-data로 전송
  static Future<Review> createReview({
    required String placeId,
    required String placeName,
    required int rating,
    required String content,
    required List<File> images,
    String? userId,
    String? photoCardId,
  }) async {
    try {
      final url = '$baseUrl/reviews';
      print('📤 [API REQUEST] POST $url (multipart)');

      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Form fields
      request.fields['place_id'] = placeId;
      request.fields['place_name'] = placeName;
      request.fields['rating'] = rating.toString();
      request.fields['content'] = content;
      if (userId != null) request.fields['user_id'] = userId;
      if (photoCardId != null) request.fields['photo_card_id'] = photoCardId;

      // Image files
      for (final image in images) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          image.path,
        ));
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 리뷰 생성 시간 초과');
          throw Exception('리뷰 생성 시간 초과');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] 리뷰 생성 완료: ${data['id']}');
        return Review.fromJson(data);
      } else {
        print('❌ [ERROR] 리뷰 생성 실패: ${response.statusCode}');
        print('❌ [ERROR BODY] ${utf8.decode(response.bodyBytes)}');
        throw Exception('리뷰 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] 리뷰 생성 에러: $e');
      throw Exception('리뷰 생성 에러: $e');
    }
  }

  /// 리뷰 단건 조회
  static Future<Review> getReview(String reviewId) async {
    try {
      final url = '$baseUrl/reviews/$reviewId';
      print('📤 [API REQUEST] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 리뷰 조회 시간 초과');
          throw Exception('리뷰 조회 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] 리뷰 조회 완료');
        return Review.fromJson(data);
      } else if (response.statusCode == 404) {
        print('❌ [ERROR] 리뷰를 찾을 수 없습니다');
        throw Exception('리뷰를 찾을 수 없습니다');
      } else {
        print('❌ [ERROR] 리뷰 조회 실패: ${response.statusCode}');
        throw Exception('리뷰 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] 리뷰 조회 에러: $e');
      throw Exception('리뷰 조회 에러: $e');
    }
  }

  /// 장소별 리뷰 목록 조회
  static Future<ReviewListResult> getReviewsByPlace(
    String placeId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final url = '$baseUrl/reviews/place/$placeId?limit=$limit&offset=$offset';
      print('📤 [API REQUEST] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 리뷰 목록 조회 시간 초과');
          throw Exception('리뷰 목록 조회 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] 리뷰 목록 조회: ${data['total_count']}개');
        return ReviewListResult.fromJson(data);
      } else {
        print('❌ [ERROR] 리뷰 목록 조회 실패: ${response.statusCode}');
        throw Exception('리뷰 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] 리뷰 목록 조회 에러: $e');
      throw Exception('리뷰 목록 조회 에러: $e');
    }
  }

  /// 사용자별 리뷰 목록 조회 (내 리뷰)
  static Future<ReviewListResult> getMyReviews(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final url = '$baseUrl/reviews/user/$userId?limit=$limit&offset=$offset';
      print('📤 [API REQUEST] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 내 리뷰 조회 시간 초과');
          throw Exception('내 리뷰 조회 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] 내 리뷰 조회: ${data['total_count']}개');
        return ReviewListResult.fromJson(data);
      } else {
        print('❌ [ERROR] 내 리뷰 조회 실패: ${response.statusCode}');
        throw Exception('내 리뷰 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] 내 리뷰 조회 에러: $e');
      throw Exception('내 리뷰 조회 에러: $e');
    }
  }

  /// 전체 리뷰 목록 조회
  static Future<ReviewListResult> getAllReviews({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final url = '$baseUrl/reviews?limit=$limit&offset=$offset';
      print('📤 [API REQUEST] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 전체 리뷰 조회 시간 초과');
          throw Exception('전체 리뷰 조회 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] 전체 리뷰 조회: ${data['total_count']}개');
        return ReviewListResult.fromJson(data);
      } else {
        print('❌ [ERROR] 전체 리뷰 조회 실패: ${response.statusCode}');
        throw Exception('전체 리뷰 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] 전체 리뷰 조회 에러: $e');
      throw Exception('전체 리뷰 조회 에러: $e');
    }
  }

  /// 장소별 평점 조회
  static Future<PlaceRating> getPlaceRating(String placeId) async {
    try {
      final url = '$baseUrl/reviews/place/$placeId/rating';
      print('📤 [API REQUEST] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 평점 조회 시간 초과');
          throw Exception('평점 조회 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ [SUCCESS] 평점 조회: ${data['average_rating']}');
        return PlaceRating.fromJson(data);
      } else {
        print('❌ [ERROR] 평점 조회 실패: ${response.statusCode}');
        throw Exception('평점 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [EXCEPTION] 평점 조회 에러: $e');
      throw Exception('평점 조회 에러: $e');
    }
  }

  /// 리뷰 삭제
  static Future<bool> deleteReview(String reviewId) async {
    try {
      final url = '$baseUrl/reviews/$reviewId';
      print('📤 [API REQUEST] DELETE $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [TIMEOUT] 리뷰 삭제 시간 초과');
          throw Exception('리뷰 삭제 시간 초과');
        },
      );

      print('📥 [API RESPONSE] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ [SUCCESS] 리뷰 삭제 완료');
        return true;
      } else if (response.statusCode == 404) {
        print('❌ [ERROR] 리뷰를 찾을 수 없습니다');
        return false;
      } else {
        print('❌ [ERROR] 리뷰 삭제 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 [EXCEPTION] 리뷰 삭제 에러: $e');
      return false;
    }
  }
}
