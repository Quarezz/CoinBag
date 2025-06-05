# CoinBag Database Schema

## 1. Introduction

This document outlines the database schema for the CoinBag application, based on the Product Requirements Document (PRD) and MVP Development Plan. The goal is to provide a clear structure for storing and managing user and application data within Supabase (PostgreSQL).

**General Conventions:**

*   **Primary Keys:** All tables use a `UUID` primary key named `id`, typically generated using `uuid_generate_v4()` through the `uuid-ossp` extension.
*   **Foreign Keys:** Foreign keys are used to establish relationships between tables. `ON DELETE` clauses are specified based on desired data integrity.
*   **Timestamps:** Tables generally include `created_at` and `updated_at` columns (type `TIMESTAMP WITH TIME ZONE`) to track record modifications. These default to the current UTC time.
*   **User Ownership:** Most tables containing user-specific data include a `user_id` column, which is a foreign key to `auth.users(id)`, linking the data to the authenticated Supabase user.
*   **Naming:** Table and column names are in `snake_case`.

## 2. Required Extensions

The following PostgreSQL extension needs to be enabled in Supabase for UUID generation:

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## 3. Table Schemas

### 3.1. `accounts`

Stores user-defined financial accounts (e.g., "Cash Wallet", "Primary Savings Account"). These accounts can optionally be linked to a synced bank account.

```sql
CREATE TABLE public.accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    debit_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    credit_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    bank_access_token_id UUID NULL REFERENCES public.bank_access_tokens(id) ON DELETE SET NULL, -- Link to a specific bank sync
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS (Row Level Security) will be applied to ensure users can only access their own accounts.
```

**Indexes:**
*   An index on `user_id`.
    ```sql
    CREATE INDEX idx_accounts_user_id ON public.accounts(user_id);
    ```
*   An index on `bank_access_token_id`.
    ```sql
    CREATE INDEX idx_accounts_bank_access_token_id ON public.accounts(bank_access_token_id);
    ```

### 3.2. `categories`

Stores user-defined, potentially nested, expense categories.

```sql
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    parent_category_id UUID NULL REFERENCES public.categories(id) ON DELETE SET NULL, -- For nested categories
    icon_data TEXT NULL, -- For storing icon representation (e.g., SVG string, font character code)
    color_hex TEXT NULL, -- For storing color information (e.g., "#RRGGBB")
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT check_category_not_own_parent CHECK (id <> parent_category_id)
);

-- RLS: Users can only access and manage their own categories.
```
**Notes:**
*   A user can have multiple categories with the same name (e.g., under different parents or at the top level). If specific uniqueness is needed (e.g., unique name per parent_category_id for a user), further constraints can be added.

**Indexes:**
*   An index on `user_id`.
    ```sql
    CREATE INDEX idx_categories_user_id ON public.categories(user_id);
    ```
*   An index on `parent_category_id`.
    ```sql
    CREATE INDEX idx_categories_parent_category_id ON public.categories(parent_category_id);
    ```

### 3.3. `tags`

Stores user-defined tags for expenses. A user can have tags with the same name but different colors.

```sql
CREATE TABLE public.tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color_hex TEXT NULL, -- For storing color information (e.g., "#RRGGBB")
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
    -- Note: unique_user_tag_name constraint removed to allow same names with different colors/IDs.
    -- If name must be unique per user, add: CONSTRAINT unique_user_tag_name UNIQUE (user_id, name)
);

-- RLS: Users can only access and manage their own tags.
```
**Indexes:**
*   An index on `user_id`.
    ```sql
    CREATE INDEX idx_tags_user_id ON public.tags(user_id);
    ```

### 3.4. `expenses`

Stores individual expense transactions.

