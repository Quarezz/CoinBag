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
- [ ] Rules for automation of synced transactions to mark them with correct tags/categories

## Detailed Task Breakdown

### 1. Authentication (Largely Complete)
*   **Status:** Integrated with Supabase Auth. `AuthService` handles login, signup, signout. Mock login also available.
*   **Open Tasks:**
    *   [ ] Review and test edge cases (e.g., password reset functionality if required by Supabase setup, email verification flows).
    *   [ ] Ensure consistent error handling for auth exceptions.

### 2. Dashboard (`dashboard_screen.dart`)
*   **PRD Goal:** View dashboard summary of recent spending and balances.
*   **Status:** Basic dashboard screen exists. Displays a spending chart and upcoming bills using mock data.
*   **Open Tasks:**
    *   [ ] **Data Integration:**
        *   [ ] Integrate `SupabaseApiService.fetchDashboardInfo` to get real data.
        *   [ ] Modify `SpendingChart` to accept and display real spending data over time.
        *   [ ] Replace mock `_upcomingBills` with data derived from recurring expenses or a dedicated bills feature (if implemented).
    *   [ ] **Account Balances:**
        *   [ ] Display a summary of balances from user's accounts (requires Account Management to be further developed).

### 3. Expense Management
*   **PRD Goals:** Browse expenses with pagination. Add, edit and remove expenses. Rich expense entry with categories, tags and recurring expenses.
*   **Status:**
    *   `ExpensesListScreen`: Basic structure exists.
    *   `AddExpenseScreen`: Basic UI structure exists with text fields.
    *   `SupabaseApiService`: Has methods for `addExpense`, `fetchExpenses`, `editExpense`, `removeExpense`.
    *   `Expense` model: Supports ID, description, amount, date, accountId, category, tags, recurringIntervalDays.
*   **Open Tasks:**
    *   **Add/Edit Expense Screen (`add_expense_screen.dart` and new Edit Screen/Dialog):**
        *   [ ] Implement form handling and validation.
        *   [ ] Connect UI fields to the `Expense` model properties for creation and editing.
        *   [ ] Call `SupabaseApiService.addExpense` on save for new expenses.
        *   [ ] Call `SupabaseApiService.editExpense` on save for existing expenses.
        *   [ ] **Category Integration:**
            *   [ ] Allow selection from existing categories (see Settings).
            *   [ ] Persist selected category with the expense.
        *   **Tag Integration:**
            *   [ ] Allow selection/creation of tags (see Settings).
            *   [ ] Persist selected tags with the expense.
        *   **Recurring Expense:**
            *   [ ] Provide UI to set `recurringIntervalDays`.
            *   [ ] Ensure this data is saved with the expense.
    *   **Expenses List Screen (`expenses_list_screen.dart`):**
        *   [ ] Call `SupabaseApiService.fetchExpenses` to load real expense data.
        *   [ ] Implement pagination in `fetchExpenses` and the UI.
        *   [ ] Display expense details (description, amount, date, category, tags).
        *   [ ] Add UI elements to trigger editing of an expense (navigate to Edit Screen/Dialog).
        *   [ ] Add UI elements to trigger removal of an expense (call `SupabaseApiService.removeExpense`) with confirmation.
    *   **Rich Expense Features:**
        *   [ ] Ensure filtering/sorting by category or tags if desired for MVP.
        *   [ ] Consider how recurring expenses impact views (e.g., forecasting future bills).

### 4. Account Management (User-defined accounts, not bank accounts)
*   **PRD Goal:** Manage multiple accounts with separate balances.
*   **Status:**
    *   `Account` model exists (id, name, debitBalance, creditBalance).
    *   `SupabaseApiService` has `addAccount`, `updateAccount`.
    *   `AccountScreen` has been refactored to focus on *bank* accounts. A new screen/section might be needed for user-defined accounts or this needs to be integrated into the existing `AccountScreen` if it's meant to show both. For now, assuming `Account` model refers to user-defined accounts distinct from Plaid-linked ones.
