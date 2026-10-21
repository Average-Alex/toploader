-- setup.sql: builds the database for Toploader.
--
-- This is SQL, the language databases use. Lines starting with -- are
-- comments: the database ignores them.
--
-- How to use it: in Supabase, open SQL Editor, paste all of this in, and press
-- Run. It's safe to run again ("if not exists" and "drop ... if exists" skip or
-- replace things that are already there).
--
-- It makes three things:
--   1. a "listings" table: one row per card someone posts
--   2. security rules saying who can read and change listings
--   3. a "card-photos" storage area for the photos, with its own rules


-- ===================== 1. The listings table =====================
-- A table is like a spreadsheet: each column is one detail, each row is one
-- listing. Each line below is a column: its name, its type, and its rules.
--   text        = words
--   numeric     = a number (with decimals allowed)
--   boolean     = true or false
--   uuid        = a long unique ID, like 3f2b8c1e-...
--   text[]      = a list of words
--   timestamptz = a date and time
--   not null    = it must have a value
--   default ... = the value used when none is given
--   check (...) = a rule the value must pass, or the row is refused
create table if not exists public.listings (
  -- The listing's own unique ID. gen_random_uuid() makes one automatically.
  id uuid primary key default gen_random_uuid(),
  -- Which account posted it. auth.uid() means "whoever is signed in".
  -- "references auth.users" links it to that account, and "on delete cascade"
  -- deletes their listings if the account is ever deleted.
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  -- The seller's display name, shown on the card (char_length = number of letters).
  seller_name text not null default '' check (char_length(seller_name) <= 40),
  -- The card's name: required, 1 to 80 letters.
  title text not null check (char_length(title) between 1 and 80),
  -- The card type: Pokémon, Sports, Magic, Yu-Gi-Oh!, One Piece, or Other.
  category text not null default 'Other',
  -- The set or series, like "Base Set" (optional).
  set_name text not null default '' check (char_length(set_name) <= 60),
  -- The year, like 1999 (optional).
  year text not null default '' check (char_length(year) <= 4),
  -- The card number, like 4/102 (optional).
  number text not null default '' check (char_length(number) <= 20),
  -- The version, like "Foil" or "Purple Prizm" (optional).
  version text not null default '' check (char_length(version) <= 60),
  -- The condition code: M, NM, LP, MP, HP, DMG, or GRADED.
  condition text not null default 'NM',
  -- The grade for graded cards, like "PSA 9" (optional).
  grade text not null default '' check (char_length(grade) <= 16),
  -- Selling, trading, or either. Any other value is refused.
  mode text not null default 'sale' check (mode in ('sale', 'trade', 'both')),
  -- The asking price in dollars. Empty (null) for trades; never negative.
  price numeric check (price is null or (price >= 0 and price < 1000000)),
  -- What they want in a trade (optional).
  wants text not null default '' check (char_length(wants) <= 120),
  -- Extra notes about the card (optional, up to 500 letters).
  notes text not null default '' check (char_length(notes) <= 500),
  -- How to reach the seller: required.
  contact text not null check (char_length(contact) between 1 and 120),
  -- The file names of its photos in storage, up to 4 (cardinality = how many).
  photos text[] not null default '{}' check (cardinality(photos) <= 4),
  -- Whether it's been sold.
  sold boolean not null default false,
  -- When it was posted. now() fills in the current date and time.
  created_at timestamptz not null default now()
);


-- ===================== 2. Who can do what with listings =====================
-- Row Level Security (RLS) checks a rule ("policy") for every row, every time
-- someone reads or changes the table. With it turned on, nothing is allowed
-- unless a policy below allows it. This is what keeps the public website key
-- in config.js safe.
alter table public.listings enable row level security;

-- Each policy is first dropped (if it already exists) and then created, so
-- running this file again doesn't cause an error.

-- Reading ("select"): anyone, even people who aren't signed in, can see every
-- listing. using (true) means "for every row".
drop policy if exists "Anyone can see listings" on public.listings;
create policy "Anyone can see listings" on public.listings
  for select using (true);

-- Adding ("insert"): only signed-in people ("authenticated"), and only
-- listings with their own account ID. So nobody can post as someone else.
drop policy if exists "Signed-in users add their own" on public.listings;
create policy "Signed-in users add their own" on public.listings
  for insert to authenticated with check (auth.uid() = user_id);

-- Changing ("update", like marking a card sold): only your own listings
-- ("using"), and you can't hand one over to another account ("with check").
drop policy if exists "Owners edit their own" on public.listings;
create policy "Owners edit their own" on public.listings
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Deleting: only your own listings.
drop policy if exists "Owners delete their own" on public.listings;
create policy "Owners delete their own" on public.listings
  for delete to authenticated using (auth.uid() = user_id);


-- ===================== 3. Card photo storage =====================
-- A "bucket" is a folder for files. This makes one called card-photos:
--   public = true      anyone can view the photos by their web address
--   5242880            the biggest file allowed, in bytes (5 MB)
--   allowed_mime_types only pictures (JPEG, PNG, WebP)
-- "on conflict do nothing" skips this if the bucket already exists.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('card-photos', 'card-photos', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Viewing photos: anyone.
drop policy if exists "Anyone can view card photos" on storage.objects;
create policy "Anyone can view card photos" on storage.objects
  for select using (bucket_id = 'card-photos');

-- Uploading: only signed-in people, and only into the folder named after their
-- own account ID. (storage.foldername(name))[1] is the first folder in the
-- file's path, and auth.uid()::text is your account ID as text.
drop policy if exists "Users upload to their own folder" on storage.objects;
create policy "Users upload to their own folder" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'card-photos' and (storage.foldername(name))[1] = auth.uid()::text);

-- Deleting photos: only the ones in your own folder.
drop policy if exists "Users delete their own photos" on storage.objects;
create policy "Users delete their own photos" on storage.objects
  for delete to authenticated
  using (bucket_id = 'card-photos' and (storage.foldername(name))[1] = auth.uid()::text);
