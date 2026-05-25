-- MoneyRush Database Schema
-- Run this in Supabase SQL Editor: supabase.com -> your project -> SQL Editor
-- Enable pgvector for RAG knowledge base
create extension if not exists vector;

-- ─────────────────────────────────────────────────────────────────────────────
-- PLAYERS
-- Extends Supabase auth.users. Created on sign-up.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.players (
  id uuid references auth.users(id) on delete cascade primary key,
  username text not null,
  avatar_config jsonb default '{}',
  advisor_config jsonb default '{}',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- KNOWLEDGE MAP
-- One row per player per domain. Scores 0-100.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.knowledge_maps (
  id uuid default gen_random_uuid() primary key,
  player_id uuid references public.players(id) on delete cascade,
  domain text not null,
  score integer default 0 check (score >= 0 and score <= 100),
  updated_at timestamptz default now(),
  unique(player_id, domain)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- GAME STATE
-- One row per player. Full financial simulation state.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.game_states (
  id uuid default gen_random_uuid() primary key,
  player_id uuid references public.players(id) on delete cascade unique,
  current_chapter integer default 1,
  in_game_date date default '2024-01-01',
  income_path text default 'employment',
  -- Financial state
  bank_balance decimal(12,2) default 1000.00,
  monthly_income decimal(10,2) default 0,
  monthly_expenses decimal(10,2) default 0,
  savings_balance decimal(12,2) default 0,
  investment_portfolio jsonb default '{}',
  debt_balance decimal(12,2) default 0,
  credit_card_balance decimal(10,2) default 0,
  credit_score integer default 650,
  emergency_fund decimal(10,2) default 0,
  net_worth decimal(12,2) default 1000.00,
  leisure_spending decimal(10,2) default 0,
  income_stream_count integer default 1,
  -- Five score dimensions (0-100)
  wealth_score integer default 50,
  stability_score integer default 50,
  growth_score integer default 50,
  freedom_score integer default 50,
  wellbeing_score integer default 50,
  life_score integer default 50,
  -- Life state
  has_partner boolean default false,
  has_children boolean default false,
  children_count integer default 0,
  family_state jsonb default '{}',
  -- Unlocked features
  unlocked_districts text[] default array['residential','work_district','market'],
  active_income_paths text[] default array['employment'],
  quiz_completed boolean default false,
  updated_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- SCENARIO LIBRARY
-- All scenarios. Seeded from Google Sheets via Apps Script.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.scenarios (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  situation text not null,
  options jsonb not null,
  domain text not null,
  chapter integer not null,
  difficulty integer default 1 check (difficulty >= 1 and difficulty <= 5),
  concept_tags text[] default array[]::text[],
  income_path_tags text[] default array[]::text[],
  life_stage_tags text[] default array[]::text[],
  is_active boolean default true,
  created_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- PLAYER SCENARIO HISTORY (Spaced Repetition)
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.player_scenarios (
  id uuid default gen_random_uuid() primary key,
  player_id uuid references public.players(id) on delete cascade,
  scenario_id uuid references public.scenarios(id),
  encountered_at timestamptz default now(),
  choice_index integer,
  was_optimal boolean,
  ease_factor decimal(4,2) default 2.5,
  interval_days integer default 1,
  next_review_at timestamptz default now() + interval '1 day',
  repetition_count integer default 0,
  unique(player_id, scenario_id)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- DECISION LOG
-- Full history for analytics and advisor context.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.decision_log (
  id uuid default gen_random_uuid() primary key,
  player_id uuid references public.players(id) on delete cascade,
  scenario_id uuid references public.scenarios(id),
  choice_index integer,
  was_optimal boolean,
  financial_impact jsonb,
  in_game_date date,
  created_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- KNOWLEDGE BASE (RAG)
-- Verified financial concepts. Embeddings for pgvector similarity search.
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.knowledge_entries (
  id uuid default gen_random_uuid() primary key,
  concept text not null,
  domain text not null,
  definition text not null,
  relevance_to_teen text not null,
  mechanics text not null,
  common_misconception text,
  consequence_of_ignorance text,
  source_citation text,
  embedding vector(1536),
  created_at timestamptz default now()
);

create index if not exists knowledge_entries_embedding_idx
  on public.knowledge_entries
  using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);

-- ─────────────────────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- Players can only read/write their own data.
-- ─────────────────────────────────────────────────────────────────────────────
alter table public.players enable row level security;
alter table public.knowledge_maps enable row level security;
alter table public.game_states enable row level security;
alter table public.player_scenarios enable row level security;
alter table public.decision_log enable row level security;
alter table public.scenarios enable row level security;
alter table public.knowledge_entries enable row level security;

-- Players table
create policy "Players: own row" on public.players
  for all using (auth.uid() = id);

-- Knowledge maps
create policy "Knowledge maps: own rows" on public.knowledge_maps
  for all using (auth.uid() = player_id);

-- Game states
create policy "Game states: own row" on public.game_states
  for all using (auth.uid() = player_id);

-- Player scenarios
create policy "Player scenarios: own rows" on public.player_scenarios
  for all using (auth.uid() = player_id);

-- Decision log
create policy "Decision log: own rows" on public.decision_log
  for all using (auth.uid() = player_id);

-- Scenarios: any authenticated user can read (they are shared content)
create policy "Scenarios: read by authenticated" on public.scenarios
  for select using (auth.role() = 'authenticated');

-- Knowledge entries: any authenticated user can read
create policy "Knowledge entries: read by authenticated" on public.knowledge_entries
  for select using (auth.role() = 'authenticated');

-- ─────────────────────────────────────────────────────────────────────────────
-- AUTO-UPDATE updated_at
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create or replace trigger players_updated_at
  before update on public.players
  for each row execute procedure public.handle_updated_at();

create or replace trigger game_states_updated_at
  before update on public.game_states
  for each row execute procedure public.handle_updated_at();
