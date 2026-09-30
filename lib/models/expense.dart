/// Expense data model
class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String paidTo;
  final String description;
  final String? receiptImagePath;
  final String? confirmationText; // Mobile money SMS text
  final String? approvedBy;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime createdAt;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidTo,
    required this.description,
    this.receiptImagePath,
    this.confirmationText,
    this.approvedBy,
    this.status = 'pending',
    required this.createdAt,
  });

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? paidTo,
    String? description,
    String? receiptImagePath,
    String? confirmationText,
    String? approvedBy,
    String? status,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paidTo: paidTo ?? this.paidTo,
      description: description ?? this.description,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      confirmationText: confirmationText ?? this.confirmationText,
      approvedBy: approvedBy ?? this.approvedBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'paidTo': paidTo,
      'description': description,
      'receiptImagePath': receiptImagePath,
      'confirmationText': confirmationText,
      'approvedBy': approvedBy,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      paidTo: map['paidTo'] as String,
      description: map['description'] as String,
      receiptImagePath: map['receiptImagePath'] as String?,
      confirmationText: map['confirmationText'] as String?,
      approvedBy: map['approvedBy'] as String,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  @override
  String toString() => 'Expense(id: $id, title: $title, amount: $amount)';
}
