import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

Widget persoAlertDialogWithConstrainedContent({
  required Widget title,
  required Widget content,
  List<Widget>? actions,
  double? minWidth,
}) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return AlertDialog(
        title: title,
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minWidth: min(constraints.maxWidth * 0.8, maxWidth * 0.8),
            ),
            child: content,
          ),
        ),
        actions: actions,
      );
    },
  );
}
