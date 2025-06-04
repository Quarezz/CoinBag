# CoinBag MVP Development Plan

This document outlines the detailed plan to achieve the Minimum Viable Product (MVP) for CoinBag, as defined in `docs/PRD.md`.

## MVP Core Functionality Checklist (from PRD.md)

- [ ] View dashboard summary of recent spending and balances
- [ ] Browse expenses with pagination
- [ ] Add, edit and remove expenses
- [ ] Link bank accounts and sync transactions
- [ ] Premium users can link multiple banks
- [ ] Manage multiple accounts with separate balances
- [ ] Export and import data via CSV
- [ ] Sync data to the cloud via Supabase
- [ ] Rich expense entry with categories, tags and recurring expenses
- [ ] Implement rules for automation (e.g., auto-categorization)

## Detailed Task Breakdown

### 1. Authentication (Largely Complete)
*   **Status:** Integrated with Supabase Auth. `AuthService` handles login, signup, signout. Mock login also available.
*   **Open Tasks:**
    *   [x] **[Client/Backend]** Review and test edge cases:
        *   **Requirement:** Ensure all authentication flows (sign up, sign in, sign out, password recovery/reset if applicable) are robust and handle errors gracefully.
        *   **Client:** Test UI feedback for various scenarios (e.g., incorrect password, email already exists, network errors). Verify state changes correctly (e.g., user is redirected to appropriate screen after login/logout).
        *   **Backend:** Verify Supabase Auth settings (e.g., email confirmations, secure passwords policy). Ensure Row Level Security (RLS) policies are in place for all tables, restricting access based on `auth.uid()`.
    *   [x] **[Client]** Ensure consistent error handling for auth exceptions:
        *   **Requirement:** Display user-friendly error messages for all `AuthException` types from Supabase (and any other auth-related errors).
        *   **Implementation:** Use `try-catch` blocks around calls to `AuthService`. Display errors in SnackBars or dialogs. Avoid showing raw error messages to the user.
*   **Updates:** Added password reset option on the login screen and implemented comprehensive error messages for sign-in and sign-up failures .

### 2. Dashboard (`dashboard_screen.dart`)
*   **PRD Goal:** View dashboard summary of recent spending and balances.
*   **Status:** Basic dashboard screen exists. Displays a spending chart and upcoming bills using mock data.
*   **Open Tasks:**
    *   **Data Integration:**
        *   [ ] **[Client/Backend]** Integrate `SupabaseApiService.fetchDashboardInfo` to get real data:
            *   **Requirement:** The dashboard should display dynamic data fetched from the backend, not mock data.
            *   **Client:** Modify `DashboardScreen` to call a new method in `SupabaseApiService` (e.g., `fetchDashboardSummary`). Update the screen's state with the fetched data.
            *   **Backend:** Create a Supabase database function (RPC) named `fetch_dashboard_info` (as mentioned in PRD) or a view. This function should aggregate:
                *   Total spending over a defined period (e.g., last 30 days).
                *   Balances from user-defined accounts (sum of `debitBalance - creditBalance` from the `accounts` table for the current user).
                *   Information for "Upcoming Bills" (derived from recurring expenses).
                *   Ensure RLS protects this function/view.
        *   [ ] **[Client]** Modify `SpendingChart` to accept and display real spending data:
            *   **Requirement:** The chart should visualize actual spending trends.
            *   **Implementation:** Update the `SpendingChart` widget to accept a list of data points (e.g., date and amount) and render them. This data will come from the `fetchDashboardInfo` call.
        *   [ ] **[Client]** Replace mock `_upcomingBills` with real data:
            *   **Requirement:** Show actual upcoming bills based on recurring expenses.
            *   **Implementation:** Process the recurring expenses data fetched via `fetchDashboardInfo`. Calculate next due dates and amounts for upcoming bills. Update the UI to list these bills.
    *   **Account Balances:**
        *   [ ] **[Client]** Display a summary of balances from user-defined accounts:
            *   **Requirement:** Users should see an overview of their account balances on the dashboard.
            *   **Implementation:** Use the aggregated balance data from `fetchDashboardInfo`. Display this clearly, perhaps separating total assets and liabilities if applicable.

