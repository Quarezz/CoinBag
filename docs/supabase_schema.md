# Supabase Database Schema

This document outlines the database schema for the CoinBag application using Supabase.

## Tables

### expenses
Stores all expense transactions.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| description | text | Description of the expense |
| amount | decimal | Amount of the expense |
| date | timestamp | Date of the expense |
| account_id | uuid | Foreign key to accounts table |
| category | text | Optional category of the expense |
| tags | text[] | Array of tags associated with the expense |
| recurring_interval_days | integer | Optional number of days for recurring expenses |

### accounts
Stores user accounts and their balances.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| name | text | Name of the account |
| debit_balance | decimal | Current debit balance |
| credit_balance | decimal | Current credit balance |

### dashboard_info
Stores dashboard-related information for each account.

| Column | Type | Description |
|--------|------|-------------|
| account_id | uuid | Foreign key to accounts table |
| [Additional columns based on dashboard requirements] | - | - |

### bank_syncs
Stores bank synchronization data.

| Column | Type | Description |
|--------|------|-------------|
| account_id | uuid | Foreign key to accounts table |
| sync_data | jsonb | Bank synchronization data |

## Authentication

The application uses Supabase Auth for user authentication. The following tables are automatically created by Supabase:

- auth.users
- auth.identities
- auth.sessions

## Row Level Security (RLS) Policies

It's recommended to implement the following RLS policies:

1. Users can only access their own expenses
2. Users can only access their own accounts
3. Users can only access their own dashboard info
4. Users can only access their own bank syncs

## Indexes

Recommended indexes:

1. expenses(account_id, date)
2. expenses(category)
3. bank_syncs(account_id)

## Notes

- All monetary values should be stored as decimal to ensure precision
- Timestamps should be stored in UTC
- UUIDs should be used for all primary and foreign keys
- Consider implementing soft delete for expenses and accounts 