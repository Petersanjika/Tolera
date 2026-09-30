import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

/// Tolera local SQLite database using sqflite.
/// Provides offline-first data storage for all app data.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables on first launch
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        phone TEXT NOT NULL,
        gender TEXT NOT NULL,
        houseNumber TEXT NOT NULL,
        village TEXT NOT NULL,
        nationalId TEXT,
        photoPath TEXT,
        householdSize INTEGER DEFAULT 1,
        joinDate TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE contributions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memberId INTEGER NOT NULL,
        amount REAL NOT NULL,
        monthKey TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        collectorName TEXT NOT NULL,
        notes TEXT,
        receiptPath TEXT,
        receiptNumber TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (memberId) REFERENCES members(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        paidTo TEXT NOT NULL,
        description TEXT NOT NULL,
        receiptImagePath TEXT,
        confirmationText TEXT,
        approvedBy TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE meetings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        meetingType TEXT NOT NULL,
        agenda TEXT NOT NULL,
        minutes TEXT,
        meetingDate TEXT NOT NULL,
        photoPath TEXT,
        createdBy TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meetingId INTEGER NOT NULL,
        memberId INTEGER NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (meetingId) REFERENCES meetings(id) ON DELETE CASCADE,
        FOREIGN KEY (memberId) REFERENCES members(id) ON DELETE CASCADE
      )
    ''');

    await _createUsersTable(db);
    // Seed demo data after tables are created
    await _seedDemoData(db);
    await _seedDemoUsers(db);
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        pin TEXT NOT NULL,
        profileImagePath TEXT,
        status TEXT DEFAULT 'active',
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsersTable(db);
      await _seedDemoUsers(db);
    }
  }

  /// Seed demo Malawian community data for testing
  Future<void> _seedDemoData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // --- Demo Members ---
    final memberData = [
      {
        'fullName': 'Chisomo Banda',
        'phone': '0888123456',
        'gender': 'Female',
        'houseNumber': 'HH-001',
        'village': 'Area 25',
        'householdSize': 4,
        'status': 'active',
      },
      {
        'fullName': 'Mwalimu Phiri',
        'phone': '0999234567',
        'gender': 'Male',
        'houseNumber': 'HH-002',
        'village': 'Area 25',
        'householdSize': 5,
        'status': 'active',
      },
      {
        'fullName': 'Thandiwe Mbewe',
        'phone': '0888345678',
        'gender': 'Female',
        'houseNumber': 'HH-003',
        'village': 'Ndirande',
        'householdSize': 3,
        'status': 'active',
      },
      {
        'fullName': 'Gift Chirwa',
        'phone': '0999456789',
        'gender': 'Male',
        'houseNumber': 'HH-004',
        'village': 'Ndirande',
        'householdSize': 6,
        'status': 'active',
      },
      {
        'fullName': 'Evelyn Msowoya',
        'phone': '0888567890',
        'gender': 'Female',
        'houseNumber': 'HH-005',
        'village': 'Chilomoni',
        'householdSize': 2,
        'status': 'active',
      },
      {
        'fullName': 'Kondwani Gondwe',
        'phone': '0999678901',
        'gender': 'Male',
        'houseNumber': 'HH-006',
        'village': 'Chilomoni',
        'householdSize': 4,
        'status': 'active',
      },
      {
        'fullName': 'Mercy Nkhoma',
        'phone': '0888789012',
        'gender': 'Female',
        'houseNumber': 'HH-007',
        'village': 'Bangwe',
        'householdSize': 5,
        'status': 'active',
      },
      {
        'fullName': 'Dalitso Tembo',
        'phone': '0999890123',
        'gender': 'Male',
        'houseNumber': 'HH-008',
        'village': 'Bangwe',
        'householdSize': 3,
        'status': 'inactive',
      },
      {
        'fullName': 'Patricia Kaunda',
        'phone': '0888901234',
        'gender': 'Female',
        'houseNumber': 'HH-009',
        'village': 'Mbayani',
        'householdSize': 4,
        'status': 'active',
      },
      {
        'fullName': 'Isaac Nyirenda',
        'phone': '0999012345',
        'gender': 'Male',
        'houseNumber': 'HH-010',
        'village': 'Mbayani',
        'householdSize': 2,
        'status': 'active',
      },
      {
        'fullName': 'Beatrice Lungu',
        'phone': '0888111222',
        'gender': 'Female',
        'houseNumber': 'HH-011',
        'village': 'Area 47',
        'householdSize': 5,
        'status': 'active',
      },
      {
        'fullName': 'Timothy Chalira',
        'phone': '0999222333',
        'gender': 'Male',
        'houseNumber': 'HH-012',
        'village': 'Area 47',
        'householdSize': 3,
        'status': 'active',
      },
    ];

    for (final m in memberData) {
      await db.insert('members', {
        ...m,
        'joinDate': DateTime(2025, 1, 1).toIso8601String(),
        'createdAt': now,
        'updatedAt': now,
      });
    }

    // --- Demo Contributions (last 3 months) ---
    final months = ['2026-02', '2026-03', '2026-04', '2026-05'];
    final paidMemberIds = [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12]; // member 8 has arrears
    int receiptCounter = 1;

    for (final month in months) {
      final membersToPay = month == '2026-05'
          ? [1, 2, 3, 5, 7, 9] // only some paid for current month
          : paidMemberIds;

      for (final memberId in membersToPay) {
        final dateStr = '$month-15T10:00:00.000';
        final receiptNum =
            'TLR-${month.replaceAll('-', '')}-${receiptCounter.toString().padLeft(3, '0')}';
        await db.insert('contributions', {
          'memberId': memberId,
          'amount': 2000.0,
          'monthKey': month,
          'paymentMethod': memberId % 2 == 0 ? 'Airtel Money' : 'Cash',
          'collectorName': 'Treasurer',
          'notes': null,
          'receiptPath': null,
          'receiptNumber': receiptNum,
          'createdAt': dateStr,
        });
        receiptCounter++;
      }
    }

    // --- Demo Expenses ---
    final expenseData = [
      {
        'title': 'Pipe Replacement – Main Line',
        'amount': 45000.0,
        'category': 'Pipe Repair',
        'paidTo': 'Chifundo Hardware',
        'description': 'Replaced 50m of 2-inch galvanized pipe near the main tap.',
        'approvedBy': 'Chairperson',
        'status': 'approved',
        'createdAt': '2026-03-10T09:00:00.000',
      },
      {
        'title': 'Fuel for Generator',
        'amount': 18000.0,
        'category': 'Fuel',
        'paidTo': 'Petroda Filling Station',
        'description': 'Fuel for water pump generator during power outage.',
        'approvedBy': 'Treasurer',
        'status': 'approved',
        'createdAt': '2026-03-22T14:00:00.000',
      },
      {
        'title': 'Tap Repair – Block C',
        'amount': 8500.0,
        'category': 'Tap Repair',
        'paidTo': 'Mr. Phiri Plumber',
        'description': 'Fixed 3 broken taps in Block C community water point.',
        'approvedBy': 'Chairperson',
        'status': 'approved',
        'createdAt': '2026-04-05T11:00:00.000',
      },
      {
        'title': 'Meeting Refreshments',
        'amount': 5000.0,
        'category': 'Meetings',
        'paidTo': 'Chisomo Banda',
        'description': 'Tea and biscuits for April monthly committee meeting.',
        'approvedBy': 'Secretary',
        'status': 'approved',
        'createdAt': '2026-04-15T15:30:00.000',
      },
      {
        'title': 'Water Treatment Chemicals',
        'amount': 22000.0,
        'category': 'Water Treatment',
        'paidTo': 'Malawi Water Authority',
        'description': 'Chlorine and purification chemicals for May quarter.',
        'approvedBy': 'Chairperson',
        'status': 'pending',
        'createdAt': '2026-05-02T08:00:00.000',
      },
    ];

    for (final e in expenseData) {
      await db.insert('expenses', {
        ...e,
        'receiptImagePath': null,
        'confirmationText': null,
      });
    }

    // --- Demo Meetings ---
    final meetingData = [
      {
        'title': 'February Monthly Meeting',
        'meetingType': 'Monthly Meeting',
        'agenda': '1. Review January finances\n2. Discuss pipe repair\n3. AOB',
        'minutes':
            'The committee reviewed January finances. Total collected: K22,000. Approved pipe repair budget of K45,000.',
        'meetingDate': '2026-02-15T14:00:00.000',
        'createdBy': 'Secretary',
        'createdAt': '2026-02-15T14:00:00.000',
      },
      {
        'title': 'March Monthly Meeting',
        'meetingType': 'Monthly Meeting',
        'agenda': '1. Financial report\n2. Repair update\n3. Arrears discussion',
        'minutes':
            'Pipe repair completed. 1 member with outstanding arrears. Agreed to send SMS reminders.',
        'meetingDate': '2026-03-15T14:00:00.000',
        'createdBy': 'Secretary',
        'createdAt': '2026-03-15T14:00:00.000',
      },
      {
        'title': 'Emergency Pump Repair Meeting',
        'meetingType': 'Emergency Meeting',
        'agenda': '1. Water pump failure assessment\n2. Approve emergency funds',
        'minutes':
            'Emergency funds of K18,000 approved for fuel and technician fees.',
        'meetingDate': '2026-03-20T09:00:00.000',
        'createdBy': 'Chairperson',
        'createdAt': '2026-03-20T09:00:00.000',
      },
      {
        'title': 'April Monthly Meeting',
        'meetingType': 'Monthly Meeting',
        'agenda': '1. Q1 financial review\n2. Water treatment chemicals\n3. AOB',
        'minutes': 'Q1 total income K88,000. Expenses K71,500. Balance K16,500.',
        'meetingDate': '2026-04-15T14:00:00.000',
        'createdBy': 'Secretary',
        'createdAt': '2026-04-15T14:00:00.000',
      },
    ];

    for (final m in meetingData) {
      final meetingId = await db.insert('meetings', {
        ...m,
        'photoPath': null,
      });

      // Add attendance for each meeting (most members present)
      final presentMembers = [1, 2, 3, 4, 5, 6, 7, 9, 10, 11];
      final absentMembers = [8, 12];
      for (final memberId in presentMembers) {
        await db.insert('attendance', {
          'meetingId': meetingId,
          'memberId': memberId,
          'status': 'present',
          'createdAt': m['meetingDate'],
        });
      }
      for (final memberId in absentMembers) {
        await db.insert('attendance', {
          'meetingId': meetingId,
          'memberId': memberId,
          'status': 'absent',
          'createdAt': m['meetingDate'],
        });
      }
    }
  }

  /// Seed demo user accounts for testing
  Future<void> _seedDemoUsers(Database db) async {
    final now = DateTime.now().toIso8601String();
    final users = [
      {
        'name': 'Peter Kumwembe',
        'phone': '0888000001',
        'role': 'chairperson',
        'pin': '1111',
        'status': 'active',
      },
      {
        'name': 'Mwalimu Phiri',
        'phone': '0999234567',
        'role': 'treasurer',
        'pin': '2222',
        'status': 'active',
      },
      {
        'name': 'Thandiwe Mbewe',
        'phone': '0888345678',
        'role': 'secretary',
        'pin': '3333',
        'status': 'active',
      },
      {
        'name': 'Gift Chirwa',
        'phone': '0999456789',
        'role': 'collector',
        'pin': '4444',
        'status': 'active',
      },
      {
        'name': 'Chisomo Banda',
        'phone': '0888123456',
        'role': 'member',
        'pin': '5555',
        'status': 'active',
      },
      {
        'name': 'Evelyn Msowoya',
        'phone': '0888567890',
        'role': 'member',
        'pin': '6666',
        'status': 'active',
      },
    ];
    for (final u in users) {
      await db.insert('users', {...u, 'createdAt': now});
    }
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
    _db = null;
  }
}
