-- TaraCommute starter schema.
-- Run in Supabase SQL Editor. This creates starter tables only.
-- Do not store sensitive emergency details or public reports without a reviewed privacy design.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  preferred_language text not null default 'en'
    check (preferred_language in ('en', 'fil')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.community_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete set null,
  report_type text not null check (
    report_type in ('accident', 'traffic', 'road_closure', 'flood', 'road_hazard', 'other')
  ),
  description text,
  -- Coordinates are nullable until the app obtains a real, user-approved GPS position.
  latitude double precision,
  longitude double precision,
  gps_accuracy_m double precision,
  status text not null default 'reported' check (
    status in ('reported', 'unverified', 'corroborated', 'authority_verified', 'resolved', 'expired')
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint valid_latitude check (latitude is null or latitude between -90 and 90),
  constraint valid_longitude check (longitude is null or longitude between -180 and 180)
);

alter table public.profiles enable row level security;
alter table public.community_reports enable row level security;

-- Users can read and update only their own profile.
drop policy if exists "profile_select_own" on public.profiles;
create policy "profile_select_own" on public.profiles
  for select to authenticated using (auth.uid() = id);

drop policy if exists "profile_update_own" on public.profiles;
create policy "profile_update_own" on public.profiles
  for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- Signed-in users may create a report under their own account.
drop policy if exists "reports_insert_own" on public.community_reports;
create policy "reports_insert_own" on public.community_reports
  for insert to authenticated with check (auth.uid() = reporter_id);

-- Reports are not publicly readable yet. Add carefully reviewed public-read rules only
-- after moderation, privacy controls, and incident grouping are implemented.
