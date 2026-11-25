insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
    'site-images',
    'site-images',
    true,
    10485760,
    array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
    public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Users can view their own site image listings" on storage.objects;
create policy "Users can view their own site image listings"
on storage.objects for select
using (
    bucket_id = 'site-images'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can upload their own site images" on storage.objects;
create policy "Users can upload their own site images"
on storage.objects for insert
with check (
    bucket_id = 'site-images'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can update their own site images" on storage.objects;
create policy "Users can update their own site images"
on storage.objects for update
using (
    bucket_id = 'site-images'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
    bucket_id = 'site-images'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can delete their own site images" on storage.objects;
create policy "Users can delete their own site images"
on storage.objects for delete
using (
    bucket_id = 'site-images'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
);