### 3. Expense Management
*   **PRD Goals:** Browse expenses with pagination. Add, edit and remove expenses. Rich expense entry with categories, tags and recurring expenses.
*   **Status:**
    *   `ExpensesListScreen`: Basic structure exists.
    *   `AddExpenseScreen`: Basic UI structure exists with text fields.
    *   `SupabaseApiService`: Has methods for `addExpense`, `fetchExpenses`, `editExpense`, `removeExpense`.
    *   `Expense` model: Supports ID, description, amount, date, accountId, category, tags, recurringIntervalDays.
*   **Open Tasks:**
    *   **Add/Edit Expense Screen (`add_expense_screen.dart` and new Edit Screen/Dialog):**
        *   [ ] **[Client]** Implement form handling and validation:
            *   **Requirement:** Ensure users provide valid data for expenses.
            *   **Implementation:** Use `Form` widget and `TextFormField` validators for fields like description (non-empty), amount (numeric, positive), and date.
        *   [ ] **[Client]** Connect UI fields to the `Expense` model for creation and editing:
            *   **Requirement:** Data entered by the user should be correctly mapped to the `Expense` object.
            *   **Implementation:** When saving, populate an `Expense` object from the form field controllers. For editing, pre-fill form fields from an existing `Expense` object.
        *   [ ] **[Client]** Call `SupabaseApiService.addExpense` on save for new expenses:
            *   **Requirement:** New expenses must be persisted to the backend.
            *   **Implementation:** On successful form validation for a new expense, call `SupabaseApiService.addExpense` with the populated `Expense` object. Handle success (e.g., navigate back, show confirmation) and errors (e.g., show error message).
        *   [ ] **[Client]** Create an Edit Expense flow/screen and call `SupabaseApiService.editExpense` on save:
            *   **Requirement:** Users must be able to modify existing expenses.
            *   **Implementation:** Create a new screen or dialog for editing, pre-filled with expense data. On save, call `SupabaseApiService.editExpense`. Handle success and errors.
        *   **Category Integration:**
            *   [ ] **[Client]** Allow selection from existing categories:
                *   **Requirement:** Users should be able to assign a category to an expense.
                *   **Implementation:** In `AddExpenseScreen`/Edit screen, add a dropdown or selection UI. Fetch categories (from `CategorySettingsScreen`'s source or a shared service if categories are synced via Supabase).
            *   [ ] **[Client/Backend]** Persist selected category with the expense:
                *   **Client:** Ensure the selected category's ID or name is included in the `Expense` object sent to `SupabaseApiService`.
                *   **Backend:** The `expenses` table in Supabase needs a column (e.g., `category_id` or `category_name`) to store this. Ensure `addExpense` and `editExpense` in `SupabaseApiService` correctly map this.
        *   **Tag Integration:**
            *   [ ] **[Client]** Allow selection/creation of tags:
                *   **Requirement:** Users should be able to assign multiple tags to an expense.
                *   **Implementation:** In `AddExpenseScreen`/Edit screen, add a UI for selecting existing tags (from `TagSettingsScreen`'s source or a shared service) or creating new ones dynamically. A chip-based input could work.
            *   [ ] **[Client/Backend]** Persist selected tags with the expense:
                *   **Client:** Ensure the list of selected tag names or IDs is included in the `Expense` object.
                *   **Backend:** The `expenses` table in Supabase needs a column for tags (e.g., `tags TEXT[]` if using a PostgreSQL array). Ensure `addExpense` and `editExpense` handle this.
        *   **Recurring Expense:**
            *   [ ] **[Client]** Provide UI to set `recurringIntervalDays`:
                *   **Requirement:** Users should be able to mark an expense as recurring.
                *   **Implementation:** Add a switch or dropdown in `AddExpenseScreen`/Edit screen to enable recurrence and input `recurringIntervalDays` (e.g., 7 for weekly, 30 for monthly).
            *   [ ] **[Client/Backend]** Ensure recurrence data is saved with the expense:
                *   **Client:** Include `recurringIntervalDays` in the `Expense` object.
                *   **Backend:** The `expenses` table needs a `recurring_interval_days INTEGER NULLABLE` column.
    *   **Expenses List Screen (`expenses_list_screen.dart`):**
        *   [ ] **[Client]** Call `SupabaseApiService.fetchExpenses` to load real expense data:
            *   **Requirement:** The screen must display actual expenses for the logged-in user.
            *   **Implementation:** On screen initialization, call `fetchExpenses`. Handle loading states and display fetched expenses in a `ListView`.
        *   [ ] **[Client]** Implement pagination in `fetchExpenses` and the UI:
            *   **Requirement:** Efficiently load expenses for users with many entries.
            *   **Client:** Modify UI to support infinite scrolling or next/previous page buttons. Pass `page` and `pageSize` parameters to `fetchExpenses`.
            *   **Backend (SupabaseApiService):** Ensure `fetchExpenses` method uses `range(from, to)` for pagination.
        *   [ ] **[Client]** Display expense details (description, amount, date, category, tags):
            *   **Requirement:** Each list item should clearly show key expense information.
            *   **Implementation:** Design `ListTile` or custom widget to display all relevant fields from the `Expense` object.
        *   [ ] **[Client]** Add UI elements to trigger editing of an expense:
            *   **Requirement:** Allow users to navigate to the edit flow.
            *   **Implementation:** Add an edit icon/button to each expense item. On tap, navigate to the Edit Expense screen, passing the `Expense` object.
        *   [ ] **[Client]** Add UI elements to trigger removal of an expense with confirmation:
            *   **Requirement:** Allow users to delete expenses securely.
            *   **Implementation:** Add a delete icon/button. On tap, show a confirmation dialog. If confirmed, call `SupabaseApiService.removeExpense` and update the list.
    *   **Rich Expense Features:**
        *   [ ] **[Client]** Implement filtering/sorting by category or tags (Optional for MVP, based on priority):
            *   **Requirement:** Enhance expense browsing.
            *   **Implementation:** Add UI controls (dropdowns, chips) to select filter criteria. Modify `fetchExpenses` calls to include these filters if Supabase service supports it.
        *   [ ] **[Client/Backend]** Consider how recurring expenses impact views:
            *   **Requirement:** Recurring expenses should be clearly identifiable, and their future occurrences might be relevant for forecasting.
            *   **Client:** Potentially add an icon or specific styling for recurring expenses in the list.
            *   **Backend:** The `fetch_dashboard_info` function should use `recurring_interval_days` and the `date` of the last instance to project upcoming bills.

### 4. Account Management (User-defined accounts, not bank accounts)
*   **PRD Goal:** Manage multiple accounts with separate balances.
*   **Status:**
    *   `Account` model exists (id, name, debitBalance, creditBalance).
    *   `SupabaseApiService` has `addAccount`, `updateAccount`.
    *   `AccountScreen` has been refactored to focus on *bank* accounts. A new screen/section might be needed for user-defined accounts or this needs to be integrated into the existing `AccountScreen` if it's meant to show both. For now, assuming `Account` model refers to user-defined accounts distinct from Plaid-linked ones.
*   **Open Tasks:**
    *   **UI for User Accounts:**
        *   [ ] **[Client]** Design and implement a new screen (e.g., `UserAccountsScreen.dart`) or a section in `SettingsScreen` to list user-defined accounts (e.g., "Cash Wallet", "Primary Savings").
            *   **Requirement:** Users need a dedicated place to manage their internal accounts.
            *   **Implementation:** Create a new `StatefulWidget`. Fetch and display accounts using `ListView.builder`. Each item should show account name and balance.
        *   [ ] **[Client]** Allow creation of new user-defined accounts:
            *   **Requirement:** Users should be able to add new accounts.
            *   **Implementation:** Add a FAB or button to navigate to a new "Add Account" screen/dialog. This form should take `name` and `initialBalance`. On save, call `SupabaseApiService.addAccount`.
        *   [ ] **[Client]** Allow editing names of user-defined accounts:
            *   **Requirement:** Users should be able to correct or update account names.
            *   **Implementation:** Add an edit option per account in the list. Navigate to an edit form (can reuse "Add Account" screen in an edit mode). Call `SupabaseApiService.updateAccount`.
        *   [ ] **[Client]** Display balances for these accounts:
            *   **Requirement:** Balances should be clearly visible and updated.
            *   **Implementation:** The `Account` model has `debitBalance` and `creditBalance`. The displayed balance should be `debitBalance - creditBalance`. This should update when expenses linked to this account are added/modified. (This implies expense addition needs to update account balances, or balances are calculated dynamically).
    *   **Data Storage & Logic:**
        *   [ ] **[Client/Backend]** `SupabaseApiService`: Add `fetchAccounts(userId)` method:
            *   **Requirement:** Retrieve all user-defined accounts for the current user.
            *   **Client:** Call this method in `UserAccountsScreen`.
            *   **Backend:** `SupabaseApiService` method should select from the `accounts` table where `user_id` matches the current authenticated user. RLS must be in place on `accounts` table.
        *   [ ] **[Backend]** `accounts` table schema:
            *   **Requirement:** Ensure the `accounts` table in Supabase has `id (PK)`, `user_id (FK to auth.users)`, `name (TEXT)`, `debit_balance (NUMERIC)`, `credit_balance (NUMERIC)`, `created_at`.
        *   [ ] **[Client/Backend]** Expense assignment to accounts:
            *   **Requirement:** When adding/editing an expense, users must select which user-defined account it belongs to.
            *   **Client:** Add an "Account" dropdown in the `AddExpenseScreen`/Edit screen, populated by `fetchAccounts`.
            *   **Backend:** The `expenses` table needs an `account_id (FK to accounts.id)` column. `SupabaseApiService.addExpense/editExpense` must handle this.
        *   [ ] **[Backend]** Update account balances when expenses are CRUD:
            *   **Requirement:** Account balances must reflect associated expenses.
            *   **Implementation (Choose one):**
                *   **Option 1 (Database Triggers - Recommended for consistency):** Create Supabase database triggers on the `expenses` table. After insert, update, or delete of an expense, update the `debit_balance` or `credit_balance` of the corresponding row in the `accounts` table.
                *   **Option 2 (Application Logic):** In `SupabaseApiService`, after an expense is added/updated/deleted, make another call to update the balances in the `accounts` table. This is more prone to race conditions or missed updates.

### 5. Bank Account Linking & Transaction Sync (External Provider)
*   **PRD Goals:** Link bank accounts and sync transactions. Premium users can link multiple banks.
*   **Status:**
    *   `BankSyncService`: Placeholders. `IapService`: Mocked. `AccountScreen`: Basic UI. PRD mentions `bank_syncs` table.
*   **Open Tasks:**
    *   **Core Bank Linking (`BankSyncService`):**
        *   [ ] **[Client/Backend]** **Provider Integration (Major Task - e.g., Plaid):**
            *   **Requirement:** Decide on and integrate a third-party bank aggregation service. For MVP, a robust mock might be acceptable if a real provider is too complex, but PRD implies real linking.
            *   **Client:** Implement the client-side aspects of the chosen provider's SDK (e.g., initializing Plaid Link to get a `public_token`).
            *   **Backend:** Create Supabase Edge Functions or use `SupabaseApiService` to:
                *   Exchange the provider's `public_token` for an `access_token` (e.g., Plaid's `/item/public_token/exchange`).
                *   Securely store the `access_token` and `item_id` (from Plaid) in the `bank_syncs` table, associated with the `user_id`. **Never expose access_tokens to the client after exchange.**
                *   Implement functions to fetch accounts (`/accounts/get` in Plaid) and transactions (`/transactions/sync` or `/transactions/get` in Plaid) using the stored `access_token`.
        *   [ ] **[Client/Backend]** `BankSyncService.linkBankAccount(providerToken)`:
            *   **Requirement:** Finalize the process of linking a new bank.
            *   **Client:** Call this service method after the provider's client-side flow is complete (e.g., Plaid Link `onSuccess` gives a `public_token`).
            *   **Backend (via SupabaseApiService or Edge Function called by BankSyncService):**
                *   Take the `public_token`.
                *   Exchange it for an `access_token` and `item_id`.
                *   Store these securely in the `bank_syncs` table, along with `user_id`, provider name (e.g., "Plaid"), and any relevant metadata.
                *   Return success/failure to the client.
        *   [ ] **[Client/Backend]** `BankSyncService.syncTransactions(linkedAccountId)`:
            *   **Requirement:** Fetch new transactions for a specific linked bank account.
            *   **Client:** User triggers this from `AccountScreen`.
            *   **Backend (via SupabaseApiService or Edge Function):**
                *   Retrieve the `access_token` for the given `linkedAccountId` (which might be your internal ID for a row in `bank_syncs`).
                *   Call the provider's API to fetch transactions (e.g., Plaid's `/transactions/sync`).
                *   Convert provider's transaction data into CoinBag `Expense` model objects. Map fields carefully.
                *   Save these new expenses to the `expenses` table via `SupabaseApiService.addExpense`. Ensure they are associated with the correct CoinBag user-defined account (user might need to choose which internal account to map this bank feed to, or it maps to a generic "synced" account).
                *   Implement de-duplication: Store the provider's transaction ID and check against it before inserting to avoid duplicates. Update `last_synced` timestamp in `bank_syncs`.
    *   **Account Screen UI (`account_screen.dart`):**
        *   [ ] **[Client]** `_loadAccounts`:
            *   **Requirement:** Display successfully linked bank accounts.
            *   **Implementation:** Call a new method in `SupabaseApiService` (e.g., `fetchLinkedBankAccounts`) that queries the `bank_syncs` table (or a view joining with `accounts` if bank syncs are mapped to internal accounts) for the current user.
        *   [ ] **[Client]** `_addBankAccount`:
            *   **Requirement:** Initiate the bank linking flow.
            *   **Implementation:** Trigger the chosen provider's client-side SDK flow (e.g., open Plaid Link).
        *   [ ] **[Client]** `Sync Button` on list item:
            *   **Requirement:** Allow manual sync for a specific bank.
            *   **Implementation:** Call `BankSyncService.syncTransactions` with the identifier for that linked bank account. Refresh UI with new transactions/balances.
    *   **Premium Feature (`IapService`, `BankSyncService`):**
        *   [ ] **[Client]** Refine `IapService.buyPremium()` for MVP:
            *   **Requirement:** A way to simulate or enable premium status for testing.
            *   **Implementation:** If not implementing full IAP for MVP, make this a simple toggle or mock purchase flow.
        *   [ ] **[Client]** `BankSyncService.linkBankAccount` check:
            *   **Requirement:** Enforce limits on free users.
            *   **Implementation:** Before initiating linking, check `iapService.hasPremium` and count of existing linked accounts (from `_linkedAccounts` or by fetching from `SupabaseApiService`).
        *   [ ] **[Client]** User feedback for limits:
            *   **Requirement:** Inform non-premium users if they hit the bank linking limit.
            *   **Implementation:** Show a dialog or SnackBar prompting to upgrade.
    *   **Supabase Backend (Schema & RLS):**
        *   [ ] **[Backend]** Finalize `bank_syncs` table schema:
            *   **Columns:** `id (PK)`, `user_id (FK to auth.users, NOT NULL)`, `provider_name (TEXT NOT NULL)`, `item_id_encrypted (TEXT NOT NULL)` (Plaid item ID, encrypted), `access_token_encrypted (TEXT NOT NULL)` (Plaid access token, encrypted), `account_name_from_provider (TEXT)`, `provider_account_id (TEXT)`, `last_synced (TIMESTAMPZ)`, `created_at (TIMESTAMPZ)`.
            *   **Encryption:** Use Supabase Vault or pgsodium for encrypting `access_token` and `item_id`.
            *   **RLS:** Strict RLS only allowing users to access their own entries. Backend functions (SECURITY DEFINER) will be needed to insert/read encrypted tokens.
        *   [ ] **[Backend]** `expenses` table linkage:
            *   **Requirement:** Trace an expense back to its synced bank if applicable.
            *   **Implementation:** Add `bank_sync_id (FK to bank_syncs.id, NULLABLE)` and `provider_transaction_id (TEXT, NULLABLE)` to the `expenses` table. Add a unique constraint on `(bank_sync_id, provider_transaction_id)` to prevent duplicates.

