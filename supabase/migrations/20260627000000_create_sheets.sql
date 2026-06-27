-- M4: Schema da tabela de fichas
-- Execute este arquivo no SQL Editor do painel Supabase (https://supabase.com/dashboard).

create table public.sheets (
  id             uuid        primary key,
  user_id        uuid        not null references auth.users(id) on delete cascade,
  system_id      text        not null,
  level          int         not null default 1,
  base_abilities jsonb       not null default '{}',
  tree           jsonb       not null default '[]',
  character      jsonb       not null default '{}',
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- Índice para listagem por usuário (usado em listByUser)
create index sheets_user_id_idx on public.sheets (user_id);

-- Row Level Security: cada usuário vê e altera só as próprias fichas
alter table public.sheets enable row level security;

create policy "Usuário acessa apenas suas fichas"
  on public.sheets
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Mantém updated_at sincronizado automaticamente
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger sheets_updated_at
  before update on public.sheets
  for each row execute procedure public.set_updated_at();
