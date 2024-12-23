import 'package:flutter/material.dart';

class OfflinePage extends StatelessWidget {
  final VoidCallback onReturn;

  OfflinePage({required this.onReturn});

  static Route route({required VoidCallback onReturn}) {
    return MaterialPageRoute<void>(builder: (_) => OfflinePage(onReturn: onReturn));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is the offline wiki page.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onReturn,
              child: Text('Return to Normal Flow'),
            ),
          ],
        ),
      ),
    );
  }
}
