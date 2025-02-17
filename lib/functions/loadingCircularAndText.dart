import 'package:flutter/material.dart';

Widget loadingCircularAndText(String text) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(text),
        ],
      ),
    );
