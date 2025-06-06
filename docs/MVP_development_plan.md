# CoinBag MVP Development Plan

This document outlines the detailed plan to achieve the Minimum Viable Product (MVP) for CoinBag, as defined in `docs/PRD.md`. It has been updated to reflect the current state of the codebase.

## MVP Core Functionality Checklist (from PRD.md)

- [x] View dashboard summary of recent spending and balances
- [x] Browse expenses with pagination
- [x] Add, edit and remove expenses
- [ ] Link bank accounts and sync transactions
- [ ] Premium users can link multiple banks
- [x] Manage multiple accounts with separate balances (backend support exists)
- [x] Export and import data via CSV (service exists, no UI)
- [x] Sync data to the cloud via Supabase
- [ ] Rich expense entry with categories, tags and recurring expenses (partially done)
- [ ] Implement rules for automation (e.g., auto-categorization)

## Detailed Task Breakdown

### 1. Authentication
*   **Status:** **Implemented.** The authentication flow is robust and uses a clean architecture pattern with `AuthRepository` in the domain layer, and `AuthRepositoryImpl` providing the Supabase implementation. This is a more advanced and scalable approach than the `AuthService` mentioned previously. All core features including sign-up, sign-in, sign-out, and password reset are functional. Error handling is comprehensive, with custom exceptions for different failure scenarios. Mock login is also available for testing.
*   **Open Tasks:**
    *   [ ] **[Testing]** Perform final testing on all authentication flows to ensure robustness and a smooth user experience.

### 2. Dashboard (`dashboard_screen.dart`)
*   **PRD Goal:** View dashboard summary of recent spending and balances.
*   **Status:** **Implemented.** The `DashboardScreen` is fully functional. It fetches real data from the backend using a `DashboardRepository` which calls a Supabase RPC function (`fetch_dashboard_info`). It displays the overall balance, a balance-over-time chart using `fl_chart`, and has placeholders for category spending and latest transactions. It also includes a date range selector and handles loading and error states.
*   **Open Tasks:**
    *   [ ] **[UI]** Finalize the UI for category spending and latest transactions.

### 3. Expense Management
*   **PRD Goals:** Browse expenses with pagination. Add, edit and remove expenses. Rich expense entry with categories, tags and recurring expenses.
*   **Status:** **Partially Implemented.**
    *   `ExpensesListScreen`: Fetches and displays real expense data with pagination.
    *   `AddExpenseScreen` & `EditExpenseScreen`: UI exists.
    *   `SupabaseNetworkDataSource`: Has methods for `addExpense`, `fetchExpenses`, `editExpense`, `removeExpense`, all implemented using Supabase RPC functions.
    *   `Expense` model: Supports all necessary fields.
*   **Open Tasks:**
    *   **Add/Edit Expense Screen (`add_expense_screen.dart` and `edit_expense_screen.dart`):**
        *   [ ] **[Client]** Implement form validation.
        *   [ ] **[Client]** Connect UI fields to the `Expense` model and call the corresponding repository methods on save.
        *   **Category & Tag Integration:**
            *   [ ] **[Client]** Implement UI for selecting existing categories and tags.
            *   [ ] **[Client/Backend]** Persist selected category and tags with the expense.

### 4. Account Management (User-defined accounts, not bank accounts)
*   **PRD Goal:** Manage multiple accounts with separate balances.
*   **Status:** **Partially Implemented.**
    *   The backend is ready. The `SupabaseNetworkDataSource` has methods for `addAccount`, `updateAccount` and the `accounts` table exists.
    *   The client-side UI for managing user-defined accounts is not yet implemented. The existing `AccountScreen` is for bank account linking.
*   **Open Tasks:**
    *   **UI for User Accounts:**
        *   [ ] **[Client]** Design and implement a new screen (e.g., `UserAccountsScreen.dart`) to list, create, and edit user-defined accounts.
    *   **Expense-Account Linking:**
        *   [ ] **[Client]** Add an "Account" dropdown in the `AddExpenseScreen`/`EditExpenseScreen` to link an expense to an account.

### 5. Bank Account Linking & Transaction Sync (External Provider)
*   **PRD Goals:** Link bank accounts and sync transactions. Premium users can link multiple banks.
*   **Status:** **Not started.**
    *   The `bank_syncs` table exists and is used in `SupabaseNetworkDataSource`, but the core logic for linking to a third-party provider like Plaid is not implemented.
*   **Open Tasks:**
    *   [ ] **[Client/Backend]** Integrate a third-party bank aggregation service (e.g., Plaid).
    *   [ ] **[Client/Backend]** Implement the `linkBankAccount` and `syncTransactions` flows.
    *   [ ] **[Client]** Build the UI on `AccountScreen` to manage linked accounts and trigger syncs.
    *   [ ] **[Client/Backend]** Implement premium feature checks for linking multiple banks.

### 6. Data Export/Import (`csv_service.dart`)
*   **PRD Goal:** Export and import data via CSV.
*   **Status:** **Partially Implemented.** The `CsvService` with `importCsv` and `exportCsv` methods for `Expense` data is already implemented.
*   **Open Tasks:**
    *   **UI Integration (e.g., in Settings screen):**
        *   [ ] **[Client]** Add "Export to CSV" and "Import from CSV" options in the UI.
        *   [ ] **[Client]** Handle the file picking and the mapping of imported data to accounts.

### 7. Cloud Sync (Supabase Integration)
*   **PRD Goal:** Sync data to the cloud via Supabase.
*   **Status:** **Implemented.** Data is being synced to Supabase. The `SupabaseNetworkDataSource` handles all the communication with the Supabase backend, using RPC functions for most operations.
*   **Open Tasks:**
    *   [ ] **[Backend]** Review and verify all Row Level Security (RLS) policies for all tables to ensure data privacy.

### 8. Settings (`settings_screen.dart`, etc.)
*   **Status:** **Partially Implemented.**
    *   The `SettingsScreen` provides navigation to various settings.
    *   Basic screens for managing Categories and Tags exist.
    *   Sign out functionality is implemented.
*   **Open Tasks:**
    *   [ ] **[Client/Backend]** Implement the logic for creating, updating, and deleting categories and tags.
    *   [ ] **[Client/Backend]** Implement the rules engine for automation.

## Post-MVP (from `plan.md`