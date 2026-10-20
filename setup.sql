-- Toploader database setup. Paste all of this into Supabase's SQL Editor and
-- press Run. Safe to run again.

-- Listings: anyone can read them; signed-in people add, edit, and delete
-- only their own.
create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  seller_name text not null default '' check (char_length(seller_name) <= 40),
  title text not null check (char_length(title) between 1 and 80),
  category text not null default 'Other',
  set_name text not null default '' check (char_length(set_name) <= 60),
  year text not null default '' check (char_length(year) <= 4),
  number text not null default '' check (char_length(number) <= 20),
  version text not null default '' check (char_length(version) <= 60),
  condition text not null default 'NM',
  grade text not null default '' check (char_length(grade) <= 16),
  mode text not null default 'sale' check (mode in ('sale', 'trade', 'both')),
  price numeric check (price is null or (price >= 0 and price < 1000000)),
  wants text not null default '' check (char_length(wants) <= 120),
  notes text not null default '' check (char_length(notes) <= 500),
  contact text not null check (char_length(contact) between 1 and 120),
  photos text[] not null default '{}' check (cardinality(photos) <= 4),
  sold boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.listings enable row level security;

drop policy if exists "Anyone can see listings" on public.listings;
create policy "Anyone can see listings" on public.listings
  for select using (true);

drop policy if exists "Signed-in users add their own" on public.listings;
create policy "Signed-in users add their own" on public.listings
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Owners edit their own" on public.listings;
create policy "Owners edit their own" on public.listings
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Owners delete their own" on public.listings;
create policy "Owners delete their own" on public.listings
  for delete to authenticated using (auth.uid() = user_id);

-- Card photos: public to view; each person uploads only into their own folder.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('card-photos', 'card-photos', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "Anyone can view card photos" on storage.objects;
create policy "Anyone can view card photos" on storage.objects
  for select using (bucket_id = 'card-photos');

drop policy if exists "Users upload to their own folder" on storage.objects;
create policy "Users upload to their own folder" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'card-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users delete their own photos" on storage.objects;
create policy "Users delete their own photos" on storage.objects
  for delete to authenticated
  using (bucket_id = 'card-photos' and (storage.foldername(name))[1] = auth.uid()::text);
