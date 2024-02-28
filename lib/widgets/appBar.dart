import 'package:flutter/material.dart';
import '../constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageName;

  const CustomAppBar({
    Key? key,
    required this.pageName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green, // Set green grassy background color
      title: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(pageName),
          ),
          const Center(
            child: Text(
              appBarTxt,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
