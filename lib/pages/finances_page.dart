import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:provider/provider.dart';

import '../classes/club.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const FinancesPage(),
    );
  }

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  late final Stream<List<Map<String, dynamic>>> _financeStream;

  @override
  void initState() {
    _financeStream = supabase
        .from('finances')
        .stream(primaryKey: ['id'])
        .eq('id_club', 1)
        .order('created_at')
        .map((maps) => maps
            .map((map) => {
                  'id': map['id'],
                  'created_at': map['created_at'],
                  'amount': map['amount'],
                  'description': map['description'],
                  // Add more fields here as needed
                })
            .toList());

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);
    sessionProvider.updateClubStream(supabase.auth.currentUser!.id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Club>>(
      stream: Provider.of<SessionProvider>(context).clubStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final clubs = snapshot.data!;
          return Scaffold(
            appBar: CustomAppBar(
                pageName:
                    'Finances of club: ${clubs[Provider.of<SessionProvider>(context).nClubInList].club_name ?? 'No club name'}'),
            // CustomAppBar(clubStream: _clubStream),
            // drawer: AppDrawer(clubStream: _clubStream),
            drawer: const AppDrawer(),
            body: clubs.isEmpty
                ? const Center(child: Text('No clubs found'))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Hello ${clubs[Provider.of<SessionProvider>(context).nClubInList].username} !',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text:
                              'Selected club [${Provider.of<SessionProvider>(context).nClubInList}]: ',
                          style: const TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                              text: clubs[Provider.of<SessionProvider>(context)
                                      .nClubInList]
                                  .club_name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Finances:',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _financeStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final finances = snapshot.data!;
                              print('testPierreG: ${finances.length}');
                              return ListView.builder(
                                itemCount: finances.length,
                                itemBuilder: (context, index) {
                                  final finance = finances[index];
                                  return Card(
                                    margin: const EdgeInsets.all(8),
                                    child: ListTile(
                                      title: Text(finance['description'] ??
                                          'No description'),
                                      subtitle:
                                          Text('Amount: ${finance['amount']}'),
                                      trailing: Text(
                                        'Date: ${DateFormat.yMd().format(DateTime.parse(finance['created_at']))}',
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error occurred: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