```sql
CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount >= 0),
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    category_id UUID NULL REFERENCES public.categories(id) ON DELETE SET NULL,
    tags UUID[] DEFAULT '{}', -- Array of tag IDs (REFERENCES public.tags(id))
    bank_access_token_id UUID NULL REFERENCES public.bank_access_tokens(id) ON DELETE SET NULL, -- If synced from a bank, linking to the specific token used
    provider_transaction_id TEXT NULL, -- Transaction ID from the external provider
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_provider_transaction_for_sync UNIQUE (bank_access_token_id, provider_transaction_id)
);

-- RLS: Users can only access and manage their own expenses.
```
**Notes:**
*   The `tags UUID[]` column will store an array of foreign keys to `public.tags(id)`. Referential integrity for array elements is not automatically enforced by PostgreSQL. Application logic or triggers would be needed if strict cleanup of deleted tag IDs from this array is required.

**Indexes:**
*   On `user_id`.
    ```sql
    CREATE INDEX idx_expenses_user_id ON public.expenses(user_id);
    ```
*   On `account_id`.
    ```sql
    CREATE INDEX idx_expenses_account_id ON public.expenses(account_id);
    ```
*   On `date` for time-based queries.
    ```sql
    CREATE INDEX idx_expenses_date ON public.expenses(date);
    ```
*   On `category_id`.
    ```sql
    CREATE INDEX idx_expenses_category_id ON public.expenses(category_id);
    ```
*   A GIN index on `tags` (array of UUIDs).
    ```sql
    CREATE INDEX idx_expenses_tags_gin ON public.expenses USING GIN (tags);
    ```
*  On `bank_access_token_id`.
    ```sql
    CREATE INDEX idx_expenses_bank_access_token_id ON public.expenses(bank_access_token_id);
    ```

### 3.5. `bank_access_tokens`

Stores encrypted access tokens and related metadata for bank integrations that use a token-based access protocol.

```sql
CREATE TABLE public.bank_access_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    provider_name TEXT NOT NULL, -- e.g., "Plaid", "MockBank"
    item_id_encrypted TEXT NOT NULL, -- Provider's item ID (e.g., Plaid's item_id), encrypted using Supabase Vault
    access_token_encrypted TEXT NOT NULL, -- Provider's access token, encrypted using Supabase Vault
    -- Additional metadata from provider can be stored here in a JSONB field if needed, e.g., institution_id, available_products
    -- metadata JSONB NULL,
    last_synced_at TIMESTAMP WITH TIME ZONE NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS: Users can only access their own bank_access_tokens records.
-- Encryption: item_id_encrypted and access_token_encrypted will use Supabase Vault. This is managed via application logic and Supabase's encryption functions.
```
**Indexes:**
*   On `user_id`.
    ```sql
    CREATE INDEX idx_bank_access_tokens_user_id ON public.bank_access_tokens(user_id);
    ```
**Future Considerations:**
*   A separate `bank_integrations` meta-table could list available bank integration types and point to specific credential storage tables (like this one for tokens, or others for different protocols) if more diverse integration methods are added later.

### 3.6. `rules` (Deferred for MVP)

Stores user-defined automation rules. The implementation of this feature is deferred beyond the initial MVP. The table structure is a placeholder.

```sql
CREATE TABLE public.rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NULL,
    condition_type TEXT NOT NULL,
    condition_value TEXT NOT NULL,
    action_type TEXT NOT NULL,
    action_value TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS: Users can only access and manage their own rules.
```
**Indexes:**
*   On `user_id`.
    ```sql
    CREATE INDEX idx_rules_user_id ON public.rules(user_id);
    ```

## 4. Relationships Overview

*   **User Centric:** Most tables are directly linked to a `user_id` from `auth.users`.
*   **Accounts & Expenses:** `expenses` belong to an `account`. Both `expenses` and `accounts` are tied to a `user_id`. `accounts` can be linked to a `bank_access_tokens` record.
*   **Expenses Details:** `expenses` can have a `category_id`, multiple `tags` (via an array of `tags.id`), and can be linked to a `bank_access_tokens` record (if synced).
*   **Categories:** Can be nested using  `parent_category_id`.
*   **Automation:** `rules` (deferred) are defined by a user.

