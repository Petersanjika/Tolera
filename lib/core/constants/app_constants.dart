/// App-wide constants for Tolera
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'Tolera';
  static const String appTagline = 'Transparent Water Management';
  static const String appVersion = '1.0.0';

  // ── Database ──────────────────────────────────────────────────────────────
  static const String dbName = 'tolera.db';
  static const int dbVersion = 2;

  // ── Default PIN ───────────────────────────────────────────────────────────
  static const String defaultPin = '1234';
  static const String pinPrefKey = 'app_pin';
  static const String themeModePrefKey = 'theme_mode';

  // ── Payment Methods ───────────────────────────────────────────────────────
  static const List<String> paymentMethods = [
    'Cash',
    'Airtel Money',
    'TNM Mpamba',
    'Bank Transfer',
    'Mobile Money',
  ];

  // ── Expense Categories ────────────────────────────────────────────────────
  static const List<String> expenseCategories = [
    'Pipe Repair',
    'Tap Repair',
    'Fuel',
    'Transport',
    'Maintenance',
    'Salaries',
    'Electricity',
    'Water Treatment',
    'Security',
    'Meetings',
    'Tools & Equipment',
    'Other',
  ];

  // ── Meeting Types ─────────────────────────────────────────────────────────
  static const List<String> meetingTypes = [
    'Monthly Meeting',
    'Emergency Meeting',
    'Repair Meeting',
    'Committee Meeting',
    'Annual General Meeting',
  ];

  // ── Villages / Areas (Malawi) ─────────────────────────────────────────────
  static const List<String> villages = [
    'Area 25',
    'Area 47',
    'Chilomoni',
    'Ndirande',
    'Zingwangwa',
    'Bangwe',
    'Mbayani',
    'Limbe',
    'Blantyre City',
    'Malabada',
    'Chigumula',
    'Chirimba',
    'Machinjiri',
    'Makata',
    'Midima',
    'Other',
  ];

  // ── Fixed Monthly Contribution ─────────────────────────────────────────────
  static const double defaultMonthlyContribution = 2000.0; // MWK 2,000

  // ── Currency ──────────────────────────────────────────────────────────────
  static const String currency = 'MWK';
  static const String currencySymbol = 'K';

  // ── Months ────────────────────────────────────────────────────────────────
  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
