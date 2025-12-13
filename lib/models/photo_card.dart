class PhotoCard {
  final String id;
  final String? imagePath;
  final String message;
  final List<String> hashtags;
  final String province;
  final String city;
  final String aiQuote;
  final DateTime createdAt;
  final bool isDefault;

  PhotoCard({
    required this.id,
    this.imagePath,
    required this.message,
    required this.hashtags,
    required this.province,
    required this.city,
    required this.aiQuote,
    required this.createdAt,
    this.isDefault = false,
  });

  String get destination => '$province $city';

  String get formattedDate {
    return '${createdAt.year}년 ${createdAt.month}월 ${createdAt.day}일';
  }

  PhotoCard copyWith({
    String? id,
    String? imagePath,
    String? message,
    List<String>? hashtags,
    String? province,
    String? city,
    String? aiQuote,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return PhotoCard(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      message: message ?? this.message,
      hashtags: hashtags ?? this.hashtags,
      province: province ?? this.province,
      city: city ?? this.city,
      aiQuote: aiQuote ?? this.aiQuote,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'message': message,
      'hashtags': hashtags,
      'province': province,
      'city': city,
      'aiQuote': aiQuote,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  factory PhotoCard.fromJson(Map<String, dynamic> json) {
    return PhotoCard(
      id: json['id'],
      imagePath: json['imagePath'],
      message: json['message'],
      hashtags: List<String>.from(json['hashtags']),
      province: json['province'],
      city: json['city'],
      aiQuote: json['aiQuote'],
      createdAt: DateTime.parse(json['createdAt']),
      isDefault: json['isDefault'] ?? false,
    );
  }
}

// AI 감성 글귀 목록
class AIQuotes {
  static const List<String> quotes = [
    "사랑하는 사람과 함께하는 모든 순간이 기적이 됩니다",
    "여행은 두 사람의 마음을 더욱 가까이 만들어줍니다",
    "함께 걷는 모든 길이 특별한 추억이 됩니다",
    "소중한 사람과의 여행, 평생 간직할 보물입니다",
    "당신과 함께라면 어디든 천국입니다",
    "사랑은 여행처럼, 함께할 때 더 빛납니다",
    "두 손 꼭 잡고 걷는 이 길이 우리의 이야기",
    "오늘의 여행이 내일의 추억이 됩니다",
    "같은 풍경도 당신과 보면 더 아름답습니다",
    "기차는 달려도, 우리의 시간은 멈춰있네요",
    "창밖 풍경처럼, 우리 사랑도 끝없이 펼쳐져요",
    "이 순간을 영원히 기억하고 싶어요",
    "당신이 있어 이 여행이 완벽해요",
    "함께라서 더 설레는 기차 여행",
    "우리만의 특별한 추억을 만들어가요",
    "사랑하는 사람과 떠나는 여행, 그것이 행복입니다",
    "기차 창문에 비친 우리, 참 예쁘죠?",
    "달려가는 기차처럼, 우리 사랑도 앞으로만",
    "이 여행의 끝에도 당신이 있길 바래요",
    "함께 있으면 어디든 목적지가 됩니다",
  ];

  static String getRandomQuote() {
    final random = DateTime.now().millisecondsSinceEpoch % quotes.length;
    return quotes[random];
  }
}

// 해시태그 프리셋
class HashtagPresets {
  static const List<String> presets = [
    '맛집탐방',
    '카페투어',
    '로맨틱',
    '사진맛집',
    '힐링',
    '액티비티',
    '쇼핑',
    '역사탐방',
  ];
}

// 지역 데이터
class RegionData {
  static const Map<String, List<String>> provinces = {
    '강원특별자치도': ['강릉시', '속초시', '춘천시', '원주시', '동해시', '삼척시', '태백시', '정선군', '평창군', '양양군'],
    '경기도': ['수원시', '성남시', '고양시', '용인시', '부천시', '안산시', '안양시', '남양주시', '화성시', '평택시'],
    '경상남도': ['창원시', '김해시', '진주시', '양산시', '거제시', '통영시', '사천시', '밀양시', '함안군', '거창군'],
    '경상북도': ['포항시', '경주시', '구미시', '김천시', '안동시', '영주시', '상주시', '문경시', '경산시', '청도군'],
    '전라남도': ['목포시', '여수시', '순천시', '나주시', '광양시', '담양군', '곡성군', '구례군', '보성군', '화순군'],
    '전라북도': ['전주시', '군산시', '익산시', '정읍시', '남원시', '김제시', '완주군', '진안군', '무주군', '장수군'],
    '충청남도': ['천안시', '공주시', '보령시', '아산시', '서산시', '논산시', '계룡시', '당진시', '금산군', '부여군'],
    '충청북도': ['청주시', '충주시', '제천시', '보은군', '옥천군', '영동군', '증평군', '진천군', '괴산군', '음성군'],
    '제주도': ['제주시', '서귀포시'],
    '부산광역시': ['해운대구', '수영구', '남구', '동구', '서구', '중구', '영도구', '부산진구', '동래구', '금정구'],
    '대구광역시': ['중구', '동구', '서구', '남구', '북구', '수성구', '달서구', '달성군'],
    '인천광역시': ['중구', '동구', '미추홀구', '연수구', '남동구', '부평구', '계양구', '서구', '강화군', '옹진군'],
    '광주광역시': ['동구', '서구', '남구', '북구', '광산구'],
    '대전광역시': ['동구', '중구', '서구', '유성구', '대덕구'],
    '울산광역시': ['중구', '남구', '동구', '북구', '울주군'],
  };
}
