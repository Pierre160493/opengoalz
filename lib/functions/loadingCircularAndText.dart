import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

Widget loadingCircularAndText(String text) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlayerJugglingAnimation(),
          Text(
            text,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: fontSizeMedium,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );

class PlayerJugglingAnimation extends StatefulWidget {
  @override
  _PlayerJugglingAnimationState createState() =>
      _PlayerJugglingAnimationState();
}

class _PlayerJugglingAnimationState extends State<PlayerJugglingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationAnimation,
      child: Icon(Icons.sports_soccer, size: 90, color: Colors.green),
    );
  }
}
