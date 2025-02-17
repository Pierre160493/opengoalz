import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';

class FansPage extends StatefulWidget {
  final int idClub;
  const FansPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => FansPage(idClub: idClub),
    );
  }

  @override
  State<FansPage> createState() => _FansPageState();
}

class _FansPageState extends State<FansPage> {
  late final Stream<List<Map<String, dynamic>>> _fansStream;

  @override
  void initState() {
    _fansStream = supabase
        .from('fans')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .order('created_at')
        .map((maps) => maps
            .map((map) => {
                  'id': map['id'],
                  'created_at': map['created_at'],
                  'additional_fans': map['additional_fans'],
                  'mood': map['mood'],
                  // Add more fields here as needed
                })
            .toList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(Provider.of<UserSessionProvider>(context, listen: false)
              .user!
              .selectedClub!
              .name)),
      // CustomAppBar(clubStream: _clubStream),
      // drawer: AppDrawer(clubStream: _clubStream),
      drawer: const AppDrawer(),
      body: MaxWidthContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Text(
            //   'Hello ${Provider.of<UserSessionProvider>(context, listen: false).user!.selectedClub!.username} !',
            //   style: const TextStyle(fontSize: 24),
            // ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _fansStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final fansList = snapshot.data!;
                    final totalFans = fansList.fold<int>(
                      0,
                      (previousValue, element) => previousValue +
                          (element['additional_fans'] ?? 0) as int,
                    );
                    return Text(
                      'Total number of fans: $totalFans',
                      // style: const TextStyle(fontSize: 18),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return loadingCircularAndText('Loading fans...');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