### 6. Data Export/Import (`csv_service.dart`)
*   **PRD Goal:** Export and import data via CSV.
*   **Status:** `CsvService` exists for `Expense` data.
*   **Open Tasks:**
    *   **UI Integration (e.g., in Settings screen):**
        *   [ ] **[Client]** Add "Export Expenses to CSV" option:
            *   **Requirement:** Allow users to download their expense data.
            *   **Implementation:** In `SettingsScreen`, add a ListTile. On tap, fetch all expenses for the user via `SupabaseApiService.fetchExpenses` (handle pagination if necessary, or fetch all). Call `CsvService.exportCsv`. Use a file picker or share plugin to save/share the resulting CSV string.
        *   [ ] **[Client]** Add "Import Expenses from CSV" option:
            *   **Requirement:** Allow users to upload expenses from a CSV file.
            *   **Implementation:** In `SettingsScreen`, add a ListTile. On tap, use a file picker to select a CSV. Read file content. Call `CsvService.importCsv`.
        *   [ ] **[Client]** Handle mapping for imported CSV data:
            *   **Requirement:** Imported expenses need to be correctly associated and processed.
            *   **Implementation:**
                *   For `accountId`: Prompt user to select which of their existing user-defined CoinBag accounts these imported expenses should be linked to.
                *   For `category`/`tags`: If categories/tags in the CSV don't exist, either auto-create them (call `SupabaseApiService` to add new categories/tags) or map to a default/prompt user.
                *   After processing with `CsvService.importCsv`, iterate through the returned `List<Expense>` and call `SupabaseApiService.addExpense` for each, ensuring the chosen `accountId` and processed category/tags are set. Batch inserts if possible.
    *   [ ] **[Client]** Error Handling for import/export:
        *   **Requirement:** Inform user of success or failure.
        *   **Implementation:** Use SnackBars or dialogs to show messages like "Export successful", "Import complete: X expenses added", or "Error during import: [reason]".

