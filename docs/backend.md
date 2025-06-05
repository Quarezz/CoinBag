# CoinBag Backend Guide (Supabase)

## 1. Introduction

This document outlines the backend architecture and development guidelines for the CoinBag application, utilizing Supabase as the primary backend-as-a-service (BaaS) platform. Supabase provides a suite of tools including a PostgreSQL database, authentication, instant APIs, edge functions, and storage, which will be leveraged to build CoinBag's backend functionality.

**Why Supabase?**

*   **Integrated Solution:** Offers a cohesive set of backend services (Auth, DB, Functions, Storage) reducing the need to manage multiple disparate services.
*   **PostgreSQL Power:** Provides a full-fledged PostgreSQL database, allowing for complex queries, relationships, and robust data integrity.
*   **Row Level Security (RLS):** Enables fine-grained access control directly at the database level, crucial for multi-tenant applications like CoinBag.
*   **Scalability:** Supabase is designed to scale, providing a pathway for growth.
*   **Developer Experience:** Offers a CLI for local development, migrations, and schema management, along with client libraries for easy integration.
*   **Open Source:** Core components are open source, offering transparency and flexibility.

## 2. Core Supabase Features Usage

### 2.1. Authentication (`auth`)

*   **Service:** Supabase Auth will be used for all user authentication needs, including sign-up, sign-in, and session management.
*   **User Identity:** The `auth.users` table and the `auth.uid()` function are central to identifying users and linking their data across the application.
*   **Security:**
    *   Email confirmations can be enabled for new sign-ups (as per PRD).
    *   Secure password policies should be enforced.
    *   RLS policies will heavily rely on `auth.uid()` to ensure users can only access their own data.

### 2.2. Database (PostgreSQL)

*   **Schema:** The database schema is defined in `docs/database.md`. All tables reside in the `public` schema unless specified otherwise.
*   **Migrations:**
    *   Schema changes (DDL - Data Definition Language) **MUST** be managed via Supabase CLI migrations.
    *   All migrations will be generated using `supabase db diff` (after making changes to a local/shadow database or by writing SQL manually) and stored in the `supabase/migrations/` directory.
    *   Migrations should be descriptive and atomic where possible.
    *   **Workflow for Schema Changes:**
        1.  Start the local Supabase development environment (`supabase start`).
        2.  Connect to the local database using a SQL client (e.g., Supabase Studio, DBeaver, pgAdmin).
        3.  Apply desired schema changes (e.g., `CREATE TABLE`, `ALTER TABLE`).
        4.  Stop the local database and run `supabase db diff -f <migration_name>` to generate a new migration file. Review the generated SQL.
        5.  Alternatively, for complex changes or when starting from scratch based on `database.md`, migration files can be written manually.
        6.  Apply migrations locally using `supabase db reset` (to ensure a clean slate) or `supabase migration up` (to apply new migrations).
        7.  Once tested locally, commit the migration files to version control.
        8.  Deploy migrations to the staging/production Supabase project using `supabase db push`.
            **Caution:** Always back up your remote database before pushing migrations to production.
*   **Data Integrity:** Foreign keys, CHECK constraints, and unique constraints defined in `database.md` are crucial for maintaining data integrity.
*   **Indexes:** Indexes are defined in `database.md` to optimize query performance. Additional indexes may be added as needed based on query patterns.

### 2.3. Row Level Security (RLS)

*   **Mandatory:** RLS **MUST** be enabled on all tables containing user-specific data.
*   **Principle:** Policies should restrict access such that users can only perform operations (SELECT, INSERT, UPDATE, DELETE) on their own data.
*   **Implementation:**
    *   Policies will primarily use `auth.uid() = user_id` conditions, where `user_id` is a column in the target table referencing `auth.users(id)`.
    *   For tables indirectly related to a user (e.g., `expenses` linked via `accounts`), policies may need to check ownership through joins (e.g., `EXISTS (SELECT 1 FROM accounts WHERE accounts.id = expenses.account_id AND accounts.user_id = auth.uid())`).
    *   **Naming Convention for Policies:** `"Users can [action] their own [table_name]"` (e.g., `"Users can view their own accounts"`).
    *   Use `USING` clause for SELECT, UPDATE, DELETE operations.
    *   Use `WITH CHECK` clause for INSERT and UPDATE operations to enforce data ownership on write.
    *   Policies should be defined within migration files to be version controlled and automatically applied.

### 2.4. Database Functions (RPC - Remote Procedure Calls)

*   **Purpose:** For complex data operations, aggregations, or business logic that is best executed directly within the database for performance or atomicity.
*   **Example:** The `fetch_dashboard_info` function (as per PRD) will be a database function.
*   **Security:**
    *   Functions accessed directly by clients via the API should be `SECURITY DEFINER` if they need to bypass RLS for specific, controlled operations (e.g., aggregating data across rows a user owns but might not have direct RLS select access to in an intermediate step). Use with extreme caution and ensure the function itself is secure and properly restricts data access based on the calling user (`auth.uid()`).
    *   Alternatively, functions can be `SECURITY INVOKER` (default), running with the permissions of the calling user, respecting RLS.
    *   Clearly define parameters and return types.
