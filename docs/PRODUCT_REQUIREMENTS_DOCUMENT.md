# Product Requirements Document: CoinBag MVP

## 1. Introduction

**Purpose of CoinBag:** CoinBag is a personal finance management application designed to help users track their expenses, manage accounts, and gain insights into their spending habits.

**Purpose of this PRD:** This document outlines the product requirements for the Minimum Viable Product (MVP) of CoinBag. It is derived from the `MVP_development_plan.md` and aims to provide a clear reference for features, functionalities, and unresolved decision points.

## 2. Goals for MVP

The primary goals for the CoinBag MVP are to deliver a functional and reliable application that allows users to:

*   Securely manage their user account.
*   View a dashboard summary of recent spending and account balances.
*   Browse, add, edit, and remove expenses with rich details (categories, tags, recurrence).
*   Manage multiple user-defined accounts with separate balances.
*   Optionally link external bank accounts and sync transactions.
*   Export and import expense data via CSV.
*   Sync all data securely to the cloud (Supabase).
*   Configure application settings, including categories, tags, and basic automation rules.

## 3. Target Audience (Inferred)

Individuals seeking a mobile-first solution to:
*   Track personal expenditures.
*   Organize finances across multiple accounts.
*   Understand spending patterns.
*   Automate aspects of financial data entry.

## 4. Product Features (MVP)

### 4.1. Authentication
*   **User Registration:** Users can sign up for a new CoinBag account.
*   **User Login:** Registered users can sign in to their account.
*   **User Signout:** Users can sign out of their account.
*   **Security:**
    *   Authentication flows must handle errors gracefully and provide clear user feedback.
    *   Supabase Auth settings (e.g., email confirmations, secure password policies) must be verified.
    *   **Open Question:** Is password recovery/reset functionality required for MVP? (Currently noted as "if applicable").
*   **Access Control:** Row Level Security (RLS) policies must be implemented for all Supabase tables, restricting data access based on `auth.uid()`.
*   **Error Handling:** Consistent and user-friendly error messages for all authentication-related exceptions.

### 4.2. Dashboard
*   **Summary View:** Display a summary of recent spending and account balances.
    *   Data must be fetched from the backend (`fetch_dashboard_info` Supabase function/view), not mock data.
*   **Spending Chart:** Visualize spending trends using real data.
*   **Upcoming Bills:** Display upcoming bills derived from recurring expenses.
*   **Account Balances Display:** Summarize balances from user-defined accounts.
    *   **Open Question:** How should "total assets and liabilities" be presented, if this distinction is applicable for MVP?
*   **Backend Data Aggregation (`fetch_dashboard_info`):**
    *   Aggregate total spending over a defined period.
        *   **Open Question:** What is the specific "defined period" for total spending (e.g., last 30 days is a suggestion)?
    *   Aggregate balances from user-defined accounts.
    *   Aggregate information for "Upcoming Bills" from recurring expenses.
    *   RLS must protect this function/view.

### 4.3. Expense Management
*   **Add Expense:**
    *   Users can add new expenses with fields for description, amount, date, associated user-defined account, category, tags, and recurrence.
    *   Form validation for required fields (description, amount, date).
    *   New expenses are persisted via `SupabaseApiService.addExpense`.
*   **Edit Expense:**
    *   Users can edit existing expenses.
    *   Edit flow pre-fills data from the existing expense.
    *   Changes are persisted via `SupabaseApiService.editExpense`.
*   **Remove Expense:**
    *   Users can remove expenses with a confirmation step.
    *   Expenses are removed via `SupabaseApiService.removeExpense`.
*   **Browse Expenses:**
    *   Display a list of expenses with key details (description, amount, date, category, tags).
    *   Implement pagination for efficient loading of large numbers of expenses (client-side UI and backend `fetchExpenses` method).
    *   **Open Question:** What is the priority for implementing filtering/sorting by category or tags for MVP? (Currently "Optional for MVP, based on priority").
