# Archimate - Project Management for Archonism Architects

**Archimate** is a comprehensive project management application designed specifically for archonism architecture firm. Built with Flutter for Android and leveraging Supabase for backend services (Database, Authentication, Storage), it aims to streamline workflows from client onboarding to project completion and financial tracking.

**Current Status:** [Development]

## Table of Contents

1.  [Overview](#overview)
2.  [Key Features](#key-features)
3.  [Technology Stack](#technology-stack)
4.  [Project Setup](#project-setup)
5.  [Project Structure](#project-structure)
6.  [Instructions for AI Assistant (Windsurf)](#instructions-for-ai-assistant-windsurf)
7.  [Coding Guidelines & Style Guide](#coding-guidelines--style-guide)
8.  [Supabase Integration Notes](#supabase-integration-notes)
9.  [Contribution](#contribution)
10. [License](#license)

## Overview

Archimate provides architects and firms with a dedicated tool to manage the lifecycle of their projects efficiently. It centralizes project information, client details, financial data (quotes, invoices, expenses), and project files, making day-to-day operations smoother and more organized. The primary target platform is Android.

## Key Features

* **Project Management:**
    * Create, update, and track architectural projects.
    * Define project scope, status, deadlines, and assigned team members.
* **Project Planning:**
    * Outline project phases and tasks.
    * Track progress against the plan.
    * Do project planning in Kanban style (To Do, In Progress, Done) with a calendar view.
* **Client Management:**
    * Store and manage client contact details and history.
    * Link clients to specific projects.
* **Quotation Management:**
    * Create, send, and track project quotations.
    * Convert approved quotes into projects or invoices.
* **Invoice Generation:**
    * Generate invoices based on project milestones, timesheets, or quotations.
    * Track invoice status (sent, paid, overdue).
* **Financial Tracking:**
    * Record day-to-day expenses associated with projects or general overhead.
    * Track earnings/payments received for projects.
    * Basic financial summaries per project.
* **File Management:**
    * Upload and associate photos, documents (drawings, permits, contracts), and notes with specific projects.
    * Organized file storage using Supabase Storage.

## Technology Stack

* **Frontend Framework:** Flutter (targeting Android primarily)
* **Programming Language:** Dart
* **Backend as a Service (BaaS):** Supabase
    * **Database:** Supabase Postgres
    * **Authentication:** Supabase Auth
    * **File Storage:** Supabase Storage
* **State Management:** Riverpod
* **Routing:** GoRouter
* **Build Tool:** Flutter SDK / Dart SDK

## Project Setup

1.  **Clone the Repository:**
    ```bash
    git clone [Your Repository URL]
    cd archonism
    ```
2.  **Install Flutter:** Ensure you have the Flutter SDK installed and configured. Refer to the [official Flutter documentation](https://flutter.dev/docs/get-started/install).
3.  **Set up Supabase:**
    * Create a project on [Supabase](https://supabase.com/).
    * In your Supabase project dashboard, go to `Project Settings` > `API`.
    * Find your `Project URL` and `anon public` key.
    * **Crucially:** Do NOT commit API keys directly into the code. Use environment variables or a configuration file (`.env`) that is ignored by Git (`.gitignore`).
    * Create a `.env` file in the project root (and add `.env` to `.gitignore`):
        ```
        SUPABASE_URL=YOUR_SUPABASE_URL
        SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
        ```
    * Use a package like `flutter_dotenv` to load these variables at runtime.
4.  **Define Database Schema:** Set up the required tables in your Supabase database (e.g., `projects`, `clients`, `quotes`, `invoices`, `expenses`, `project_files`, `users`). Define relationships and appropriate Row Level Security (RLS) policies.
5.  **Configure Supabase Storage:** Create buckets in Supabase Storage (e.g., `project-photos`, `project-documents`) and set appropriate access policies.
6.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
7.  **Run the App:**
    ```bash
    flutter run
    ```

## Project Structure

We will follow a feature-first approach combined with layering for clarity:

archonism/
├── android/                 # Android specific files
├── ios/                     # iOS specific files (if ever needed)
├── lib/
│   ├── app.dart             # Main App Widget (MaterialApp/CupertinoApp setup)
│   ├── main.dart            # App entry point
│   ├── core/                # Core utilities, constants, base classes, helpers
│   │   ├── constants/
│   │   ├── error/           # Error handling (failures, exceptions)
│   │   ├── network/         # Network utility (if needed beyond Supabase client)
│   │   ├── providers/       # Global Riverpod providers (Supabase client, Auth state)
│   │   ├── routing/         # App routing configuration (GoRouter)
│   │   └── utils/
│   ├── data/                # Data layer: Models, Repositories, Data Sources
│   │   ├── datasources/     # Data sources (Supabase interactions)
│   │   │   ├── remote/      # Supabase client calls
│   │   │   └── local/       # Local storage/cache (if needed)
│   │   ├── models/          # Data models (e.g., Project, Client)
│   │   └── repositories/    # Abstract repositories
│   ├── features/            # Feature modules (e.g., projects, clients, auth)
│   │   ├── auth/
│   │   │   ├── presentation/  # Widgets, Screens, Riverpod Providers/Notifiers
│   │   │   ├── domain/        # Entities, Use Cases, Repository Interfaces (optional for smaller features)
│   │   │   └── data/          # Data implementation specific to this feature
│   │   ├── projects/
│   │   │   ├── presentation/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── clients/
│   │   │   └── ... (similarly structured)
│   │   ├── invoices/
│   │   │   └── ...
│   │   └── ... (other features)
│   └── presentation/        # Shared UI components, themes, assets
│       ├── shared_widgets/  # Common widgets used across features
│       ├── theme/           # App theme data
│       └── assets/          # Asset constants/paths (though assets folder is top-level)
├── assets/                  # Static assets (images, fonts)
│   ├── images/
│   ├── fonts/
├── test/                    # Automated tests (unit, widget, integration)
├── .env                     # Environment variables (MUST be in .gitignore)
├── .gitignore               # Git ignore file
├── pubspec.yaml             # Project dependencies and metadata
└── README.md                # This file


## Instructions for AI Assistant (Windsurf)

**Windsurf, please adhere strictly to the following when generating code for the Archonism project:**

1.  **Follow the README:** Refer to the [Coding Guidelines & Style Guide](#coding-guidelines--style-guide) and [Project Structure](#project-structure) sections below for all code generation.
2.  **Target Platform:** Assume the primary target is **Android**. Use Material Design components unless otherwise specified.
3.  **Technology Stack:**
    * Use **Flutter** and **Dart**.
    * All backend interactions must use the **Supabase** client (`supabase_flutter` package).
    * State management **MUST** be implemented using **Riverpod**. Do not use Provider, Bloc, GetX, or other state management solutions unless explicitly instructed for a specific, isolated reason. Use `NotifierProvider`, `AsyncNotifierProvider`, `FutureProvider`, `StreamProvider` as appropriate.
    * Use **GoRouter** for navigation. Define routes in the `lib/core/routing/` directory.
4.  **Supabase Interactions:**
    * Implement Supabase calls within the `lib/data/datasources/remote/` directory or feature-specific data sources.
    * Abstract Supabase calls behind Repository interfaces (`lib/data/repositories/` or `lib/features/*/domain/repositories/`).
    * Handle potential Supabase errors gracefully (e.g., using `try-catch` and returning custom Failure objects or using a Result type).
    * Assume appropriate **Row Level Security (RLS)** policies are or will be in place. Code should work with RLS enabled (e.g., fetching data only for the authenticated user).
    * For file uploads/downloads, use `Supabase Storage` methods. Place related logic accordingly.
5.  **Code Generation:**
    * Generate code within the defined **Project Structure**. If unsure where a new file belongs, ask or place it in the most logical feature directory's `presentation`, `domain`, or `data` layer.
    * Create **small, reusable widgets** whenever possible. Place shared widgets in `lib/presentation/shared_widgets/`.
    * Implement **error handling** for user interactions, API calls, and potential failures. Show user-friendly error messages.
    * Generate **model classes** in `lib/data/models/` or `lib/features/*/domain/entities/` with `fromJson`, `toJson` methods, and `copyWith` where applicable. Ensure models are immutable (`final` properties).
    * Use **dependency injection** via Riverpod providers to access repositories, data sources, and notifiers within the UI layer.
6.  **Clarity and Context:**
    * If a request is ambiguous, **ask for clarification** before generating code.
    * When modifying existing code, clearly state **which file** you are modifying and **provide the context** (e.g., the function or class being changed).
    * Break down complex feature requests into smaller, manageable steps if necessary.
7.  **Testing:** While you may not always be asked to write tests, structure the code (using repositories, dependency injection) to be **testable**. If asked, generate unit tests for logic (notifiers, repositories) and widget tests for UI components.

## Coding Guidelines & Style Guide

**Consistency is key. All code MUST adhere to these guidelines:**

1.  **Dart Language:**
    * Follow the official [Effective Dart](https://dart.dev/effective-dart) guidelines strictly (Style, Documentation, Usage, Design).
    * Enable and address all recommended lints: [Dart Linter Rules](https://dart-lang.github.io/linter/lints/). Run `flutter analyze` frequently.
2.  **Formatting:**
    * Use `dart format` on every file before committing. Configure your IDE to format on save.
3.  **Naming Conventions:**
    * `PascalCase` for classes, enums, typedefs, and extensions (`MyClass`, `ProjectType`).
    * `camelCase` for variables, parameters, and function/method names (`projectName`, `calculateTotal()`).
    * `snake_case` for file names and directories (`project_details_screen.dart`, `lib/core/utils/`).
    * `UPPER_SNAKE_CASE` or `SCREAMING_SNAKE_CASE` for constants (`const maxRetries = 3;` -> `const kMaxRetries = 3;` or `static const maxRetries = 3;`). Prefer prefixing with `k` for global constants.
4.  **Code Structure:**
    * Keep classes and functions focused (Single Responsibility Principle).
    * Keep lines under 80-100 characters where practical for readability.
    * Order class members logically: static variables, instance variables, constructors, methods.
5.  **Flutter Widgets:**
    * Prefer `StatelessWidget` over `StatefulWidget` unless mutable state is essential within the widget itself. Manage state via Riverpod.
    * Use `const` constructors for widgets wherever possible to improve performance.
    * Break down large `build` methods into smaller, private helper methods or separate `StatelessWidget`s.
    * Avoid deeply nested widget trees where possible. Refactor into smaller widgets.
6.  **State Management (Riverpod):**
    * Use the appropriate provider type (`Provider`, `FutureProvider`, `StreamProvider`, `StateProvider`, `StateNotifierProvider`, `NotifierProvider`, `AsyncNotifierProvider`). Prefer `NotifierProvider` and `AsyncNotifierProvider` for complex state.
    * Define providers globally (in `lib/core/providers/`) or scoped to features (`lib/features/*/presentation/providers/`).
    * Keep provider logic minimal; delegate complex business logic to repositories or use cases.
    * Widgets should `ref.watch` providers to rebuild on state changes and `ref.read` for one-time reads or calling methods on notifiers within callbacks.
7.  **Error Handling:**
    * Use `try-catch` blocks for operations that can fail (especially I/O, network calls).
    * Consider using a `Result` type (e.g., from `multiple_result` package) or custom `Failure` classes to represent success or error states from repositories/use cases.
    * Propagate errors up to the UI layer to display appropriate feedback to the user (e.g., using `AsyncValue` with Riverpod's `AsyncNotifierProvider`).
8.  **Asynchronous Code:**
    * Use `async/await` for asynchronous operations.
    * Handle `Future`s and `Stream`s correctly, especially within the UI (using `FutureBuilder`, `StreamBuilder`, or Riverpod's async providers).
9.  **Comments and Documentation:**
    * Write comments to explain *why* something is done, not *what* it does (if the code is self-explanatory).
    * Use `///` DartDoc comments for all public classes, methods, and functions. Explain parameters, return values, and potential exceptions.
    * Use `// TODO:` comments for planned work and `// FIXME:` for known issues needing fixes.
10. **Dependencies:**
    * Keep `pubspec.yaml` clean and organized. Remove unused dependencies.
    * Use specific version constraints where necessary, but prefer compatible version ranges (`^`) for libraries following semantic versioning.
11. **Immutability:**
    * Prefer immutable data structures. Use `final` for class fields where possible. Use packages like `freezed` for generating immutable models if desired.

## Supabase Integration Notes

* **Authentication:** Use `supabase_flutter` for handling user sign-up, sign-in, sign-out, and session management. Leverage `AuthChangeEvent` streams.
* **Database:** Use the Supabase Dart client for CRUD operations. Pay close attention to table names, column names, and data types defined in your Supabase schema. Implement data fetching and manipulation within data source classes.
* **Storage:** Use the Supabase Dart client for file uploads (`upload`, `uploadBinary`), downloads (`download`), listing files (`list`), and getting public URLs (`getPublicUrl`) as needed. Ensure storage buckets and policies are correctly configured in the Supabase dashboard.
* **Realtime:** Leverage Supabase Realtime subscriptions (`on`) for features requiring live updates (e.g., project status changes, chat notifications) if implemented.
* **Row Level Security (RLS):** Design database interactions assuming RLS is enabled. Queries should generally only return data owned by or shared with the authenticated user (`auth.uid()`). Ensure RLS policies are set up correctly in Supabase for all tables containing sensitive or user-specific data.

## Contribution

*(Define contribution guidelines if applicable, e.g., branching strategy, pull request process. For now, this might be internal.)*

Currently, development is managed internally by [Your Name/Firm Name].

## License

*(Choose a license - e.g., MIT for open source, or state it's proprietary)*

Proprietary License. Copyright (c) 2025 [Your Name/Firm Name]. All rights reserved. *(Updated Year)*

---