*   **Open Tasks (assuming separate management for user-defined accounts):**
    *   [ ] **UI for User Accounts:**
        *   [ ] Design and implement a screen or section to list user-defined accounts (e.g., "Cash", "Savings Wallet").
        *   [ ] Allow creation of new user-defined accounts (name, initial balance).
        *   [ ] Allow editing names of user-defined accounts.
        *   [ ] Display balances for these accounts.
    *   **Data Storage:**
        *   [ ] `SupabaseApiService`: Add `fetchAccounts` method to get all accounts for the current user.
        *   [ ] Ensure `addAccount` and `updateAccount` are used correctly.
    *   **Transactions:**
        *   [ ] Ensure expenses can be assigned to these user-defined accounts.

### 5. Bank Account Linking & Transaction Sync (Plaid/External Provider)
*   **PRD Goals:** Link bank accounts and sync transactions. Premium users can link multiple banks.
*   **Status:**
    *   `BankSyncService`: Exists with `linkBankAccount` and `syncTransactions` (currently placeholder logic).
    *   `IapService`: Exists for premium status check (mocked).
    *   `AccountScreen`: UI elements for adding accounts and manual sync exist.
    *   Supabase table `bank_syncs` mentioned in PRD.
*   **Open Tasks:**
    *   **Core Bank Linking (`BankSyncService`):**
        *   [ ] **Provider Integration (Major Task):**
            *   [ ] **TODO:** Research and decide on a bank aggregation provider (e.g., Plaid, TrueLayer, GoCardless) or implement a more robust mock for MVP.
            *   [ ] Implement the chosen provider's SDK/API for:
                *   [ ] Authentication/OAuth flow to link a bank.
                *   [ ] Fetching a list of accounts from the linked institution.
                *   [ ] Retrieving transactions for a selected account.
            *   [ ] **TODO:** Securely store access tokens or identifiers from the provider, associating them with the user and the `bank_syncs` Supabase table.
        *   [ ] `linkBankAccount` (in `BankSyncService`):
            *   [ ] **TODO:** Replace placeholder with actual provider linking logic.
            *   [ ] After successful linking, store relevant data in the `bank_syncs` table via `SupabaseApiService`.
        *   [ ] `syncTransactions` (in `BankSyncService`):
            *   [ ] **TODO:** Implement fetching transactions from the provider for a given linked bank.
            *   [ ] Convert provider's transaction data into `Expense` model objects.
            *   [ ] Save these new expenses to Supabase via `SupabaseApiService.addExpense`, ensuring they are associated with the correct CoinBag account and the synced bank.
            *   [ ] Implement de-duplication logic for transactions if the provider doesn't guarantee uniqueness or if syncs overlap.
    *   **Account Screen UI (`account_screen.dart`):**
        *   [ ] `_loadAccounts`: **TODO:** Load *linked bank accounts* from Supabase (from `bank_syncs` table or a join). This is currently a placeholder.
        *   [ ] `_addBankAccount`: **TODO:** Trigger the actual bank linking flow via `BankSyncService`.
        *   [ ] `Sync Button` on list item: **TODO:** Trigger `BankSyncService.syncTransactions` for that specific linked bank account and refresh the UI.
    *   **Premium Feature (`IapService`, `BankSyncService`):**
        *   [ ] Refine `IapService.buyPremium()` if a mock purchase flow is needed for MVP.
        *   [ ] Ensure `BankSyncService.linkBankAccount` correctly checks `iapService.hasPremium` and `_linkedAccounts.length >= freeLimit` before allowing new links.
        *   [ ] Provide clear user feedback if the limit is reached for non-premium users.
    *   **Supabase Backend:**
        *   [ ] Finalize schema for `bank_syncs` table (e.g., user_id, provider_name, access_token_ref, account_name, provider_account_id, last_synced).
        *   [ ] Ensure `expenses` table has a way to link to a `bank_syncs` entry if it originated from a bank.

### 6. Data Export/Import (`csv_service.dart`)
*   **PRD Goal:** Export and import data via CSV.
*   **Status:** `CsvService` exists with `exportCsv` and `importCsv` methods for `Expense` data.
*   **Open Tasks:**
    *   **UI Integration (e.g., in Settings screen):**
        *   [ ] Add a button/option to "Export Expenses to CSV".
            *   [ ] Prompt user for save location or use a default share mechanism.
            *   [ ] Call `CsvService.exportCsv` with all relevant expenses.
        *   [ ] Add a button/option to "Import Expenses from CSV".
            *   [ ] Allow user to pick a CSV file.
            *   [ ] Call `CsvService.importCsv`.
            *   [ ] Handle mapping of imported data:
                *   Which `accountId` should imported expenses be assigned to? (e.g., a default or ask user)
                *   How to handle categories/tags not already in the app? (e.g., create new, or map to existing)
    *   [ ] **Error Handling:** Provide feedback for successful/failed import/export operations.

