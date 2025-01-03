import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Function to insert a game sub into the database
Future<bool> operationInDB(
  BuildContext context,
  String operationType,
  String tableName, {
  Map<String, Object?>? data,
  Map<String, Object>? matchCriteria,
  Map<String, List<dynamic>>? inFilterMatchCriteria,
}) async {
  /// Check if data is present for the INSERT and UPDATE operation
  if (['INSERT', 'UPDATE', 'FUNCTION'].contains(operationType.toUpperCase())) {
    if (data == null) {
      throw Exception(
          'Data is required for the ${operationType} operation in the operationInDB function');
    }
  }
  if (['UPDATE', 'DELETE'].contains(operationType.toUpperCase())) {
    if (inFilterMatchCriteria == null && matchCriteria == null) {
      throw Exception(
          'matchCriteria is required for the ${operationType} operation in the operationInDB function');
    }
  }
  try {
    switch (operationType.toUpperCase()) {
      case 'INSERT':
        await supabase.from(tableName).insert(data!);
        break;
      case 'UPDATE':
        if (inFilterMatchCriteria == null) {
          await supabase.from(tableName).update(data!).match(matchCriteria!);
        } else {
          await supabase.from(tableName).update(data!).inFilter(
              inFilterMatchCriteria.entries.first.key,
              inFilterMatchCriteria.entries.first.value);
        }
        break;
      case 'DELETE':
        if (inFilterMatchCriteria == null) {
          await supabase.from(tableName).delete().match(matchCriteria!);
        } else {
          await supabase.from(tableName).delete().inFilter(
              inFilterMatchCriteria.entries.first.key,
              inFilterMatchCriteria.entries.first.value);
        }
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
    context.showSnackBarPostgreSQLError('PostgreSQL ERROR: ${error.message}');
  } catch (error) {
    context.showSnackBarError('Unknown ERROR: $error');
  }
  return false;
}

// Future<bool> operationInDB(
//     BuildContext context, String operationType, String tableName,
//     {Map<String, Object?>? data,
//     Map<String, Object>? matchCriteria,
//     String? matchCriteriaXXX,
//     List<dynamic>? matchCriterias}) async {
//   /// Check if data is present for the INSERT and UPDATE operation
//   if (['INSERT', 'UPDATE', 'FUNCTION'].contains(operationType.toUpperCase())) {
//     if (data == null) {
//       throw Exception(
//           'Data is required for the ${operationType} operation in the operationInDB function');
//     }
//   }
//   if (['UPDATE', 'DELETE'].contains(operationType.toUpperCase())) {
//     if (matchCriteria == null) {
//       throw Exception(
//           'matchCriteria is required for the ${operationType} operation in the operationInDB function');
//     }
//   }
//   try {
//     switch (operationType.toUpperCase()) {
//       case 'INSERT':
//         await supabase.from(tableName).insert(data!);
//         break;
//       case 'UPDATE':
//         // await supabase.from(tableName).update(data!).match(matchCriteria!);
//         await supabase
//             .from(tableName)
//             .update(data!)
//             .inFilter(matchCriteriaXXX!, matchCriterias!);
//         break;
//       case 'DELETE':
//         await supabase.from(tableName).delete().match(matchCriteria!);
//         break;
//       case 'FUNCTION':
//         await supabase.rpc(tableName, params: data!);
//         break;
//       default:
//         throw Exception(
//             'Invalid operation type in the operationInDB function: $operationType');
//     }
//     return true;
//   } on PostgrestException catch (error) {
//     print('PostgreSQL ERROR: ${error.message}');
//     context.showSnackBarPostgreSQLError('PostgreSQL ERROR: ${error.message}');
//   } catch (error) {
//     print('Unknown ERROR: $error');
//     context.showSnackBarError('Unknown ERROR: $error');
//   }
//   return false;
// }
