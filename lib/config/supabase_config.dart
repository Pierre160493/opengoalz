/// Provides configuration for connecting to Supabase.
///
/// This class exposes the Supabase URL and API key as compile-time constants.
/// For Flutter web builds, these values are injected at build time using
/// the --dart-define argument, which allows you to securely and flexibly
/// provide environment-specific values without hardcoding them in source code.
///
/// Example usage in your build command:
/// flutter build web --release \
///   --dart-define=SUPABASE_URL_PROD=your_url \
///   --dart-define=SUPABASE_KEY_PROD=your_key
///
/// Access these values anywhere in your app via:
///   SupabaseConfig.supabaseUrl
///   SupabaseConfig.supabaseKey
class SupabaseConfig {
  /// The Supabase project URL, injected at build time.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// The Supabase API key, injected at build time.
  static const String supabaseKey = String.fromEnvironment('SUPABASE_KEY');
}
