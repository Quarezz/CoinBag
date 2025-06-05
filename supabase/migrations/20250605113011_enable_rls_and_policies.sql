-- Enable RLS for all relevant tables and define policies
-- Table: public.accounts
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to read their own accounts" ON public.accounts FOR
SELECT
    USING (auth.uid () = user_id);

CREATE POLICY "Allow users to insert their own accounts" ON public.accounts FOR INSERT
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to update their own accounts" ON public.accounts FOR
UPDATE USING (auth.uid () = user_id)
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to delete their own accounts" ON public.accounts FOR DELETE USING (auth.uid () = user_id);

-- Table: public.categories
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to read their own categories" ON public.categories FOR
SELECT
    USING (auth.uid () = user_id);

CREATE POLICY "Allow users to insert their own categories" ON public.categories FOR INSERT
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to update their own categories" ON public.categories FOR
UPDATE USING (auth.uid () = user_id)
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to delete their own categories" ON public.categories FOR DELETE USING (auth.uid () = user_id);

-- Table: public.tags
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to read their own tags" ON public.tags FOR
SELECT
    USING (auth.uid () = user_id);

CREATE POLICY "Allow users to insert their own tags" ON public.tags FOR INSERT
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to update their own tags" ON public.tags FOR
UPDATE USING (auth.uid () = user_id)
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to delete their own tags" ON public.tags FOR DELETE USING (auth.uid () = user_id);

-- Table: public.expenses
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to read their own expenses" ON public.expenses FOR
SELECT
    USING (auth.uid () = user_id);

CREATE POLICY "Allow users to insert their own expenses" ON public.expenses FOR INSERT
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to update their own expenses" ON public.expenses FOR
UPDATE USING (auth.uid () = user_id)
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to delete their own expenses" ON public.expenses FOR DELETE USING (auth.uid () = user_id);

-- Table: public.bank_access_tokens
ALTER TABLE public.bank_access_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to read their own bank_access_tokens" ON public.bank_access_tokens FOR
SELECT
    USING (auth.uid () = user_id);

CREATE POLICY "Allow users to insert their own bank_access_tokens" ON public.bank_access_tokens FOR INSERT
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to update their own bank_access_tokens" ON public.bank_access_tokens FOR
UPDATE USING (auth.uid () = user_id)
WITH
    CHECK (auth.uid () = user_id);

CREATE POLICY "Allow users to delete their own bank_access_tokens" ON public.bank_access_tokens FOR DELETE USING (auth.uid () = user_id);