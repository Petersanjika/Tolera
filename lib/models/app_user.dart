/// User roles within the Tolera community water system.
/// Each role has a different set of permissions and navigation tabs.
enum UserRole {
  collector,   // Records payments, registers members
  treasurer,   // Manages finances and expenses
  secretary,   // Manages meetings and attendance
  member,      // View-only access to personal and community data
  chairperson, // Full access + approvals + user management
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.collector:   return 'Data Collector';
      case UserRole.treasurer:   return 'Treasurer';
      case UserRole.secretary:   return 'Secretary';
      case UserRole.member:      return 'Member';
      case UserRole.chairperson: return 'Chairperson';
    }
  }

  String get description {
    switch (this) {
      case UserRole.collector:
        return 'Records contributions & registers members';
      case UserRole.treasurer:
        return 'Manages finances, expenses & reports';
      case UserRole.secretary:
        return 'Handles meetings & attendance records';
      case UserRole.member:
        return 'Views personal payments & community info';
      case UserRole.chairperson:
        return 'Full access, approvals & user management';
    }
  }

  String get dbValue {
    switch (this) {
      case UserRole.collector:   return 'collector';
      case UserRole.treasurer:   return 'treasurer';
      case UserRole.secretary:   return 'secretary';
      case UserRole.member:      return 'member';
      case UserRole.chairperson: return 'chairperson';
    }
  }

  static UserRole fromDb(String value) {
    switch (value) {
      case 'collector':   return UserRole.collector;
      case 'treasurer':   return UserRole.treasurer;
      case 'secretary':   return UserRole.secretary;
      case 'member':      return UserRole.member;
      case 'chairperson': return UserRole.chairperson;
      default:            return UserRole.member;
    }
  }
}

/// Represents a user account in the Tolera system.
class AppUser {
  final int? id;
  final String name;
  final String phone;
  final UserRole role;
  final String pin;
  final String? profileImagePath;
  final String status; // 'active' | 'inactive'
  final String createdAt;

  const AppUser({
    this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.pin,
    this.profileImagePath,
    this.status = 'active',
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      role: UserRoleExtension.fromDb(map['role'] as String),
      pin: map['pin'] as String,
      profileImagePath: map['profileImagePath'] as String?,
      status: map['status'] as String? ?? 'active',
      createdAt: map['createdAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'role': role.dbValue,
      'pin': pin,
      'profileImagePath': profileImagePath,
      'status': status,
      'createdAt': createdAt,
    };
  }

  AppUser copyWith({
    int? id,
    String? name,
    String? phone,
    UserRole? role,
    String? pin,
    String? profileImagePath,
    String? status,
    String? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      pin: pin ?? this.pin,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
