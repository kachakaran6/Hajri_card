This is actually a **huge business opportunity**.

In Gujarat, Rajasthan, Maharashtra and many other states, lakhs of contractors still use these small **Hajri/Rojgar Cards** because they're simple, fast and don't require training.

The mistake most developers make is creating an ERP.

**Don't build an ERP. Build a digital version of this exact card.**

---

# Product Vision

> **Digital Rojgar Book**
>
> "The easiest labour attendance and wage management system."

Target users

* Civil Contractors
* Tile Contractors
* Electricians
* Plumbers
* Fabricators
* Builders
* Farm Contractors
* Labour Suppliers
* Small Factories

Age group

30-60

Most users are **not tech savvy.**

Everything should work in **3 taps maximum.**

---

# UX Principles

## Never show complex dashboard first.

Open app →

```
Today's Labour
```

Big Cards

```
+ Add Labour

Today's Attendance

Payments

Reports
```

Nothing else.

---

# Swipe Actions

Every labour card

```
← Swipe Left

Pay
Advance
Edit
History

→ Swipe Right

Present
Half Day
Absent
Overtime
```

No buttons.

Just swipe.

---

# Big FAB

Bottom Right

```
+
```

One tap

```
Add Labour

Take Attendance

Pay Salary

Give Advance
```

---

# Labour Card

```
👤

Ramesh Solanki

₹700/day

Present Today

12 Days

₹8400 Due

Swipe →
```

Large fonts.

Large touch targets.

---

# Home Screen

```
Good Morning

Today

Present 28

Absent 4

Today's Wage

₹18,900

--------------------

Labour List

--------------------

Floating +
```

---

# Labour Profile

Exactly like this paper card.

Tabs

```
Overview

Attendance

Payments

Reports
```

---

Overview

```
Photo

Name

Phone

Village

Joining Date

Daily Wage

Current Due

Advance

Balance
```

---

Attendance

Calendar

```
P

P

A

H

OT
```

Tap

Change instantly.

---

Payments

Timeline

```
Paid ₹2000

Advance ₹500

Bonus ₹1000

Deduction ₹200
```

---

Reports

Monthly

PDF

WhatsApp

Print

---

# Attendance Screen

Most used page.

Large cards.

```
☑ Present

☑ Half

☑ Absent

☑ OT
```

Tap.

Done.

---

Long press

Multiple select.

---

# Daily Wage Entry

```
Present

700

OT

2 Hours

Bonus

200

Deduction

50

Save
```

---

# Monthly Summary

Exactly same as physical card.

```
Total Days

Present

Half

OT

Total Wage

Advance

Paid

Remaining

```

---

# Offline First

Very important.

Works without internet.

Sync later.

---

# Languages

Gujarati

Hindi

English

One tap change.

---

# Notifications

Morning

```
Take Attendance
```

Evening

```
Today's Payment Pending
```

---

# Reports

Generate

```
Monthly Card

Salary Sheet

Attendance Sheet

Payment History

Contract Wise

Worker Ledger
```

---

# QR Code

Every labour gets

QR

Scan

Open profile instantly.

---

# Search

Search

```
Name

Phone

Village

ID

QR
```

---

# Contractor Dashboard

```
Projects

Workers

Today's Expense

Pending Amount

Cash Flow
```

---

# Supabase Database Design Prompt

Copy this directly into Cursor/Claude/ChatGPT.

---

