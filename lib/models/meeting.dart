/// Meeting data model
class Meeting {
  final int? id;
  final String title;
  final String meetingType;
  final String agenda;
  final String? minutes;
  final DateTime meetingDate;
  final String? photoPath;
  final String createdBy;
  final DateTime createdAt;

  const Meeting({
    this.id,
    required this.title,
    required this.meetingType,
    required this.agenda,
    this.minutes,
    required this.meetingDate,
    this.photoPath,
    required this.createdBy,
    required this.createdAt,
  });

  Meeting copyWith({
    int? id,
    String? title,
    String? meetingType,
    String? agenda,
    String? minutes,
    DateTime? meetingDate,
    String? photoPath,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      meetingType: meetingType ?? this.meetingType,
      agenda: agenda ?? this.agenda,
      minutes: minutes ?? this.minutes,
      meetingDate: meetingDate ?? this.meetingDate,
      photoPath: photoPath ?? this.photoPath,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'meetingType': meetingType,
      'agenda': agenda,
      'minutes': minutes,
      'meetingDate': meetingDate.toIso8601String(),
      'photoPath': photoPath,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'] as int?,
      title: map['title'] as String,
      meetingType: map['meetingType'] as String,
      agenda: map['agenda'] as String,
      minutes: map['minutes'] as String?,
      meetingDate: DateTime.parse(map['meetingDate'] as String),
      photoPath: map['photoPath'] as String?,
      createdBy: map['createdBy'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() => 'Meeting(id: $id, title: $title)';
}

/// Attendance record for a meeting
class Attendance {
  final int? id;
  final int meetingId;
  final int memberId;
  final String status; // 'present' | 'absent'
  final String? memberName; // joined from members table
  final DateTime createdAt;

  const Attendance({
    this.id,
    required this.meetingId,
    required this.memberId,
    required this.status,
    this.memberName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'meetingId': meetingId,
      'memberId': memberId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      meetingId: map['meetingId'] as int,
      memberId: map['memberId'] as int,
      status: map['status'] as String,
      memberName: map['memberName'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  bool get isPresent => status == 'present';
}