*   **Rich Expense Details:**
    *   **Categories:**
        *   Assign a category to an expense from a list of existing categories.
        *   Selected category is persisted with the expense.
        *   `expenses` table requires a column for category linkage.
        *   **Open Question:** Should categories be fetched from a dedicated settings source or a shared service, especially if synced via Supabase? (Potential architectural decision).
    *   **Tags:**
        *   Assign multiple tags to an expense (select existing or create new).
        *   Selected tags are persisted with the expense (e.g., `TEXT[]` in Supabase).
        *   **Open Question:** Similar to categories, how should tags be fetched/managed if synced? (Potential architectural decision).
    *   **Recurring Expenses:**
        *   Mark an expense as recurring with a defined interval (e.g., `recurringIntervalDays`).
        *   Recurrence data is saved with the expense.
        *   Recurring expenses should be identifiable in lists.
        *   **Open Question:** How detailed should forecasting based on future occurrences of recurring expenses be for MVP dashboard/views?

### 4.4. Account Management (User-defined Accounts)
*   **View Accounts:** Users can view a list of their user-defined accounts (e.g., "Cash Wallet," "Savings") with names and current balances.
*   **Create Accounts:** Users can create new user-defined accounts with a name and initial balance.
*   **Edit Accounts:** Users can edit the names of their user-defined accounts.
*   **Account Balances:**
    *   Displayed balance calculated as `debitBalance - creditBalance`.
    *   Balances must automatically update when associated expenses are added, edited, or deleted.
    *   **Decision Point:** Mechanism for updating account balances:
        1.  Database Triggers on `expenses` table (Recommended in plan).
        2.  Application Logic in `SupabaseApiService` (More prone to issues).
*   **UI for User Accounts:**
    *   **Open Question/Potential Conflict:** The `MVP_development_plan.md` states: "A new screen/section might be needed for user-defined accounts or this needs to be integrated into the existing `AccountScreen` (currently focused on bank accounts) if it's meant to show both." This needs clarification on UI structure.
*   **Data Storage (`accounts` table):**
    *   Schema: `id (PK)`, `user_id (FK to auth.users)`, `name (TEXT)`, `debit_balance (NUMERIC)`, `credit_balance (NUMERIC)`, `created_at`.
    *   RLS for user-only access.
    *   `SupabaseApiService` to include `fetchAccounts(userId)`.
*   **Expense-Account Linking:**
    *   When adding/editing an expense, users must select which user-defined account it belongs to.
    *   `expenses` table requires an `account_id (FK to accounts.id)`.

### 4.5. Bank Account Linking & Transaction Sync (External Provider)
*   **Link Bank Accounts:**
    *   Users can link their external bank accounts using a third-party aggregation service.
    *   **Open Question/Major Task:** A specific third-party bank aggregation service (e.g., Plaid) needs to be decided upon and integrated. The plan notes: "For MVP, a robust mock might be acceptable if a real provider is too complex, but PRD implies real linking." This significantly impacts MVP scope. If mocked, features below are simulated.
    *   Client-side SDK integration for the chosen provider.
    *   Backend exchange of public token for access token; secure storage of access token and item ID (encrypted).
*   **Sync Transactions:**
    *   Users can manually trigger a sync for new transactions for a linked bank account.
    *   Backend fetches transactions using stored access token.
    *   Provider's transaction data is converted into CoinBag `Expense` model objects.
    *   New expenses are saved to the `expenses` table, linked to the user.
    *   **Open Question:** How should synced transactions be mapped to user-defined CoinBag accounts? (e.g., user choice per sync, or map to a generic "synced" account).
    *   Implement de-duplication of transactions using provider's transaction ID.
    *   Update `last_synced` timestamp.
*   **Account Screen UI (`account_screen.dart`):**
    *   Display successfully linked bank accounts.
    *   Initiate the bank linking flow.
    *   Provide a "Sync" button per linked account.
*   **Premium Feature: Multiple Bank Accounts:**
    *   Premium users can link multiple bank accounts; free users have a limit.
    *   **Open Question:** How will premium status be managed/simulated for MVP testing if full IAP is not implemented? (e.g., "simple toggle or mock purchase flow").