### 7. Cloud Sync (Supabase Integration)
*   **PRD Goal:** Sync data to the cloud via Supabase.
*   **Status:** Most operations use `SupabaseApiService`. `CloudSyncService` role unclear.
*   **Open Tasks:**
    *   [ ] **[Client/Backend]** Service Consolidation/Clarification:
        *   **Requirement:** Define the clear role of `CloudSyncService` vs `SupabaseApiService`.
        *   **Implementation:** Review `CloudSyncService`. If its expense functionality is fully redundant with `SupabaseApiService`, refactor existing code to use `SupabaseApiService` consistently and deprecate/remove the redundant parts of `CloudSyncService`. If `CloudSyncService` is intended for bulk operations or a different sync strategy (e.g., full dataset sync vs. individual CRUD), document this and implement accordingly. For MVP, direct Supabase calls via `SupabaseApiService` for CRUD is standard.
    *   [ ] **[Backend]** Data Consistency and RLS:
        *   **Requirement:** All user data must be securely stored and only accessible by the owner.
        *   **Implementation:**
            *   Review all tables (`expenses`, `accounts`, `bank_syncs`, `categories`, `tags`, `rules`) to ensure they have a `user_id` column (or are linked to a user-owned record).
            *   Implement/Verify Supabase Row Level Security (RLS) policies for ALL tables. Policies should typically restrict SELECT, INSERT, UPDATE, DELETE operations based on `auth.uid() = user_id`.
    *   **Offline Support (Post-MVP, but foundational thoughts for Supabase usage):**
        *   **While full offline is Post-MVP, ensure current Supabase usage doesn't hinder future implementation.** This means avoiding client-side logic that *assumes* immediate successful writes to Supabase for critical UI updates. Optimistic updates are fine, but have a rollback or error handling path.

