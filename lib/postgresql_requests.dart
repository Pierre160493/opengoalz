import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Function to insert a game sub into the database
Future<bool> operationInDB(
    BuildContext context, String operationType, String tableName,
    {Map<String, Object?>? data, Map<String, Object>? criteria}) async {
  /// Check if data is present for the INSERT and UPDATE operation
  if (['INSERT', 'UPDATE'].contains(operationType.toUpperCase())) {
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
      default:
        throw Exception(
            'Invalid operation type in the operationInDB function: $operationType');
    }
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