*   **Management:** Database functions should be defined in migration files.
*   **Triggers:** Database triggers can be used to automate actions based on table events (e.g., updating `accounts.balance` when an `expenses` row is changed). Triggers call database functions.
    *   **Decision from `database.md` (DB-01):** Account balances will be updated via backend logic, potentially using triggers that call specific database functions.

### 2.5. Edge Functions (Serverless Functions)

*   **Purpose:** For backend logic that doesn't fit well into database functions, requires external API calls, or needs more complex programming constructs.
*   **Example:**
    *   Handling callbacks from third-party services (e.g., a bank linking provider).
    *   Exchanging a public token for an access token with a bank provider and securely storing it (potentially calling Supabase Vault functions).
*   **Language:** Typically TypeScript/JavaScript (Deno runtime).
*   **Development:** Develop locally and deploy via `supabase functions deploy <function_name>`.
*   **Security:** Securely manage environment variables and secrets. Edge Functions can interact with the database using the Supabase client libraries, respecting RLS or using a service role key for privileged operations if absolutely necessary and carefully controlled.

### 2.6. Storage

*   **Purpose:** For storing user-uploaded files (e.g., CSV imports if processed server-side, profile pictures - though not in MVP).
*   **Buckets:** Define storage buckets with appropriate access policies (public/private).
*   **RLS for Storage:** Storage access can also be controlled via RLS-like policies.
*   **MVP Scope:** CSV import/export is the primary feature that might interact with storage if files are temporarily staged. However, client-side processing might negate direct need for MVP. For now, minimal direct use anticipated for MVP core features beyond potential temporary storage.

### 2.7. Supabase Vault

*   **Purpose:** For securely storing and managing secrets like API keys or encryption keys.
*   **Decision from `database.md` (DB-04):** Supabase Vault will be used for encrypting sensitive tokens in the `bank_access_tokens` table (`item_id_encrypted`, `access_token_encrypted`).
*   **Usage:** Secrets are stored in the Vault and can be accessed by database functions (e.g., using `pgsodium` functions if Vault integration uses that under the hood for custom encryption/decryption logic within SQL) or Edge Functions.

## 3. Development Workflow & Conventions

*   **Local First:** Always develop and test changes locally using `supabase start` before considering deploying to a remote environment.
*   **Version Control:** All Supabase project configurations (`supabase/` directory, including migrations, `config.toml`) **MUST** be committed to Git.
*   **Environment Management:**
    *   **Local:** For development and testing.
    *   **Staging (Optional but Recommended):** A separate Supabase project for testing integrations and pre-production validation.
    *   **Production:** The live Supabase project.
*   **Secrets Management:**
    *   **NEVER** commit raw secrets (API keys, database passwords, JWT secret) to Git.
    *   Use environment variables for Supabase CLI and Edge Functions where appropriate (e.g., for local development, reference them from `.env` files that are in `.gitignore`).
    *   For secrets used by the database (e.g., for `pgsodium` if used directly, or internal workings of Vault), manage them through the Supabase dashboard or Vault interface.
*   **Database Backups:** Regularly back up your production Supabase database. Automated backups are provided by Supabase, but understand the retention and recovery options.

## 4. Security Best Practices

*   **Principle of Least Privilege:** RLS policies and function permissions should grant only the necessary access.
*   **Input Validation:** Validate all inputs on the client-side and sanitize/validate inputs on the backend (Edge Functions, Database Functions) to prevent injection attacks.
*   **RLS is Key:** Rely heavily on RLS for data segregation and authorization.
*   **Service Role Key:** Use the `service_role` key with extreme caution and only in secure backend environments (like Edge Functions or trusted server-side processes) where elevated privileges are absolutely necessary. Avoid exposing it or using it directly in client-side code.
*   **Secrets Handling:** Follow best practices for managing secrets using Supabase Vault and environment variables.
*   **Dependency Updates:** Keep Supabase CLI and client libraries updated to their latest stable versions.

## 5. Future Considerations (Not for immediate MVP focus)

*   **Advanced RLS:** Explore more complex RLS scenarios as features evolve.
*   **Database Function Optimization:** Profile and optimize database functions as data grows.
*   **Edge Function Scaling & Monitoring:** Implement proper logging, monitoring, and scaling strategies for Edge Functions if their usage becomes extensive.
*   **Full Text Search:** If advanced search capabilities are needed, explore PostgreSQL's full-text search features.

This document serves as a living guide and should be updated as the backend architecture and conventions evolve.
