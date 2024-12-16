import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget tickingTimeWidget(DateTime endDate) {
  return StreamBuilder<int>(
    stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
    builder: (context, snapshot) {
      final now = DateTime.now();
      Duration remainingTime = endDate.difference(now);
      final isNegative = remainingTime.isNegative;
      remainingTime = remainingTime.abs();
      final daysLeft = remainingTime.inDays;
      final hoursLeft = remainingTime.inHours.remainder(24);
      final minutesLeft = remainingTime.inMinutes.remainder(60);
      final secondsLeft = remainingTime.inSeconds.remainder(60);

      final timeString = ' ${isNegative ? '-' : ''}'
          '${daysLeft > 0 ? '${daysLeft}d, ' : ''}'
          '${hoursLeft > 0 ? '${hoursLeft}h' : ''}'
          '${minutesLeft}m'
          '${secondsLeft}s';

      return Tooltip(
        message: 'Deadline: ${DateFormat('EEE d MMM HH:mm').format(endDate)}',
        child: Row(
          children: [
            Icon(
              Icons.timer_outlined,
              color: isNegative ? Colors.red : Colors.green,
            ),
            Text(
              timeString,
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