*   **Supabase Backend (`bank_syncs` table):**
    *   Schema: `id (PK)`, `user_id (FK)`, `provider_name (TEXT)`, `item_id_encrypted (TEXT)`, `access_token_encrypted (TEXT)`, `account_name_from_provider (TEXT)`, `provider_account_id (TEXT)`, `last_synced (TIMESTAMPZ)`, `created_at (TIMESTAMPZ)`.
    *   **Encryption:** Access tokens and item IDs must be encrypted.
        *   **Decision Point:** Choose encryption method (Supabase Vault or pgsodium suggested).
    *   RLS: Strict RLS; backend functions (SECURITY DEFINER) for handling encrypted data.
*   **Expense Linkage:** `expenses` table to include `bank_sync_id (FK, NULLABLE)` and `provider_transaction_id (TEXT, NULLABLE)` with a unique constraint on this pair.

### 4.6. Data Export/Import (CSV)
*   **Export Expenses:** Users can export their expense data to a CSV file.
*   **Import Expenses:** Users can import expenses from a CSV file.
    *   **Mapping Imported Data:**
        *   `accountId`: User prompted to select an existing CoinBag account.
        *   `category`/`tags`:
            *   **Decision Point:** How to handle categories/tags from CSV not existing in CoinBag: (1) Auto-create them, (2) Map to a default, or (3) Prompt user.
    *   Imported expenses are added via `SupabaseApiService.addExpense`.
*   **Error Handling:** User feedback for success/failure of import/export operations.

### 4.7. Cloud Sync (Supabase Integration)
*   **Primary Sync Mechanism:** Data CRUD operations (expenses, accounts, etc.) are performed via `SupabaseApiService`, ensuring data is synced to Supabase.
*   **Service Roles:**
    *   **Open Question/Potential Logical Conflict:** The role of `CloudSyncService` vs. `SupabaseApiService` needs clarification. The plan states: "If its expense functionality is fully redundant with `SupabaseApiService`, refactor... If `CloudSyncService` is intended for bulk operations or a different sync strategy... document this and implement accordingly." This is an architectural decision point. For MVP, direct Supabase calls via `SupabaseApiService` for CRUD is noted as standard.
*   **Data Consistency & RLS:**
    *   All user-specific tables must have a `user_id` column (or link to a user-owned record).
    *   RLS policies must be verified for ALL tables to ensure users can only access their own data.

### 4.8. Settings
*   **Category Settings:**
    *   Users can view system-default and their user-defined categories.
    *   Users can add, edit, and delete their user-defined categories.
    *   Data stored in `categories` table (`id, user_id FK NULLABLE, name, icon_data, color_value`).
    *   RLS for category management.
*   **Tag Settings:**
    *   Users can view, add, edit, and delete their user-defined tags.
    *   Data stored in `tags` table (`id, user_id FK, name, color_value`).
    *   RLS for tag management.
*   **Automatic Rules (e.g., auto-categorization):**
    *   **Open Question/Decision Point:** What is the precise scope and complexity of rules for MVP? (Plan suggests "description contains 'text'" -> "set category 'X'" or "add tag 'Y'").
    *   **UI:** Users can create, view, and manage rules (e.g., condition: "description contains", action: "set category" or "add tag").
    *   **Persistence:** Rules stored in `rules` table (`id, user_id FK, name, condition_type, condition_value, action_type, action_value`). RLS for user-only access.
    *   **Rule Application Logic:**
        *   **Open Question/Decision Point:** How should rules be applied?
            1.  Client-side: On expense creation/sync, before saving to Supabase (simpler for MVP).
            2.  Backend: Supabase Edge Function/Trigger on expense insertion (more robust, potentially post-MVP).

## 5. Non-Functional Requirements

*   **Security:**
    *   Secure authentication practices.
    *   Strict Row Level Security on all data.
    *   Encryption for sensitive data like bank access tokens.
