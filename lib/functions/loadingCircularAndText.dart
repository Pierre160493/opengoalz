import 'package:flutter/material.dart';

Widget loadingCircularAndText(String text) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          // PlayerJugglingAnimation(),
          SizedBox(height: 16),
          Text(text),
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 100).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Player
          Positioned(
            bottom: 0,
            child: Icon(Icons.person, size: 100),
          ),
          // Ball
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                bottom: _animation.value + 100,
                child: Icon(Icons.sports_soccer, size: 30),
              );
            },
          ),
        ],
      ),
    );
  }
}
