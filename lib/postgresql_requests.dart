import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Function to insert a game sub into the database
Future<bool> operationInDB(
    BuildContext context, String operationType, String tableName,
    {Map<String, Object?>? data, Map<String, Object>? criteria}) async {
  /// Check if data is present for the INSERT and UPDATE operation
  if (['INSERT', 'UPDATE', 'FUNCTION'].contains(operationType.toUpperCase())) {
    if (data == null) {
      throw Exception(
          'Data is required for the ${operationType} operation in the operationInDB function');
    }
  }
  if (['UPDATE', 'DELETE'].contains(operationType.toUpperCase())) {
    if (criteria == null) {
      throw Exception(
          'Criteria is required for the ${operationType} operation in the operationInDB function');
    }
  }
  try {
    switch (operationType.toUpperCase()) {
      case 'INSERT':
        await supabase.from(tableName).insert(data!);
        break;
      case 'UPDATE':
        await supabase.from(tableName).update(data!).match(criteria!);
        break;
      case 'DELETE':
        await supabase.from(tableName).delete().match(criteria!);
        break;
      case 'FUNCTION':
        await supabase.rpc(tableName, params: data!);
        break;
      default:
        throw Exception(
            'Invalid operation type in the operationInDB function: $operationType');
    }
    return true;
  } on PostgrestException catch (error) {
    print('PostgreSQL ERROR: ${error.message}');
    showSnackBar(context, 'PostgreSQL ERROR: ${error.message}',
        Icon(Icons.report, color: Colors.red));
  } catch (error) {
    print('Unknown ERROR: $error');
    showSnackBar(
        context, 'Unknown ERROR: $error', Icon(Icons.error, color: Colors.red));
  }
  return false;
}

void showSnackBar(BuildContext context, String message, Icon icon) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          icon,
          SizedBox(width: 3.0),
          Text(message),
        ],
      ),
      showCloseIcon: true,
    ),
  );
}

Future<bool> showConfirmationDialog(BuildContext context, String text) async {
  return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text('Confirmation'),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(width: 3.0),
                    Text('Confirm'),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true
                },
              ),
              TextButton(
                child: Row(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    SizedBox(width: 3.0),
                    Text('Cancel'),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false
                },
              ),
            ],
          );
        },
      ) ??
      false;
}
