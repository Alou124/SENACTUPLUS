-- SenActuPlus : à exécuter UNE fois dans Supabase > SQL Editor > New query > Run.

create table if not exists public.admins (user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.admins enable row level security;  -- aucune policy : illisible/inscriptible depuis le navigateur

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as
$$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;

create table if not exists public.articles (
  id bigint generated always as identity primary key,
  slug text unique not null,
  title text not null check (char_length(title) between 3 and 200),
  category text not null,
  chapo text,
  body text,
  image_url text,
  author text not null default 'Rédaction',
  tag text,
  featured boolean not null default false,
  breaking boolean not null default false,
  published boolean not null default true,
  views integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.articles enable row level security;

create policy "lecture publique des articles publiés" on public.articles
  for select using (published or public.is_admin());
create policy "admin insère" on public.articles for insert to authenticated with check (public.is_admin());
create policy "admin modifie" on public.articles for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin supprime" on public.articles for delete to authenticated using (public.is_admin());

-- Compteur de lectures (seule action d'écriture permise aux visiteurs)
create or replace function public.increment_views(p_id bigint) returns void
language sql security definer set search_path = public as
$$ update public.articles set views = views + 1 where id = p_id and published $$;
grant execute on function public.increment_views(bigint) to anon, authenticated;

-- Images des articles
insert into storage.buckets (id, name, public) values ('article-images','article-images', true) on conflict (id) do nothing;
create policy "images : lecture publique" on storage.objects for select using (bucket_id = 'article-images');
create policy "images : admin envoie" on storage.objects for insert to authenticated with check (bucket_id = 'article-images' and public.is_admin());
create policy "images : admin modifie" on storage.objects for update to authenticated using (bucket_id = 'article-images' and public.is_admin());
create policy "images : admin supprime" on storage.objects for delete to authenticated using (bucket_id = 'article-images' and public.is_admin());

-- ÉTAPE FINALE : après avoir créé votre utilisateur (Authentication > Users > Add user),
-- remplacez l'e-mail ci-dessous par le vôtre et exécutez cette ligne :
-- insert into public.admins (user_id) select id from auth.users where email = 'VOTRE_EMAIL@exemple.com';
grant execute on function public.is_admin() to anon, authenticated;