### 8. Settings (`settings_screen.dart`, etc.)
*   **Status:** Navigation in `SettingsScreen`. Basic screens for Categories, Tags, Rules exist. Sign out implemented.
*   **Open Tasks:**
    *   **Category Settings (`category_settings_screen.dart`):**
        *   [ ] **[Client/Backend]** Load categories from Supabase:
            *   **Requirement:** Display user-defined or system-default categories.
            *   **Client:** Call a new `SupabaseApiService.fetchCategories(userId)` method.
            *   **Backend:** Create `categories` table (`id PK, user_id FK NULLABLE (for system defaults), name TEXT, icon_data TEXT, color_value INTEGER`). `fetchCategories` should get user's own + system defaults. RLS: Users can manage their own, select system ones.
        *   [ ] **[Client/Backend]** Add, edit, delete user-defined categories:
            *   **Requirement:** Users should manage their own categories.
            *   **Client:** Implement UI in `CategorySettingsScreen` and `_AddCategoryDialog` to call `SupabaseApiService.addCategory`, `updateCategory`, `deleteCategory`.
            *   **Backend:** Implement these methods in `SupabaseApiService`. Ensure RLS allows users to modify only their own categories.
    *   **Tag Settings (`tag_settings_screen.dart`):**
        *   [ ] **[Client/Backend]** Load tags from Supabase:
            *   **Requirement:** Display user-defined tags.
            *   **Client:** Call new `SupabaseApiService.fetchTags(userId)`.
            *   **Backend:** Create `tags` table (`id PK, user_id FK, name TEXT, color_value INTEGER`). RLS for user-only access.
        *   [ ] **[Client/Backend]** Add, edit, delete user-defined tags:
            *   **Requirement:** Users should manage their own tags.
            *   **Client:** Implement UI in `TagSettingsScreen` and `_AddTagDialog` for CRUD, calling `SupabaseApiService.addTag`, `updateTag`, `deleteTag`.
            *   **Backend:** Implement these methods in `SupabaseApiService`. RLS for user-only modifications.
    *   **Automatic Rules (`automatic_rules_screen.dart`):**
        *   **PRD Goal:** Implement rules for automation (e.g., auto-categorization).
        *   [ ] **[Client/Backend]** Define Scope for MVP:
            *   **Requirement:** Determine rule complexity for MVP. E.g., "If expense description contains 'Coffee', assign category 'Food & Drink'".
            *   **Implementation:** For MVP, focus on description-based text matching for auto-categorization or auto-tagging.
        *   [ ] **[Client]** UI for creating/managing rules:
            *   **Requirement:** Users need to define and see their rules.
            *   **Implementation:** In `AutomaticRulesScreen`, list existing rules. Add a form/dialog ("Add Rule") with fields for:
                *   Rule Name (optional).
                *   Condition: "Description contains" (input text field).
                *   Action: "Set Category to" (dropdown of categories), "Add Tag" (dropdown/selection of tags).
        *   [ ] **[Backend]** Persist rules to Supabase:
            *   **Requirement:** Rules must be saved per user.
            *   **Implementation:** Create `rules` table (`id PK, user_id FK, name TEXT NULLABLE, condition_type TEXT (e.g., 'description_contains'), condition_value TEXT, action_type TEXT (e.g., 'set_category', 'add_tag'), action_value TEXT (category_id or tag_name)`). Implement `SupabaseApiService.addRule`, `fetchRules`, `deleteRule`. RLS for user-only access.
        *   [ ] **[Client/Backend]** Logic to apply rules:
            *   **Requirement:** Rules should be applied automatically.
            *   **Implementation (Choose one for MVP):**
                *   **Option 1 (Client-side, on expense creation/sync):** After an expense is created (manually) or synced (from bank), before saving to Supabase, iterate through user's rules. If a rule matches, apply the action (set category/tag) on the `Expense` object. This is simpler for MVP.
                *   **Option 2 (Backend - Supabase Edge Function/Trigger - More robust, potentially post-MVP):** When an expense is inserted into the `expenses` table, a trigger calls a Supabase Function. The function fetches the user's rules and applies them to the newly inserted expense row.

