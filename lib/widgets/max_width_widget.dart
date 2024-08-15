import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

class MaxWidthContainer extends StatelessWidget {
  final Widget child;

  const MaxWidthContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
