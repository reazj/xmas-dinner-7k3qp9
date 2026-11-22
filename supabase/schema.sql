-- Christmas dinner sign-up: dishes table
-- Safe to run in a new project or an existing one (only touches public.dishes).

create table if not exists public.dishes (
  id          uuid primary key default gen_random_uuid(),
  course      text not null check (course in ('starters','snacks','sides','desserts','other')),
  dish        text not null check (char_length(btrim(dish)) between 1 and 120),
  guest_name  text not null check (char_length(btrim(guest_name)) between 1 and 60),
  notes       text check (notes is null or char_length(notes) <= 300),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create or replace function public.dishes_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists dishes_touch_updated_at on public.dishes;
create trigger dishes_touch_updated_at
  before update on public.dishes
  for each row execute function public.dishes_touch_updated_at();

-- No accounts: the public (anon) key may read, add, edit and remove dishes.
-- It can touch nothing else in the project.
alter table public.dishes enable row level security;

drop policy if exists "dishes read"   on public.dishes;
drop policy if exists "dishes insert" on public.dishes;
drop policy if exists "dishes update" on public.dishes;
drop policy if exists "dishes delete" on public.dishes;
create policy "dishes read"   on public.dishes for select to anon, authenticated using (true);
create policy "dishes insert" on public.dishes for insert to anon, authenticated with check (true);
create policy "dishes update" on public.dishes for update to anon, authenticated using (true) with check (true);
create policy "dishes delete" on public.dishes for delete to anon, authenticated using (true);

grant select, insert, update, delete on public.dishes to anon, authenticated;

-- Live updates so everyone's page refreshes when someone signs up.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'dishes'
  ) then
    alter publication supabase_realtime add table public.dishes;
  end if;
end $$;
