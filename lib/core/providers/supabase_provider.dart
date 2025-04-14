import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for the Supabase auth
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return ref.watch(supabaseClientProvider).auth;
});

/// Provider for the current user
final currentUserProvider = StateProvider<User?>((ref) {
  return ref.watch(supabaseAuthProvider).currentUser;
});

/// Provider for the current session
final currentSessionProvider = StateProvider<Session?>((ref) {
  return ref.watch(supabaseAuthProvider).currentSession;
});

/// Provider for the auth state change stream
final authStateChangeProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseAuthProvider).onAuthStateChange;
});

/// Initialize Supabase
Future<void> initializeSupabase() async {
  await dotenv.load();
  
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: false, // Set to true for development
  );
}