### 9. General Tasks & Refinements for MVP
*   [ ] **[Client]** Error Handling:
    *   **Requirement:** Consistent, user-friendly error reporting.
    *   **Implementation:** Implement global error handlers or ensure all API calls in services (`SupabaseApiService`, `BankSyncService`) and UI interactions have `try-catch` blocks. Use SnackBars, dialogs for user feedback. Log detailed errors to console during development.
*   [ ] **[Client]** Loading Indicators:
    *   **Requirement:** Inform user of ongoing background activity.
    *   **Implementation:** Use `CircularProgressIndicator` or similar widgets during API calls, page loads, or any async operation that takes noticeable time. Manage loading states (e.g., `_isLoading` boolean in `StatefulWidget`s).
*   [ ] **[Client]** State Management Review:
    *   **Requirement:** Predictable and maintainable app state.
    *   **Implementation:** Review current state management (largely `setState`). For MVP, this might be okay if screens are simple. If complexity grows, evaluate providers like Provider, Riverpod, or BLoC for more robust state management, especially for shared state across screens (e.g., premium status, user profile).
*   [ ] **[Client]** UI/UX Polish:
    *   **Requirement:** Professional and intuitive user experience.
    *   **Implementation:** Review all screens for consistent styling (use `ThemeData` from `theme.dart`), spacing, typography, and intuitive navigation. Test on various device sizes/emulators. Ensure all interactive elements have clear feedback (e.g., ripple effects on buttons).
