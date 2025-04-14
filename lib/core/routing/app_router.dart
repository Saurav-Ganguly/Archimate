import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:archimate/features/auth/presentation/screens/login_screen.dart';
import 'package:archimate/features/auth/presentation/screens/signup_screen.dart';
import 'package:archimate/features/projects/presentation/screens/project_list_screen.dart';
import 'package:archimate/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:archimate/features/projects/presentation/screens/add_edit_project_screen.dart';
import 'package:archimate/features/clients/presentation/screens/client_list_screen.dart';
import 'package:archimate/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:archimate/features/clients/presentation/screens/add_edit_client_screen.dart';
import 'package:archimate/features/invoices/presentation/screens/invoice_list_screen.dart';
import 'package:archimate/features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'package:archimate/features/invoices/presentation/screens/add_edit_invoice_screen.dart';
import 'package:archimate/core/providers/auth_provider.dart';

/// Provider for the app router
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Check if the user is logged in
      final isLoggedIn = authState.valueOrNull != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      
      // If not logged in and not going to login or signup, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToSignup) {
        return '/login';
      }
      
      // If logged in and going to login, redirect to home
      if (isLoggedIn && (isGoingToLogin || isGoingToSignup)) {
        return '/';
      }
      
      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const ProjectListScreen(),
        routes: [
          // Project routes
          GoRoute(
            path: 'projects',
            name: 'projects',
            builder: (context, state) => const ProjectListScreen(),
          ),
          GoRoute(
            path: 'projects/add',
            name: 'add-project',
            builder: (context, state) => const AddEditProjectScreen(),
          ),
          GoRoute(
            path: 'projects/edit/:id',
            name: 'edit-project',
            builder: (context, state) {
              final projectId = state.pathParameters['id']!;
              return AddEditProjectScreen(projectId: projectId);
            },
          ),
          GoRoute(
            path: 'projects/:id',
            name: 'project-detail',
            builder: (context, state) {
              final projectId = state.pathParameters['id']!;
              return ProjectDetailScreen(projectId: projectId);
            },
          ),
          
          // Client routes
          GoRoute(
            path: 'clients',
            name: 'clients',
            builder: (context, state) => const ClientListScreen(),
          ),
          GoRoute(
            path: 'clients/add',
            name: 'add-client',
            builder: (context, state) => const AddEditClientScreen(),
          ),
          GoRoute(
            path: 'clients/edit/:id',
            name: 'edit-client',
            builder: (context, state) {
              final clientId = state.pathParameters['id']!;
              return AddEditClientScreen(clientId: clientId);
            },
          ),
          GoRoute(
            path: 'clients/:id',
            name: 'client-detail',
            builder: (context, state) {
              final clientId = state.pathParameters['id']!;
              return ClientDetailScreen(clientId: clientId);
            },
          ),
          
          // Invoice routes
          GoRoute(
            path: 'invoices',
            name: 'invoices',
            builder: (context, state) => const InvoiceListScreen(),
          ),
          GoRoute(
            path: 'invoices/add',
            name: 'add-invoice',
            builder: (context, state) => const AddEditInvoiceScreen(),
          ),
          GoRoute(
            path: 'invoices/add/project/:projectId',
            name: 'add-invoice-for-project',
            builder: (context, state) {
              final projectId = state.pathParameters['projectId']!;
              return AddEditInvoiceScreen(projectId: projectId);
            },
          ),
          GoRoute(
            path: 'invoices/add/client/:clientId',
            name: 'add-invoice-for-client',
            builder: (context, state) {
              final clientId = state.pathParameters['clientId']!;
              return AddEditInvoiceScreen(clientId: clientId);
            },
          ),
          GoRoute(
            path: 'invoices/edit/:id',
            name: 'edit-invoice',
            builder: (context, state) {
              final invoiceId = state.pathParameters['id']!;
              return AddEditInvoiceScreen(invoiceId: invoiceId);
            },
          ),
          GoRoute(
            path: 'invoices/:id',
            name: 'invoice-detail',
            builder: (context, state) {
              final invoiceId = state.pathParameters['id']!;
              return InvoiceDetailScreen(invoiceId: invoiceId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('No route defined for ${state.uri.path}'),
      ),
    ),
  );
});
