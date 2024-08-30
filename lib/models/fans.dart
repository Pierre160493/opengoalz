// ignore_for_file: non_constant_identifier_names

class Fans {
  Fans({
    required this.additional_fans,
  });

  final int additional_fans;

  Fans.fromMap({
    required Map<String, dynamic> map,
  }) : additional_fans = map['additional_fans'];
}
