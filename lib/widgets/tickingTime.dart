import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget tickingTimeWidget(DateTime endDate) {
  return StreamBuilder<int>(
    stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
    builder: (context, snapshot) {
      Duration remainingTime = endDate.difference(DateTime.now());
      final _isNegative = remainingTime.isNegative;
      remainingTime = remainingTime.abs();
      final daysLeft = remainingTime.inDays;
      final hoursLeft = remainingTime.inHours.remainder(24);
      final minutesLeft = remainingTime.inMinutes.remainder(60);
      final secondsLeft = remainingTime.inSeconds.remainder(60);

      return Tooltip(
        message: 'Deadline: ' + DateFormat('EEE d MMM HH:mm').format(endDate),
        child: Row(
          children: [
            Icon(Icons.timer_outlined,
                color: _isNegative ? Colors.red : Colors.green),
            Text(
              // ' ${_isNegative ? '-' : ''}${daysLeft > 0 ? '${daysLeft}d, ' : ''}${hoursLeft > 0 ? '${hoursLeft}h:' : ''}${minutesLeft > 0 ? '${minutesLeft}m' : ''}${secondsLeft}s',
              ' ${_isNegative ? '-' : ''}${daysLeft > 0 ? '${daysLeft}d, ' : ''}${hoursLeft > 0 ? '${hoursLeft}h:' : ''}${'${minutesLeft}m:'}${secondsLeft}s',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    },
  );
}
