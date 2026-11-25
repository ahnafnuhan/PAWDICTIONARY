create table if not exists public.pet_talk_messages (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    display_name text not null,
    body text not null check (char_length(body) between 1 and 1000),
    created_at timestamptz not null default now()
);

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
