DateTime calculateDateBirth(double age, int multiverseSpeed) {
  return DateTime.now().subtract(Duration(
    seconds: (age * 14 * 7 * 24 * 3600 / multiverseSpeed).round(),
  ));
}

// DateTime calculateDateBirth2(double age, int multiverseSpeed) {
//   return DateTime.now().subtract(Duration(
//     days: (age * 14 * 7 / multiverseSpeed).round(),
//   ));
// }