*   [ ] **[Client/Backend]** Testing:
    *   **Client:** Write widget tests for key screens (`DashboardScreen`, `ExpensesListScreen`, `AddExpenseScreen`, `AccountScreen`, `SettingsScreen`) to verify UI elements render correctly and basic interactions work. Write unit tests for services (`AuthService`, `BankSyncService` (mocking provider), `SupabaseApiService` (mocking Supabase client), `CsvService`).
    *   **Backend:** For Supabase database functions or triggers, write tests using a framework like pgTAP if possible, or test them thoroughly via API calls. Test RLS policies by impersonating different user roles.
    *   **Manual QA:** Perform thorough end-to-end testing of all MVP features.
*   [ ] **[Client/Backend]** Dependencies & Initialization:
    *   **Requirement:** All services and plugins must be correctly initialized and available.
    *   **Client:** Ensure `IapService` is correctly injected/available where premium checks are needed. Verify Supabase client initialization in `main.dart`.
    *   **Backend:** Ensure any backend setup (e.g., Supabase functions deployment, initial data seeding if any) is documented and repeatable.
*   [ ] **[Client/Backend]** Code Quality & Cleanup:
    *   **Requirement:** Maintainable and clean codebase.
    *   **Client:** Address all `TODO`s relevant to MVP. Remove unused mock data/placeholders. Resolve linter warnings/errors (`flutter analyze`). Add comments for complex logic.
    *   **Backend:** Review Supabase functions and RLS policies for clarity and correctness. Document any complex SQL or database logic.

## Post-MVP (from `plan.md` and Long-Term Ideas)

*   **Improved Bank Sync:** Background sync.
*   **Full In-app Purchases:** Native IAP.
*   **Full Offline Support:** Robust local storage, sync queue.
*   Push notifications.
*   Shared accounts.
*   Web/desktop versions.
*   Budgeting tool integration.

This plan will be the primary guide for reaching MVP. It should be updated as tasks are completed or if priorities shift. 