*   **Error Handling:**
    *   Consistent, user-friendly error reporting across the application.
    *   Graceful handling of API errors and other exceptions.
*   **Performance & Responsiveness:**
    *   Loading indicators during API calls, page loads, and other async operations.
    *   Efficient data loading, especially for lists (pagination).
*   **Usability & UI/UX:**
    *   Intuitive navigation and user flows.
    *   Consistent styling, spacing, and typography (as per `ThemeData`).
    *   Clear feedback for user interactions.
    *   Application should be tested on various device sizes/emulators.
*   **State Management:**
    *   Predictable and maintainable app state.
    *   **Open Question:** Evaluate if `setState` is sufficient for MVP or if a more robust solution (Provider, Riverpod, BLoC) is needed, especially for shared state. (Plan notes `setState` might be okay for simple screens).
*   **Data Consistency:**
    *   Ensure data integrity, especially when operations involve multiple steps or services (e.g., expense creation updating account balances).
*   **Testability:**
    *   Client: Widget tests for key screens and unit tests for services.
    *   Backend: Tests for Supabase functions/triggers (pgTAP suggested as a possibility).
        *   **Open Question:** Decision on using pgTAP or other methods for backend testing.
    *   Thorough manual QA of all MVP features.
*   **Code Quality:**
    *   Clean, maintainable codebase.
    *   Address TODOs relevant to MVP.
    *   Remove unused code/mock data.
    *   Resolve linter warnings/errors.
    *   Add comments for complex logic.

## 6. Summary of Key Open Questions & Decision Points

This section summarizes critical points requiring decisions or further clarification:

*   **Authentication:**
    *   Password recovery/reset for MVP?
*   **Dashboard:**
    *   Specific "defined period" for total spending summary?
    *   Presentation of "total assets and liabilities" if applicable?
*   **Expense Management:**
    *   Priority of filtering/sorting for MVP?
    *   Architectural choice for fetching/managing categories and tags (settings source vs. shared service)?
    *   Detail level for forecasting recurring expenses?
*   **Account Management (User-defined):**
    *   UI structure: New screen for user accounts vs. integration into existing `AccountScreen`?
    *   Mechanism for updating account balances (DB Triggers vs. App Logic)?
*   **Bank Account Linking:**
    *   Choice of third-party bank aggregation service (or use a mock for MVP)? This is a major decision.
    *   Mapping strategy for synced transactions to user-defined accounts?
    *   Management/simulation of Premium status for MVP testing?
    *   Choice of encryption method for bank tokens (Supabase Vault vs. pgsodium)?
*   **Data Import/Export:**
    *   Strategy for handling new categories/tags during CSV import (auto-create, map to default, prompt user)?
*   **Cloud Sync / Service Architecture:**
    *   Role clarification and potential consolidation of `CloudSyncService` vs. `SupabaseApiService`.
*   **Settings (Automatic Rules):**
    *   Precise scope and complexity of rules for MVP?
    *   Rule application logic (Client-side vs. Backend trigger)?
*   **Non-Functional:**
    *   Necessity of a more advanced state management solution beyond `setState` for MVP?
    *   Decision on using pgTAP for backend testing?

## 7. Potential Logical Conflicts to Address

*   **`CloudSyncService` vs. `SupabaseApiService`:** The overlap and distinct responsibilities need to be clearly defined to avoid redundant or conflicting data handling logic.
*   **`AccountScreen` Focus:** The `AccountScreen` was refactored for bank accounts, but user-defined accounts also need a management interface. The PRD needs to solidify whether these are combined or separate, as this impacts UI flow and potentially shared logic.

## 8. Out of Scope for MVP / Future Considerations (from MVP Plan)

*   Full offline support (though foundational Supabase usage should not hinder future implementation).
*   Improved Bank Sync: Background sync.
*   Full In-app Purchases: Native IAP.
*   Push notifications.
*   Shared accounts.
*   Web/desktop versions.
*   Budgeting tool integration.

This document should serve as the primary reference for MVP development. It should be reviewed and updated as decisions are made and requirements evolve. 