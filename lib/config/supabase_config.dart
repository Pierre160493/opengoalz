import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Helper method to retrieve environment-specific variables using a switch case.
  static String _getEnvVariable(String prodKey, String devKey) {
    switch (dotenv.env['ENV']) {
      case 'production':
        return dotenv.env[prodKey]!;
      case 'development':
      default:
        return dotenv.env[devKey]!;
    }
  }

  // This getter retrieves the Supabase URL based on the environment (production or development).
  static String get supabaseUrl {
    return _getEnvVariable('SUPABASE_URL_PROD', 'SUPABASE_URL_DEV');
  }

  // This getter retrieves the Supabase API key based on the environment (production or development).
  static String get supabaseKey {
    return _getEnvVariable('SUPABASE_KEY_PROD', 'SUPABASE_KEY_DEV');
  }
}
