/// Split the value into a string with a correct format.
import 'package:intl/intl.dart';

String stringValueSeparated(int value) {
  return NumberFormat('#,###').format(value).replaceAll(',', ' ');
}

String positionWithIndex(int position) {
  if (position == 1) {
    return '1st';
  } else if (position == 2) {
    return '2nd';
  } else if (position == 3) {
    return '3rd';
  } else {
    return position.toString() + 'th';
  }
}