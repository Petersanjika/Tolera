/// Member data model
class Member {
  final int? id;
  final String fullName;
  final String phone;
  final String gender; // 'Male' | 'Female' | 'Other'
  final String houseNumber;
  final String village;
  final String? nationalId;
  final String? photoPath;
  final int householdSize;
  final DateTime joinDate;
  final String status; // 'active' | 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;

  const Member({
    this.id,
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.houseNumber,
    required this.village,
    this.nationalId,
    this.photoPath,
    this.householdSize = 1,
    required this.joinDate,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  Member copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? gender,
    String? houseNumber,
    String? village,
    String? nationalId,
    String? photoPath,
    int? householdSize,
    DateTime? joinDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      houseNumber: houseNumber ?? this.houseNumber,
      village: village ?? this.village,
      nationalId: nationalId ?? this.nationalId,
      photoPath: photoPath ?? this.photoPath,
      householdSize: householdSize ?? this.householdSize,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'phone': phone,
      'gender': gender,
      'houseNumber': houseNumber,
      'village': village,
      'nationalId': nationalId,
      'photoPath': photoPath,
      'householdSize': householdSize,
      'joinDate': joinDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as int?,
      fullName: map['fullName'] as String,
      phone: map['phone'] as String,
      gender: map['gender'] as String,
      houseNumber: map['houseNumber'] as String,
      village: map['village'] as String,
      nationalId: map['nationalId'] as String?,
      photoPath: map['photoPath'] as String?,
      householdSize: map['householdSize'] as int? ?? 1,
      joinDate: DateTime.parse(map['joinDate'] as String),
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  bool get isActive => status == 'active';

  @override
  String toString() => 'Member(id: $id, fullName: $fullName)';
}
