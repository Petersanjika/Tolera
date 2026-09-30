/// Contribution (monthly payment) data model
class Contribution {
  final int? id;
  final int memberId;
  final double amount;
  final String monthKey; // Format: "YYYY-MM" e.g. "2026-05"
  final String paymentMethod;
  final String collectorName;
  final String? notes;
  final String? receiptPath;
  final String receiptNumber;
  final DateTime createdAt;

  const Contribution({
    this.id,
    required this.memberId,
    required this.amount,
    required this.monthKey,
    required this.paymentMethod,
    required this.collectorName,
    this.notes,
    this.receiptPath,
    required this.receiptNumber,
    required this.createdAt,
  });

  Contribution copyWith({
    int? id,
    int? memberId,
    double? amount,
    String? monthKey,
    String? paymentMethod,
    String? collectorName,
    String? notes,
    String? receiptPath,
    String? receiptNumber,
    DateTime? createdAt,
  }) {
    return Contribution(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      monthKey: monthKey ?? this.monthKey,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      collectorName: collectorName ?? this.collectorName,
      notes: notes ?? this.notes,
      receiptPath: receiptPath ?? this.receiptPath,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'memberId': memberId,
      'amount': amount,
      'monthKey': monthKey,
      'paymentMethod': paymentMethod,
      'collectorName': collectorName,
      'notes': notes,
      'receiptPath': receiptPath,
      'receiptNumber': receiptNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Contribution.fromMap(Map<String, dynamic> map) {
    return Contribution(
      id: map['id'] as int?,
      memberId: map['memberId'] as int,
      amount: (map['amount'] as num).toDouble(),
      monthKey: map['monthKey'] as String,
      paymentMethod: map['paymentMethod'] as String,
      collectorName: map['collectorName'] as String,
      notes: map['notes'] as String?,
      receiptPath: map['receiptPath'] as String?,
      receiptNumber: map['receiptNumber'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'Contribution(id: $id, memberId: $memberId, month: $monthKey)';
}
