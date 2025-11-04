import 'package:intl/intl.dart';

/// Helper function to format prices with commas
String formatPrice(double? price, {bool showDecimals = false}) {
  if (price == null) {
    return '₱0';
  }
  
  final formatter = showDecimals
      ? NumberFormat('#,##0.00', 'en_US')
      : NumberFormat('#,##0', 'en_US');
  
  final formatted = formatter.format(price);
  return '₱$formatted';
}

