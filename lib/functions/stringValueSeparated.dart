/// Split the value into a string with a correct format.
import 'package:intl/intl.dart';

String stringValueSeparated(int value) {
  return NumberFormat('#,###').format(value).replaceAll(',', ' ');
}
