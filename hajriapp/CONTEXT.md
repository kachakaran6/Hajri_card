# Developer Context: Hajri Card

This document provides a technical overview of the Hajri Card application. It is designed to help new developers quickly understand the architecture, data flow, and where key external services (like Supabase) are integrated.

## Project Structure

The codebase is organized using a feature-based architecture within the `lib/` directory:

```text
lib/
├── core/                   # Core utilities, routing, theme, and config (e.g., SupabaseConfig)
├── features/               # Contains all application features
│   ├── attendance/         # Logic for marking and viewing attendance
│   ├── auth/               # Authentication and user profiles
│   ├── dashboard/          # Main landing screen and summary widgets
│   ├── payments/           # Financial transactions and worker ledgers
│   ├── projects/           # Management of construction/work sites
│   ├── reports/            # PDF report generation
│   ├── settings/           # User preferences and app settings
│   └── workers/            # Worker profile management
└── main.dart               # App entry point and Riverpod ProviderScope
```

Each feature folder typically contains:
*   `models/`: Freezed data classes (e.g., `worker.dart`, `project.dart`).
*   `presentation/`: UI screens and widgets.
*   `repositories/`: Data access layer communicating with Supabase.
*   `providers/`: Riverpod state notifiers and providers.

## Supabase Integration

Supabase is the primary backend for this application, handling Authentication and Database operations. The integration is heavily concentrated in the `repositories` directory of each feature.

### 1. Initialization
Supabase is initialized in `lib/main.dart` before `runApp()`, using credentials defined in `lib/core/config/supabase_config.dart`.

### 2. Database Tables & Repositories
The application communicates with the following Supabase tables:

*   **`users` (or auth profile):** Managed via `auth_repository.dart`. Handles contractor sign-up, login, and profile updates.
*   **`projects`:** Managed via `projects_repository.dart`. Stores construction site details. Linked to the contractor.
*   **`workers`:** Managed via `workers_repository.dart`. Stores laborer details, base wages, and bank info. Linked to the contractor.
*   **`attendance`:** Managed via `attendance_repository.dart`. Records daily presence/absence.
*   **`daily_wages`:** Also managed primarily via `attendance_repository.dart`. When attendance is marked, a trigger or the repository logic automatically creates a corresponding `daily_wages` record, calculating the net pay based on `status`, `overtime`, `bonus`, and `deduction`.
*   **`transactions`:** Managed via `transactions_repository.dart`. Records monetary advances and final payments made to workers.

### 3. Data Flow Example: Marking Attendance

To understand how the app interacts with the backend, consider the flow of marking attendance:

1.  **UI Interaction:** The user taps a worker's status on the `attendance_screen.dart`.
2.  **State Provider:** The UI calls a method on the `AttendanceNotifier` (a Riverpod StateNotifier).
3.  **Repository Call:** The provider invokes `saveAttendance()` on the `AttendanceRepositoryImpl`.
4.  **Supabase API:**
    *   The repository creates an `Attendance` object and calls `supabase.from('attendance').upsert(...)`.
    *   It then calculates the daily wage based on the worker's base rate and the attendance status (e.g., Half Day = 0.5 * wage).
    *   It creates a `DailyWage` object and calls `supabase.from('daily_wages').upsert(...)`.
5.  **Realtime Updates:** The UI listens to a Supabase stream (`supabase.from('attendance').stream(...)`) in the `AttendanceNotifier`. As soon as the upsert completes, the stream pushes the new data, and Riverpod automatically rebuilds the UI.

## State Management (Riverpod)

The app relies heavily on `hooks_riverpod`.
*   **Streams:** Most data is fetched using Supabase streams, wrapped in `StateNotifier` classes, making the app reactive. Changes in the database instantly reflect on the screen without manual pull-to-refresh.
*   **Dependency Injection:** Repositories are provided via standard `Provider` instances (e.g., `attendanceRepositoryProvider`), making them easily mockable for testing.

## Local Storage (Hive)

While Supabase handles all relational business data, `Hive` is used for lightweight, synchronous local storage. Currently, it is initialized in `main.dart` specifically to store user preferences like the `theme_mode` (light/dark).