### 7. Cloud Sync (Supabase Integration)
*   **PRD Goal:** Sync data to the cloud via Supabase.
*   **Status:** Most data operations are directly routed through `SupabaseApiService`. `CloudSyncService` exists but its role for expenses seems to overlap with `SupabaseApiService`.
*   **Open Tasks:**
    *   [ ] **Service Consolidation:** Review `CloudSyncService`. If its expense functionality is redundant with `SupabaseApiService`, refactor or remove to avoid confusion. Determine if it has other intended roles (e.g., bulk operations, specific sync logic).
    *   [ ] **Data Consistency:** Ensure all user-generated data (accounts, expenses, bank links, categories, tags) is reliably persisted to Supabase.
    *   [ ] **Offline Support (Post-MVP, from `plan.md`):**
        *   [ ] Design strategy for local caching/storage (e.g., SQLite).
        *   [ ] Implement a queue for offline mutations.
        *   [ ] Develop a robust sync mechanism for when connectivity is restored.

### 8. Settings (`settings_screen.dart`, `category_settings_screen.dart`, `tag_settings_screen.dart`, `automatic_rules_screen.dart`)
*   **Status:** `SettingsScreen` provides navigation. Basic screens for Categories, Tags, and Automatic Rules exist. Sign out implemented.
*   **Open Tasks:**
    *   **Category Settings (`category_settings_screen.dart`):**
        *   [ ] Implement loading categories from Supabase (if user-defined and synced).
        *   [ ] Implement adding, editing, and deleting categories, persisting changes to Supabase.
        *   [ ] Ensure `_AddCategoryDialog` saves the new category correctly.
    *   **Tag Settings (`tag_settings_screen.dart`):**
        *   [ ] Implement loading tags from Supabase.
        *   [ ] Implement adding, editing (if needed), and deleting tags, persisting changes to Supabase.
        *   [ ] Ensure `_AddTagDialog` saves the new tag correctly.
    *   **Automatic Rules (`automatic_rules_screen.dart`):**
        *   [ ] **Define Scope for MVP:** What kind of rules? (e.g., auto-categorize expense if description contains "XYZ").
        *   [ ] Implement UI for creating/managing these rules.
        *   [ ] Implement logic to apply these rules (e.g., when new transactions are synced or expenses added).
        *   [ ] Persist rules to Supabase. (This feature might be simplified or deferred post-MVP if complex).

### 9. General Tasks & Refinements for MVP
*   [ ] **Error Handling:** Implement consistent and user-friendly error reporting (SnackBars, dialogs) throughout the app for API calls, validation, etc.
*   [ ] **Loading Indicators:** Ensure all asynchronous operations display appropriate loading states in the UI.
*   [ ] **State Management:** Review and ensure consistent state management practices, especially after complex operations like bank sync or data import.
*   [ ] **UI/UX Polish:**
    *   [ ] Conduct a full app review for UI consistency, usability, and visual appeal.
    *   [ ] Ensure responsive design for different screen sizes (if relevant for target devices).
    *   [ ] Test navigation flows.
*   [ ] **Testing:**
    *   [ ] Write unit tests for key services (`AuthService`, `BankSyncService`, `SupabaseApiService`, `CsvService`).
    *   [ ] Write widget tests for critical screens and UI components.
    *   [ ] Perform thorough manual QA across all MVP features on target devices/emulators.
*   [ ] **Dependencies:**
    *   [ ] Ensure `IapService` is correctly integrated where premium checks are needed.
    *   [ ] Finalize initialization and provision of all services.
*   [ ] **Code Quality & Cleanup:**
    *   [ ] Address all remaining `TODO` comments relevant to MVP.
    *   [ ] Remove unused mock data and placeholder logic once real implementations are in place.
    *   [ ] Resolve any linter warnings or errors.
    *   [ ] Document complex code sections.

## Post-MVP (from `plan.md` and Long-Term Ideas)

*   **Improved Bank Sync:** Background sync of transactions and balance updates.
*   **Full In-app Purchases:** Native implementation for unlocking premium features.

This plan will be the primary guide for reaching MVP. It should be updated as tasks are completed or if priorities shift. 