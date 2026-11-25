create table if not exists public.pet_talk_messages (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    display_name text not null,
    avatar_url text,
    body text check (body is null or char_length(body) between 1 and 1000),
    image_url text,
    created_at timestamptz not null default now()
);

alter table public.pet_talk_messages
    alter column body drop not null;

alter table public.pet_talk_messages
    add column if not exists image_url text;

alter table public.pet_talk_messages
    add column if not exists avatar_url text;

alter table public.pet_talk_messages
    drop constraint if exists pet_talk_messages_body_check;

alter table public.pet_talk_messages
    add constraint pet_talk_messages_body_check
    check (body is null or char_length(body) between 1 and 1000);

alter table public.pet_talk_messages
    drop constraint if exists pet_talk_messages_content_check;

alter table public.pet_talk_messages
    add constraint pet_talk_messages_content_check
    check (body is not null or image_url is not null);

alter table public.pet_talk_messages enable row level security;

drop policy if exists "Signed-in users can read PetTalk messages" on public.pet_talk_messages;
create policy "Signed-in users can read PetTalk messages"
on public.pet_talk_messages
for select
to authenticated
using (true);

drop policy if exists "Users can send PetTalk messages" on public.pet_talk_messages;
create policy "Users can send PetTalk messages"
on public.pet_talk_messages
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can delete their PetTalk messages" on public.pet_talk_messages;
create policy "Users can delete their PetTalk messages"
on public.pet_talk_messages
for delete
to authenticated
using (user_id = auth.uid());

grant select, insert, delete on public.pet_talk_messages to authenticated;

create table if not exists public.public_profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    display_name text not null,
    avatar_url text,
    updated_at timestamptz not null default now()
);

alter table public.public_profiles enable row level security;

drop policy if exists "Public profiles are visible" on public.public_profiles;
create policy "Public profiles are visible"
on public.public_profiles
for select
to authenticated
using (true);

drop policy if exists "Users can update their public profile" on public.public_profiles;
create policy "Users can update their public profile"
on public.public_profiles
for insert
to authenticated
with check (id = auth.uid());

drop policy if exists "Users can edit their public profile" on public.public_profiles;
create policy "Users can edit their public profile"
on public.public_profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

grant select on public.public_profiles to authenticated;
grant insert, update on public.public_profiles to authenticated;

do $$
begin
    if not exists (
        select 1
        from pg_publication_tables
        where pubname = 'supabase_realtime'
          and schemaname = 'public'
          and tablename = 'pet_talk_messages'
    ) then
        alter publication supabase_realtime add table public.pet_talk_messages;
    end if;
end
$$;
