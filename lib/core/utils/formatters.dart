import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for formatting values in the Tolera app
class AppFormatters {
  AppFormatters._();

  static final _currencyFormat = NumberFormat('#,##0', 'en_MW');
  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('hh:mm a');

  /// Format an amount as Malawian Kwacha
  /// e.g. 45000 → "K 45,000"
  static String currency(double amount) {
    return '${AppConstants.currencySymbol} ${_currencyFormat.format(amount)}';
  }

  /// Format date as "12 May 2026"
  static String date(DateTime date) => _dateFormat.format(date);

  /// Format date as "May 2026"
  static String monthYear(DateTime date) => _monthYearFormat.format(date);

  /// Format date as "12/05/2026"
  static String shortDate(DateTime date) => _shortDateFormat.format(date);

  /// Format time as "02:30 PM"
  static String time(DateTime date) => _timeFormat.format(date);

  /// Format DateTime as "12 May 2026, 02:30 PM"
  static String dateTime(DateTime date) =>
      '${_dateFormat.format(date)}, ${_timeFormat.format(date)}';

  /// Generate a receipt number: TLR-20260507-001
  static String receiptNumber(int id) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    return 'TLR-$dateStr-${id.toString().padLeft(3, '0')}';
  }

  /// Truncate a string to [maxLength] with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }

  /// Return the ordinal string for a month number (1 = January)
  static String monthName(int month) {
    if (month < 1 || month > 12) return '';
    return AppConstants.months[month - 1];
  }

  /// Convert a month-year string "2026-05" to "May 2026"
  static String formatMonthKey(String monthKey) {
    try {
      final parts = monthKey.split('-');
      if (parts.length != 2) return monthKey;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return '${AppConstants.months[month - 1]} $year';
    } catch (_) {
      return monthKey;
    }
  }

  /// Return current month key "YYYY-MM" e.g. "2026-05"
  static String currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Get initials from a full name (max 2 characters)
  static String initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Mask a phone number for display: 0888-123-456
  static String maskPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 9) return phone;
    return '${clean.substring(0, 4)}-${clean.substring(4, 7)}-${clean.substring(7)}';
  }
}
