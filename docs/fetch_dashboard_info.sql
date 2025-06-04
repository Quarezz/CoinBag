-- Supabase RPC to provide dashboard summary data
-- Aggregates recent spending, account balances and upcoming bills
-- Assumes RLS policies are in place on related tables

create or replace function fetch_dashboard_info()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_spending numeric;
  v_balance numeric;
  v_bills jsonb;
begin
  -- total spending for last 30 days
  select coalesce(sum(amount), 0)
    into v_spending
    from expenses
    where account_id in (select id from accounts where user_id = v_user)
      and date >= (current_date - interval '30 days');

  -- aggregate account balances
  select coalesce(sum(debit_balance - credit_balance), 0)
    into v_balance
    from accounts
    where user_id = v_user;

  -- upcoming bills derived from recurring expenses
  select jsonb_agg(
           jsonb_build_object(
             'id', id,
             'description', description,
             'amount', amount,
             'due_date', (date + (recurring_interval_days || ' days')::interval)
           )
         )
    into v_bills
    from expenses
    where account_id in (select id from accounts where user_id = v_user)
      and recurring_interval_days is not null
      and (date + (recurring_interval_days || ' days')::interval) >= current_date
      and (date + (recurring_interval_days || ' days')::interval) <= current_date + interval '30 days';

  return jsonb_build_object(
    'spending', coalesce(v_spending, 0),
    'balances', coalesce(v_balance, 0),
    'upcoming_bills', coalesce(v_bills, '[]'::jsonb)
  );
end;
$$;
