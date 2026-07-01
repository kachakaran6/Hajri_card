-- Supabase Database Schema for Digital Rojgar Book (Hajri App)

-- 1. Enable UUID Extension
create extension if not exists "uuid-ossp";

-- 2. Create Profiles Table (extends Supabase auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text not null,
  company_name text,
  phone text,
  language text default 'en' not null,
  currency text default 'INR' not null,
  avatar text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Create Projects Table
create table public.projects (
  id uuid primary key default gen_random_uuid(),
  contractor_id uuid references public.profiles(id) on delete cascade not null,
  name text not null,
  location text,
  start_date date,
  end_date date,
  status text default 'Active' not null,
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Create Workers Table
create table public.workers (
  id uuid primary key default gen_random_uuid(),
  contractor_id uuid references public.profiles(id) on delete cascade not null,
  photo text,
  worker_code text,
  full_name text not null,
  phone text,
  father_name text,
  address text,
  village text,
  city text,
  state text,
  joining_date date default current_date not null,
  daily_wage numeric(10, 2) default 0.00 not null,
  overtime_rate numeric(10, 2) default 0.00 not null,
  status text default 'Active' not null,
  default_project uuid references public.projects(id) on delete set null,
  notes text,
  emergency_contact text,
  bank_name text,
  account_number text,
  ifsc text,
  upi_id text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Create Attendance Table
create table public.attendance (
  id uuid primary key default gen_random_uuid(),
  contractor_id uuid references public.profiles(id) on delete cascade not null,
  worker_id uuid references public.workers(id) on delete cascade not null,
  project_id uuid references public.projects(id) on delete set null,
  date date not null,
  status text not null, -- 'Present', 'Absent', 'Half Day', 'Leave', 'Holiday', 'Overtime'
  working_hours numeric(4, 2) default 0.00 not null,
  overtime_hours numeric(4, 2) default 0.00 not null,
  remarks text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  constraint unique_worker_date unique (worker_id, date)
);

-- 6. Create Daily Wages Table (holds wages calculated per attendance record)
create table public.daily_wages (
  id uuid primary key default gen_random_uuid(),
  contractor_id uuid references public.profiles(id) on delete cascade not null,
  worker_id uuid references public.workers(id) on delete cascade not null,
  attendance_id uuid references public.attendance(id) on delete cascade not null unique,
  daily_rate numeric(10, 2) default 0.00 not null,
  bonus numeric(10, 2) default 0.00 not null,
  deduction numeric(10, 2) default 0.00 not null,
  overtime_amount numeric(10, 2) default 0.00 not null,
  net_amount numeric(10, 2) default 0.00 not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 7. Create Transactions Table (financial records: Salary payments, advances given)
create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  contractor_id uuid references public.profiles(id) on delete cascade not null,
  worker_id uuid references public.workers(id) on delete cascade not null,
  project_id uuid references public.projects(id) on delete set null,
  transaction_type text not null, -- 'Salary', 'Advance', 'Bonus', 'Deduction', 'Adjustment'
  amount numeric(10, 2) default 0.00 not null,
  payment_method text not null, -- 'Cash', 'UPI', 'Bank', 'Cheque'
  reference_number text,
  transaction_date date not null,
  remarks text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 8. Create Monthly Summary Table (cache for performance, matching traditional rojgar card columns)
create table public.monthly_summary (
  id uuid primary key default gen_random_uuid(),
  contractor_id uuid references public.profiles(id) on delete cascade not null,
  worker_id uuid references public.workers(id) on delete cascade not null,
  month integer not null check (month >= 1 and month <= 12),
  year integer not null,
  present_days numeric(4, 1) default 0.0 not null,
  half_days numeric(4, 1) default 0.0 not null,
  leave_days numeric(4, 1) default 0.0 not null,
  absent_days numeric(4, 1) default 0.0 not null,
  holiday_days numeric(4, 1) default 0.0 not null,
  overtime_hours numeric(6, 2) default 0.00 not null,
  gross_amount numeric(12, 2) default 0.00 not null,
  bonus numeric(12, 2) default 0.00 not null,
  deduction numeric(12, 2) default 0.00 not null,
  advance numeric(12, 2) default 0.00 not null,
  paid numeric(12, 2) default 0.00 not null,
  balance numeric(12, 2) default 0.00 not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  constraint unique_worker_month_year unique (worker_id, month, year)
);

-- 9. Create Documents Table
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  contractor_id uuid references public.profiles(id) on delete cascade not null,
  worker_id uuid references public.workers(id) on delete cascade not null,
  document_type text not null, -- 'Aadhar', 'PAN', 'Driving License', 'Bank Passbook', 'Other'
  file_url text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 10. Create Notes Table
create table public.notes (
  id uuid primary key default gen_random_uuid(),
  contractor_id uuid references public.profiles(id) on delete cascade not null,
  worker_id uuid references public.workers(id) on delete cascade not null,
  note text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 11. Create Activity Logs Table
create table public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  action text not null,
  table_name text not null,
  record_id uuid not null,
  device text,
  ip text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 12. Create Notifications Table
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  contractor_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  body text not null,
  read boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ====================================================
-- TRIGGERS AND FUNCTIONS
-- ====================================================

-- Trigger: Automatically update updated_at timestamp
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$ language plpgsql;

create trigger t_profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger t_projects_updated_at before update on public.projects for each row execute function public.set_updated_at();
create trigger t_workers_updated_at before update on public.workers for each row execute function public.set_updated_at();
create trigger t_attendance_updated_at before update on public.attendance for each row execute function public.set_updated_at();
create trigger t_daily_wages_updated_at before update on public.daily_wages for each row execute function public.set_updated_at();
create trigger t_transactions_updated_at before update on public.transactions for each row execute function public.set_updated_at();
create trigger t_monthly_summary_updated_at before update on public.monthly_summary for each row execute function public.set_updated_at();
create trigger t_documents_updated_at before update on public.documents for each row execute function public.set_updated_at();
create trigger t_notes_updated_at before update on public.notes for each row execute function public.set_updated_at();
create trigger t_notifications_updated_at before update on public.notifications for each row execute function public.set_updated_at();

-- Trigger: Automatically insert profile when new user registers
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, company_name, language, currency)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'Contractor'),
    coalesce(new.raw_user_meta_data->>'company_name', 'My Company'),
    'en',
    'INR'
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Trigger: Automatically compute daily wage whenever attendance is added or updated
create or replace function public.calculate_daily_wage()
returns trigger as $$
declare
  w_wage numeric(10, 2);
  w_ot_rate numeric(10, 2);
  wage_factor numeric(3, 2);
  calc_ot_amount numeric(10, 2);
  calc_net numeric(10, 2);
  exist_id uuid;
begin
  -- Get worker wage properties
  select daily_wage, overtime_rate into w_wage, w_ot_rate from public.workers where id = new.worker_id;
  
  -- Determine wage scale factor based on attendance status
  case new.status
    when 'Present' then wage_factor := 1.0;
    when 'Half Day' then wage_factor := 0.5;
    when 'Leave' then wage_factor := 0.0;
    when 'Absent' then wage_factor := 0.0;
    when 'Holiday' then wage_factor := 0.0; -- depends on contractor policies, defaults to 0.0 (paid separately as allowance/bonus if needed)
    when 'Overtime' then wage_factor := 1.0; -- regular present + overtime hours
    else wage_factor := 1.0;
  end case;

  -- Calculate overtime amount
  calc_ot_amount := new.overtime_hours * w_ot_rate;
  
  -- Check if daily_wages record exists
  select id into exist_id from public.daily_wages where attendance_id = new.id;
  
  if exist_id is not null then
    update public.daily_wages
    set
      daily_rate = w_wage,
      overtime_amount = calc_ot_amount,
      net_amount = (w_wage * wage_factor) + calc_ot_amount + bonus - deduction,
      updated_at = timezone('utc'::text, now())
    where id = exist_id;
  else
    insert into public.daily_wages (contractor_id, worker_id, attendance_id, daily_rate, bonus, deduction, overtime_amount, net_amount)
    values (
      new.contractor_id,
      new.worker_id,
      new.id,
      w_wage,
      0.00,
      0.00,
      calc_ot_amount,
      (w_wage * wage_factor) + calc_ot_amount
    );
  end if;
  
  return new;
end;
$$ language plpgsql;

create trigger t_attendance_wage_calc
  after insert or update of status, overtime_hours on public.attendance
  for each row execute function public.calculate_daily_wage();

-- Trigger Function: Recalculate Monthly Summary cache
create or replace function public.recalculate_monthly_summary()
returns trigger as $$
declare
  tgt_worker_id uuid;
  tgt_contractor_id uuid;
  tgt_month integer;
  tgt_year integer;
  
  v_present_days numeric(4, 1) := 0;
  v_half_days numeric(4, 1) := 0;
  v_leave_days numeric(4, 1) := 0;
  v_absent_days numeric(4, 1) := 0;
  v_holiday_days numeric(4, 1) := 0;
  v_overtime_hours numeric(6, 2) := 0;
  
  v_gross_amount numeric(12, 2) := 0;
  v_bonus numeric(12, 2) := 0;
  v_deduction numeric(12, 2) := 0;
  v_advance numeric(12, 2) := 0;
  v_paid numeric(12, 2) := 0;
  v_balance numeric(12, 2) := 0;
begin
  -- Set target parameters based on the operation
  if tg_op = 'DELETE' then
    tgt_worker_id := old.worker_id;
    tgt_contractor_id := old.contractor_id;
    if tg_table_name = 'attendance' then
      tgt_month := extract(month from old.date);
      tgt_year := extract(year from old.date);
    elsif tg_table_name = 'transactions' then
      tgt_month := extract(month from old.transaction_date);
      tgt_year := extract(year from old.transaction_date);
    elsif tg_table_name = 'daily_wages' then
      -- Need to get date from attendance
      select extract(month from date), extract(year from date) into tgt_month, tgt_year
      from public.attendance where id = old.attendance_id;
    end if;
  else
    tgt_worker_id := new.worker_id;
    tgt_contractor_id := new.contractor_id;
    if tg_table_name = 'attendance' then
      tgt_month := extract(month from new.date);
      tgt_year := extract(year from new.date);
    elsif tg_table_name = 'transactions' then
      tgt_month := extract(month from new.transaction_date);
      tgt_year := extract(year from new.transaction_date);
    elsif tg_table_name = 'daily_wages' then
      select extract(month from date), extract(year from date) into tgt_month, tgt_year
      from public.attendance where id = new.attendance_id;
    end if;
  end if;

  if tgt_worker_id is null or tgt_month is null or tgt_year is null then
    return null;
  end if;

  -- 1. Summarize attendance stats
  select
    coalesce(sum(case when status = 'Present' or status = 'Overtime' then 1 else 0 end), 0),
    coalesce(sum(case when status = 'Half Day' then 1 else 0 end), 0),
    coalesce(sum(case when status = 'Leave' then 1 else 0 end), 0),
    coalesce(sum(case when status = 'Absent' then 1 else 0 end), 0),
    coalesce(sum(case when status = 'Holiday' then 1 else 0 end), 0),
    coalesce(sum(overtime_hours), 0)
  into
    v_present_days, v_half_days, v_leave_days, v_absent_days, v_holiday_days, v_overtime_hours
  from public.attendance
  where worker_id = tgt_worker_id and extract(month from date) = tgt_month and extract(year from date) = tgt_year;

  -- 2. Summarize wages & daily adjustments (bonus/deduction)
  select
    coalesce(sum(net_amount), 0),
    coalesce(sum(bonus), 0),
    coalesce(sum(deduction), 0)
  into
    v_gross_amount, v_bonus, v_deduction
  from public.daily_wages dw
  join public.attendance att on dw.attendance_id = att.id
  where dw.worker_id = tgt_worker_id and extract(month from att.date) = tgt_month and extract(year from att.date) = tgt_year;

  -- 3. Summarize transactions (payments & advances)
  -- Advance Transaction: money given out in advance (increases worker balance/due or tracked as advance)
  -- Salary Transaction: actual salary payouts
  select
    coalesce(sum(case when transaction_type = 'Advance' then amount else 0 end), 0),
    coalesce(sum(case when transaction_type = 'Salary' then amount else 0 end), 0),
    coalesce(sum(case when transaction_type = 'Bonus' then amount else 0 end), 0),
    coalesce(sum(case when transaction_type = 'Deduction' then amount else 0 end), 0)
  into
    v_advance, v_paid, v_bonus, v_deduction
  from public.transactions
  where worker_id = tgt_worker_id and extract(month from transaction_date) = tgt_month and extract(year from transaction_date) = tgt_year;

  -- Calculate remaining balance
  -- Balance = Gross Wage + Advance (given to worker, needs to be deducted) - Paid (Salary payouts)
  -- In Gujarati Rojgar system: Balance Due to worker = Gross Wages + Bonus - Deductions - Advance - Paid
  v_balance := v_gross_amount - v_advance - v_paid;

  -- Upsert Monthly Summary
  insert into public.monthly_summary (
    contractor_id, worker_id, month, year,
    present_days, half_days, leave_days, absent_days, holiday_days, overtime_hours,
    gross_amount, bonus, deduction, advance, paid, balance
  )
  values (
    tgt_contractor_id, tgt_worker_id, tgt_month, tgt_year,
    v_present_days, v_half_days, v_leave_days, v_absent_days, v_holiday_days, v_overtime_hours,
    v_gross_amount, v_bonus, v_deduction, v_advance, v_paid, v_balance
  )
  on conflict (worker_id, month, year)
  do update set
    present_days = excluded.present_days,
    half_days = excluded.half_days,
    leave_days = excluded.leave_days,
    absent_days = excluded.absent_days,
    holiday_days = excluded.holiday_days,
    overtime_hours = excluded.overtime_hours,
    gross_amount = excluded.gross_amount,
    bonus = excluded.bonus,
    deduction = excluded.deduction,
    advance = excluded.advance,
    paid = excluded.paid,
    balance = excluded.balance,
    updated_at = timezone('utc'::text, now());

  return null;
end;
$$ language plpgsql;

-- Apply Monthly Summary Trigger to Attendance, Daily Wages, and Transactions
create trigger t_attendance_monthly_summary
  after insert or update or delete on public.attendance
  for each row execute function public.recalculate_monthly_summary();

create trigger t_wages_monthly_summary
  after insert or update or delete on public.daily_wages
  for each row execute function public.recalculate_monthly_summary();

create trigger t_transactions_monthly_summary
  after insert or update or delete on public.transactions
  for each row execute function public.recalculate_monthly_summary();


-- ====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================

alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.workers enable row level security;
alter table public.attendance enable row level security;
alter table public.daily_wages enable row level security;
alter table public.transactions enable row level security;
alter table public.monthly_summary enable row level security;
alter table public.documents enable row level security;
alter table public.notes enable row level security;
alter table public.activity_logs enable row level security;
alter table public.notifications enable row level security;

-- Profiles Policies
create policy "Contractors can view their own profile" on public.profiles for select using (auth.uid() = id);
create policy "Contractors can update their own profile" on public.profiles for update using (auth.uid() = id);

-- Projects Policies
create policy "Contractors can manage their own projects" on public.projects
  for all using (auth.uid() = contractor_id) with check (auth.uid() = contractor_id);

-- Workers Policies
create policy "Contractors can manage their own workers" on public.workers
  for all using (auth.uid() = contractor_id) with check (auth.uid() = contractor_id);

-- Attendance Policies
create policy "Contractors can manage attendance" on public.attendance
  for all using (auth.uid() = contractor_id) with check (auth.uid() = contractor_id);

-- Daily Wages Policies
create policy "Contractors can manage daily wages" on public.daily_wages
  for all using (auth.uid() = contractor_id) with check (auth.uid() = contractor_id);

-- Transactions Policies
create policy "Contractors can manage transactions" on public.transactions
  for all using (auth.uid() = contractor_id) with check (auth.uid() = contractor_id);

-- Monthly Summary Policies
create policy "Contractors can manage monthly summaries" on public.monthly_summary
  for all using (auth.uid() = contractor_id) with check (auth.uid() = contractor_id);

-- Documents Policies
create policy "Contractors can manage documents" on public.documents
  for all using (auth.uid() = contractor_id) with check (auth.uid() = contractor_id);

-- Notes Policies
create policy "Contractors can manage notes" on public.notes
  for all using (auth.uid() = contractor_id) with check (auth.uid() = contractor_id);

-- Activity Logs Policies
create policy "Contractors can view their own activity logs" on public.activity_logs
  for select using (auth.uid() = user_id);
create policy "Contractors can insert their own activity logs" on public.activity_logs
  for insert with check (auth.uid() = user_id);

-- Notifications Policies
create policy "Contractors can manage their notifications" on public.notifications
  for all using (auth.uid() = contractor_id) with check (auth.uid() = contractor_id);


-- ====================================================
-- OPTIMIZED VIEWS AND INDEXES
-- ====================================================

-- View: Today's Attendance Overview
create or replace view public.view_todays_attendance as
select
  a.id,
  a.contractor_id,
  a.worker_id,
  w.full_name as worker_name,
  a.project_id,
  p.name as project_name,
  a.date,
  a.status,
  a.working_hours,
  a.overtime_hours,
  a.remarks
from public.attendance a
join public.workers w on a.worker_id = w.id
left join public.projects p on a.project_id = p.id
where a.date = current_date;

-- View: Today's Wage & Expense Overview
create or replace view public.view_todays_wages as
select
  dw.contractor_id,
  dw.worker_id,
  w.full_name as worker_name,
  att.project_id,
  dw.net_amount,
  dw.bonus,
  dw.deduction,
  dw.overtime_amount,
  att.date
from public.daily_wages dw
join public.attendance att on dw.attendance_id = att.id
join public.workers w on dw.worker_id = w.id
where att.date = current_date;

-- View: Pending Salary / Balances Due
create or replace view public.view_worker_dues as
select
  w.id as worker_id,
  w.contractor_id,
  w.full_name as worker_name,
  w.daily_wage,
  coalesce(sum(ms.balance), 0) as total_balance_due
from public.workers w
left join public.monthly_summary ms on w.id = ms.worker_id
group by w.id, w.contractor_id, w.full_name, w.daily_wage;

-- Create Indexes for performance
create index idx_workers_contractor on public.workers(contractor_id);
create index idx_projects_contractor on public.projects(contractor_id);
create index idx_attendance_date on public.attendance(date);
create index idx_attendance_worker_date on public.attendance(worker_id, date);
create index idx_daily_wages_attendance on public.daily_wages(attendance_id);
create index idx_transactions_worker on public.transactions(worker_id);
create index idx_transactions_date on public.transactions(transaction_date);
create index idx_monthly_summary_worker on public.monthly_summary(worker_id);
create index idx_monthly_summary_year_month on public.monthly_summary(year, month);
