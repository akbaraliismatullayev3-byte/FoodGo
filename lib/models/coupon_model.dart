class Coupon {
  final String id;
  final String code;
  final double discountPercent;
  final double maxDiscount;
  final double minOrderAmount;
  final DateTime expiryDate;

  Coupon({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.maxDiscount,
    required this.minOrderAmount,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'discountPercent': discountPercent,
      'maxDiscount': maxDiscount,
      'minOrderAmount': minOrderAmount,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }

  factory Coupon.fromMap(Map<String, dynamic> map, String id) {
    return Coupon(
      id: id,
      code: map['code'] ?? '',
      discountPercent: (map['discountPercent'] ?? 0.0).toDouble(),
      maxDiscount: (map['maxDiscount'] ?? 0.0).toDouble(),
      minOrderAmount: (map['minOrderAmount'] ?? 0.0).toDouble(),
      expiryDate: map['expiryDate'] != null 
          ? DateTime.parse(map['expiryDate']) 
          : DateTime.now().add(const Duration(days: 7)),
    );
  }
}
