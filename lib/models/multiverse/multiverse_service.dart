// import 'package:opengoalz/models/multiverse/multiverse.dart';
// import 'package:opengoalz/constants.dart';

// class MultiverseService {
//   static Future<Multiverse?> fromId(int id) async {
//     final stream = supabase
//         .from('multiverses')
//         .stream(primaryKey: ['id'])
//         .eq('id', id)
//         .map((maps) => maps.map((map) => Multiverse.fromMap(map)).first);

//     try {
//       final multiverse = await stream.first;
//       return multiverse;
//     } catch (e) {
//       print('Error fetching multiverse: $e');
//       return null;
//     }
//   }
// }
