# Supabase Setup Tutorial for CoinBag

This guide will walk you through setting up Supabase for the CoinBag project, including database creation, authentication, and security policies.

## 1. Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com) and sign in/sign up
2. Click "New Project"
3. Fill in the project details:
   - Name: `coinbag`
   - Database Password: [Generate a secure password]
   - Region: [Choose the closest to your users]
4. Click "Create new project"

## 2. Database Setup

### Create Tables

Run the following SQL in the Supabase SQL Editor:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create accounts table
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    debit_balance DECIMAL(12,2) DEFAULT 0,
    credit_balance DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create expenses table
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    description TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    category TEXT,
    tags TEXT[] DEFAULT '{}',
    recurring_interval_days INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create dashboard_info table
CREATE TABLE dashboard_info (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create bank_syncs table
CREATE TABLE bank_syncs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    sync_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create indexes
CREATE INDEX idx_expenses_account_date ON expenses(account_id, date);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_bank_syncs_account ON bank_syncs(account_id);
```

### Set up Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE dashboard_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_syncs ENABLE ROW LEVEL SECURITY;

-- Create policies for accounts
CREATE POLICY "Users can view their own accounts"
    ON accounts FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can insert their own accounts"
    ON accounts FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own accounts"
    ON accounts FOR UPDATE
    USING (auth.uid() = id);

-- Create policies for expenses
CREATE POLICY "Users can view their own expenses"
    ON expenses FOR SELECT
    USING (auth.uid() = account_id);

CREATE POLICY "Users can insert their own expenses"
    ON expenses FOR INSERT
    WITH CHECK (auth.uid() = account_id);

CREATE POLICY "Users can update their own expenses"
    ON expenses FOR UPDATE
    USING (auth.uid() = account_id);

CREATE POLICY "Users can delete their own expenses"
    ON expenses FOR DELETE
    USING (auth.uid() = account_id);

-- Create policies for dashboard_info
CREATE POLICY "Users can view their own dashboard info"
    ON dashboard_info FOR SELECT
    USING (auth.uid() = account_id);

CREATE POLICY "Users can insert their own dashboard info"
    ON dashboard_info FOR INSERT
    WITH CHECK (auth.uid() = account_id);

-- Create policies for bank_syncs
CREATE POLICY "Users can view their own bank syncs"
    ON bank_syncs FOR SELECT
    USING (auth.uid() = account_id);

CREATE POLICY "Users can insert their own bank syncs"
    ON bank_syncs FOR INSERT
    WITH CHECK (auth.uid() = account_id);
```

## 3. Authentication Setup

1. Go to Authentication > Settings
2. Configure the following:
   - Site URL: Your app's URL
   - Redirect URLs: Add your app's authentication callback URLs
   - Email Auth: Enable
   - Email Confirmations: Optional (recommended for production)

## 4. Environment Setup

1. Get your project credentials:
   - Go to Project Settings > API
   - Copy the `Project URL` and `anon` public key

2. Create a `.env` file in your project root:

```env
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

3. Update your Flutter app's initialization:

```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

## 5. Testing the Setup

1. Test Authentication:
```dart
final supabase = Supabase.instance.client;

// Sign up
final response = await supabase.auth.signUp(
  email: 'test@example.com',
  password: 'your-password',
);

// Sign in
final response = await supabase.auth.signInWithPassword(
  email: 'test@example.com',
  password: 'your-password',
);
```

2. Test Database Operations:
```dart
// Create an account
final account = await supabase
  .from('accounts')
  .insert({
    'name': 'Test Account',
    'debit_balance': 0,
    'credit_balance': 0,
  })
  .select()
  .single();

// Create an expense
final expense = await supabase
  .from('expenses')
  .insert({
    'description': 'Test Expense',
    'amount': 10.50,
    'date': DateTime.now().toIso8601String(),
    'account_id': account['id'],
    'category': 'Food',
    'tags': ['test', 'food'],
  })
  .select()
  .single();
```

## 6. Security Best Practices

1. Always use RLS policies to restrict data access
2. Never expose sensitive operations to the client
3. Use appropriate data types (DECIMAL for money)
4. Implement proper error handling
5. Use prepared statements for queries
6. Regularly backup your database
7. Monitor your database usage and performance

## 7. Troubleshooting

Common issues and solutions:

1. RLS Policy Issues:
   - Check if RLS is enabled on the table
   - Verify the policy conditions
   - Check if the user is authenticated

2. Authentication Issues:
   - Verify your project URL and anon key
   - Check email confirmation settings
   - Verify redirect URLs

3. Database Connection Issues:
   - Check your network connection
   - Verify your database password
   - Check if your IP is allowed in the database settings

## 8. Next Steps

1. Set up database backups
2. Configure monitoring and alerts
3. Set up CI/CD for database migrations
4. Implement proper error handling
5. Add database indexes based on query patterns
6. Set up proper logging and monitoring