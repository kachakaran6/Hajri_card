# Hajri Card

Hajri Card (Attendance Card) is a comprehensive Flutter application designed for contractors to efficiently manage their workers, projects, attendance, and payments. It streamlines day-to-day operations by replacing traditional paper-based attendance registers with a digital, real-time, cloud-synchronized platform.

## Features & User Flow

The application flow is straightforward and designed for ease of use by contractors.

### 1. Authentication
*   **Sign Up / Login:** The contractor starts by creating an account or logging in. 
*   **Profile Setup:** Initial profile configuration sets up the contractor's workspace.

### 2. Dashboard
*   **Overview:** Upon logging in, the contractor lands on the Dashboard. This provides a high-level summary of active projects, total workers present today, and recent activities.
*   **Quick Actions:** From the dashboard, the user can quickly navigate to Projects, Workers, Attendance, or Payments.

### 3. Project Management
*   **Create Projects:** Contractors can add new construction or work sites, defining the location, start date, and status.
*   **Manage Sites:** This allows the contractor to group workers based on the site they are currently working on.

### 4. Worker Management
*   **Onboard Workers:** The contractor can add laborers to the system, capturing details like their name, daily wage, overtime rate, contact info, and bank details.
*   **Worker Profiles:** Each worker gets a dedicated profile showing their assigned project, total attendance, and outstanding balances.

### 5. Attendance Tracking (Hajri)
*   **Daily Marking:** This is the core feature. Contractors select a date and project, then mark workers as Present, Absent, Half Day, Leave, etc.
*   **Overtime & Bonuses:** While marking attendance, the contractor can also log overtime hours, add bonuses, or record deductions for that specific day.
*   **Automatic Wage Calculation:** Based on the attendance status, overtime rates, and base daily wage, the app automatically calculates the net payable amount for the day.

### 6. Payments & Advances
*   **Record Transactions:** Contractors can record payments made to workers (advances or salary settlements).
*   **Ledger:** The app maintains a running ledger for each worker, balancing the calculated daily wages against the recorded payments to show the current outstanding balance.

### 7. Reports
*   **Generate Reports:** The app allows generating detailed reports (potentially exportable as PDFs) for workers' attendance and payment histories over specific periods.

## Technology Stack

*   **Frontend Framework:** Flutter (Dart)
*   **State Management:** Riverpod (`hooks_riverpod`)
*   **Backend & Database:** Supabase (PostgreSQL, Authentication, Realtime DB)
*   **Routing:** `go_router`
*   **Local Caching:** Hive (`hive_flutter`) for offline settings and fast retrieval.
*   **UI/UX:** Custom theme definitions with support for Light and Dark modes.

## Setup Instructions

1.  Clone the repository.
2.  Ensure Flutter SDK (version ^3.11.5) is installed.
3.  Run `flutter pub get` to install dependencies.
4.  Configure Supabase credentials in `lib/core/config/supabase_config.dart`.
5.  Run the app using `flutter run`.
