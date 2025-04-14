import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Auth state provider that streams the current user
final authStateProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull;
});

/// Auth notifier for handling authentication actions
class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Nothing to initialize
  }

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signUp(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Provider for the auth notifier
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(() {
  return AuthNotifier();
});
