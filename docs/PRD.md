# CoinBag Product Requirements

CoinBag is a cross platform expense tracker built with Flutter. The app allows users to keep track of their spending across multiple accounts and sync data with a Supabase backend.

## Core Functionality

- View dashboard summary of recent spending and balances
- Browse expenses with pagination
- Add, edit and remove expenses
- Link bank accounts and sync transactions
- Manage multiple accounts with separate balances
- Export and import data via CSV
- Sync data to the cloud via Supabase
- Rich expense entry with categories, tags and recurring expenses

## Technical Overview

All backend data is stored in Supabase. The app communicates with Supabase through `SupabaseApiService` which exposes methods for expenses, accounts and bank sync information. Authentication is handled externally and not covered in this document.

## Tables

- `expenses` – stores individual expenses
- `accounts` – stores user accounts
- `bank_syncs` – tracks connected bank providers
- `dashboard_info` – materialized view or RPC providing dashboard totals

Each table stores rows belonging to a specific user or account. See the planning document for additional planned tables and fields.
