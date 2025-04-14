import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archimate/app.dart';
import 'package:archimate/core/providers/supabase_provider.dart';

/// Main entry point for the Archimate application
Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with environment variables
  await initializeSupabase();

  // Run the app wrapped in a ProviderScope for Riverpod
  runApp(const ProviderScope(child: ArchimateApp()));
}
