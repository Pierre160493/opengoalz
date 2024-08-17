import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Function to insert a game sub into the database
Future<bool> insertInDB({
  required BuildContext context,
  required String tableName,
  required Map<String, dynamic> data,
}) async {
  try {
    await supabase.from(tableName).insert(data);
    return true;
  } on PostgrestException catch (error) {
    showSnackBar(context, 'PostgreSQL ERROR: ${error.message}',
        Icon(Icons.report, color: Colors.red));
  } catch (error) {
    showSnackBar(context, 'Unknown ERROR: Unexpected error occurred !',
        Icon(Icons.error, color: Colors.red));
  }
  return false;
}

/// Delete from the database
Future<bool> deleteFromDB({
  required BuildContext context,
  required String tableName,
  required Map<String, Object> data,
}) async {
  try {
    await supabase.from(tableName).delete().match(data);
    return true;
  } on PostgrestException catch (error) {
    showSnackBar(context, 'PostgreSQL ERROR: ${error.message}',
        Icon(Icons.report, color: Colors.red));
    return false;
  } catch (error) {
    showSnackBar(context, 'Unknown ERROR: Unexpected error occurred !',
        Icon(Icons.error, color: Colors.red));
    return false;
  }
}

void showSnackBar(BuildContext context, String message, Icon icon) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          icon,
          Text(message),
        ],
      ),
      showCloseIcon: true,
    ),
  );
}
