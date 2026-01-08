import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/splash_page.dart';

class OfflinePage extends StatelessWidget {
  final VoidCallback onReturn;

  OfflinePage({required this.onReturn});

  static Route route({required VoidCallback onReturn}) {
    return MaterialPageRoute<void>(
        builder: (_) => OfflinePage(onReturn: onReturn));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Offline Page',
          style: TextStyle(fontSize: fontSizeLarge),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is the offline wiki page.',
                style: TextStyle(fontSize: fontSizeMedium)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => SplashPage()),
                  (route) => false,
                );
              },
              child: Text('Return to Normal Flow',
                  style: TextStyle(fontSize: fontSizeMedium)),
            ),
          ],
        ),
      ),
    );
  }
}