```text
You are a Senior Supabase Database Architect.

Design a complete production-ready PostgreSQL schema for a Labour Management System inspired by the traditional Gujarati Hajri/Rojgar Card.

The system must support thousands of contractors and lakhs of workers.

Use UUID primary keys.

Enable Row Level Security on every table.

Every table should contain

id
created_at
updated_at

--------------------------------------------------

AUTH

Use Supabase Auth.

Each contractor owns only their own data.

Never expose another contractor's data.

--------------------------------------------------

TABLES

profiles

- auth_user_id
- full_name
- company_name
- phone
- language
- currency
- avatar

--------------------------------------------------

projects

- contractor_id
- name
- location
- start_date
- end_date
- status
- notes

--------------------------------------------------

workers

Equivalent to physical rojgar card.

Fields

photo

worker_code

full_name

phone

father_name

address

village

city

state

joining_date

daily_wage

overtime_rate

status

default_project

notes

emergency_contact

bank_name

account_number

ifsc

upi_id

--------------------------------------------------

attendance

worker_id

project_id

date

status

Present

Absent

Half Day

Leave

Holiday

Overtime

working_hours

overtime_hours

remarks

--------------------------------------------------

daily_wages

worker_id

attendance_id

daily_rate

bonus

deduction

overtime_amount

net_amount

--------------------------------------------------

transactions

worker_id

project_id

transaction_type

Salary

Advance

Bonus

Deduction

Adjustment

amount

payment_method

Cash

UPI

Bank

Cheque

reference_number

transaction_date

remarks

--------------------------------------------------

monthly_summary

worker_id

month

year

present_days

half_days

leave_days

absent_days

holiday_days

overtime_hours

gross_amount

bonus

deduction

advance

paid

balance

--------------------------------------------------

documents

worker_id

document_type

Aadhar

PAN

Driving License

Bank Passbook

Other

file_url

--------------------------------------------------

notes

worker_id

note

--------------------------------------------------

activity_logs

user_id

action

table_name

record_id

device

ip

--------------------------------------------------

notifications

contractor_id

title

body

read

--------------------------------------------------

SETUP

Create

Indexes

Foreign Keys

Constraints

Cascade Deletes

Unique Constraints

Triggers

updated_at trigger

Audit triggers

Generate SQL

Generate RLS Policies

Generate Storage Buckets

Generate helper SQL Functions

Generate Views

Today's Attendance

Today's Expense

Pending Salary

Monthly Summary

Most Active Workers

--------------------------------------------------

Performance

Partition attendance by month.

Create optimized indexes.

No duplicate attendance per worker per day.

Support offline sync.

--------------------------------------------------

Output only production-ready SQL.
```

---

# React Frontend Prompt

```text
Build a production-ready mobile-first React application using:

- React 19
- Vite
- TypeScript
- Tailwind CSS v4
- shadcn/ui
- React Bits
- 21st.dev components
- Framer Motion
- TanStack Query
- React Hook Form
- Zod
- Supabase

Design Goals:

- Inspired by WhatsApp simplicity.
- Every action should take 3 taps or fewer.
- Large touch targets.
- Thumb-friendly navigation.
- Swipe gestures everywhere.
- Smooth 60 FPS animations.
- Offline-first with sync indicators.
- Gujarati, Hindi, and English support.
- Light and Dark themes.
- Beautiful empty states and skeleton loaders.
- Consistent design tokens and reusable components.

Core Screens:
1. Dashboard
2. Workers List
3. Worker Profile
4. Attendance
5. Payments
6. Projects
7. Reports
8. Settings

Interactions:
- Swipe right: Mark Present/Half Day/Absent/OT.
- Swipe left: Pay, Advance, Edit, History.
- Long press: Multi-select workers.
- Bottom sheet for quick actions.
- Floating Action Button for primary actions.
- One-tap attendance mode.
- Monthly card view that visually matches the traditional paper Hajri card.

Generate:
- Folder structure
- Routing
- Component architecture
- State management
- Reusable UI components
- Mobile-first responsive layout
- Accessibility
- Performance optimizations
- Error handling
- Offline sync strategy
- Production-ready code architecture
```

## One feature that will make this app stand out

**"Digital Hajri Card" mode.**

Instead of forcing contractors to use tables, show each worker's profile as a **digital version of the yellow paper card** (like the one you shared). They can tap each day's row to mark attendance, enter wages, advances, or payments. This familiar layout means even non-technical users can switch from paper to digital with almost no learning curve, making adoption dramatically easier.
