# CoinBag Flutter

A Flutter-based expenses tracker supporting iOS and Android.

## Features
- Dashboard with the latest expenses
- Configurable expenses list
- Bank account linking and sync
- Optional premium upgrade for multiple bank syncs
- CSV import/export
- Multiple accounts, deposits and cards
- Debit and credit balance tracking
- Quick expense entry
- Cloud sync via Supabase
- Supabase-backed API for expenses and accounts

## Configuration

Set the following environment variables before running the app:

```
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=public-anon-key
```

These are required for the app to connect to your Supabase backend.

## Supabase API

The app communicates with Supabase for:

- Fetching dashboard data
- Paginated expenses listing
- Adding, removing and editing expenses
- Managing accounts
- Tracking bank syncs

## Running tests

Make sure the Flutter SDK is installed and `flutter` is in your `PATH`. Then run:

```bash
./run_tests.sh
```
