import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:opengoalz/constants.dart';
import 'package:opengoalz/splash_page.dart';

const supabaseUrl =
    'https://kaderxuszmqjknsoyjpi.supabase.co'; // Get from Supabase Dashboard

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  var supabaseKey = dotenv.env['SUPABASE_KEY']; // Get value from .env file

  if (supabaseKey == null) {
    if (kDebugMode) {
      print('SUPABASE_KEY not found in .env file.');
    }
    return;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Chat App',
      theme: appTheme,
      home: const SplashPage(),
    );
  }
}


//class MyApp extends StatelessWidget {
//  const MyApp({super.key});
//
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Flutter Demo',
//      theme: ThemeData(
//        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//        useMaterial3: true,
//      ),
//      home: const MyHomePage(title: 'Flutter Demo Home Page'),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//  const MyHomePage({super.key, required this.title});
//
//  final String title;
//
//  @override
//  State<MyHomePage> createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      _counter++;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//        title: Text(widget.title),
//      ),
//      body: Center(
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            const Text(
//              'You have pushed the button this many times:',
//            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.headlineMedium,
//            ),
//            ElevatedButton(
//              onPressed: () async {
//                // Query data from your Supabase project
//                try {
//                  final response =
//                      // await supabase.from('clubs').select().isFilter('id', 1);
//                      await supabase.from('clubs').select('id').count();
//                  // Display the data in the console
//                  print('Data from Supabase: ${response.data}');
//                } on PostgrestException catch (error) {
//                  print(
//                      'PostgrestException: ${error}'); // Contains PostgREST error code
//                } catch (error) {
//                  print('Error fetching data: $error');
//                }
//              },
//              child: const Text('Fetch Data from Supabase'),
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: const Icon(Icons.add),
//      ),
//    );
//  }
//}
