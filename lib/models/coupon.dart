class Coupon {
  final String id;
  final String placeId;
  final String placeName;
  final String description;
  final String province;
  final String city;
  final DateTime receivedAt;
  final DateTime? usedAt;
  final bool isUsed;

  Coupon({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.description,
    required this.province,
    required this.city,
    required this.receivedAt,
    this.usedAt,
    this.isUsed = false,
  });

  String get formattedReceivedDate {
    return '${receivedAt.year}.${receivedAt.month.toString().padLeft(2, '0')}.${receivedAt.day.toString().padLeft(2, '0')}';
  }

  String get formattedUsedDate {
    if (usedAt == null) return '';
    return '${usedAt!.year}.${usedAt!.month.toString().padLeft(2, '0')}.${usedAt!.day.toString().padLeft(2, '0')}';
  }

  Coupon copyWith({
    String? id,
    String? placeId,
    String? placeName,
    String? description,
    String? province,
    String? city,
    DateTime? receivedAt,
    DateTime? usedAt,
    bool? isUsed,
  }) {
    return Coupon(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      description: description ?? this.description,
      province: province ?? this.province,
      city: city ?? this.city,
      receivedAt: receivedAt ?? this.receivedAt,
      usedAt: usedAt ?? this.usedAt,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'placeName': placeName,
      'description': description,
      'province': province,
      'city': city,
      'receivedAt': receivedAt.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
      'isUsed': isUsed,
    };
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      placeId: json['placeId'],
      placeName: json['placeName'],
      description: json['description'],
      province: json['province'],
      city: json['city'],
      receivedAt: DateTime.parse(json['receivedAt']),
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
      isUsed: json['isUsed'] ?? false,
    );
  }
}