## 5. Key Design Decisions and Considerations

This section documents key architectural decisions made for the database schema based on MVP requirements and also notes areas for future consideration.

*   **Accounts Balance Management (DB-01):**
    *   **Decision:** Account balances (`debit_balance`, `credit_balance`) will be updated via backend logic (e.g., Supabase database functions/triggers or controlled API calls) when associated expenses are created, edited, or deleted. The client application provides new entries, and the cloud calculates the resulting balance.
    *   **Rationale:** Ensures data integrity and consistency by centralizing balance calculations on the backend.

*   **Expense Tags Storage (DB-02):**
    *   **Decision:** `expenses.tags` will store an array of `UUID`s, referencing `tags.id`.
    *   **Rationale:** This is more robust for tag renaming and management than storing tag names directly. It requires application logic to resolve tag IDs to names for display.
    *   **Note:** Referential integrity for elements in `UUID[]` arrays (ensuring each UUID in the array exists in `public.tags(id)`) is not automatically enforced by PostgreSQL foreign keys. Application logic or triggers would be needed if strict cleanup of deleted tag IDs from this array is required (beyond the `ON DELETE SET NULL` for a single `category_id`).

*   **Automation Rules (DB-03):**
    *   **Decision:** Automation rules are deferred beyond the initial MVP. The `rules` table schema is included as a placeholder for future development.
    *   **Rationale:** Simplifies MVP scope.

*   **Bank Sync Token Storage & Encryption (DB-04):**
    *   **Decision:** The table for storing bank sync credentials (for token-based integrations) is named `bank_access_tokens`. Supabase Vault will be used for encrypting sensitive tokens (`item_id_encrypted`, `access_token_encrypted`).
    *   **Future Consideration:** The design allows for future flexibility by potentially adding a meta-table for `bank_integrations` if other non-token-based bank integration protocols are supported later.

*   **CSV Import/Export (DB-05):**
    *   **Clarification:** CSV import/export functionality is primarily an application-level business logic concern that will utilize existing database APIs. It does not directly impose unique schema requirements beyond the core tables.
    *   **Rationale:** Keeps schema focused on data structure; import/export logic belongs in the application layer.

*   **System Default Categories (DB-06):**
    *   **Decision:** For the initial MVP, there will be no system-default categories. All categories will be user-defined (`categories.user_id` is NOT NULL).
    *   **Future Consideration:** The schema can be adapted later to support system defaults by making `user_id` nullable for categories and re-introducing an `is_system_default` flag if needed.

*   **Foreign Key `ON DELETE` Behavior (DB-07):**
    *   **Confirmed Behaviors:**
        *   `auth.users` deletion: Cascades to `user_id` in all referencing tables (`accounts`, `categories`, `tags`, `expenses`, `bank_access_tokens`, `rules`). This ensures user data is removed if a user account is deleted (though user deletion itself is not an MVP feature).
        *   `accounts` deletion: Cascades to `expenses.account_id`.
        *   `categories` deletion: `expenses.category_id` is `SET NULL`. `categories.parent_category_id` is `SET NULL` (allowing subcategories to become top-level if their parent is deleted).
        *   `bank_access_tokens` deletion: `accounts.bank_access_token_id` is `SET NULL`. `expenses.bank_access_token_id` is `SET NULL`.
        *   `tags` deletion: Deleting a tag from the `tags` table **does not** automatically remove its ID from the `expenses.tags UUID[]` array. This is a limitation of array types with foreign key concepts. Application logic or a periodic cleanup process would be needed to handle stale tag IDs in expenses if this becomes a concern.
    *   **Rationale:** These behaviors are chosen to maintain data integrity while providing a reasonable user experience upon deletion of related entities.

This document provides the foundational schema. It should be translated into Supabase migrations. Row Level Security (RLS) policies will need to be defined for each table to ensure proper data access control.
