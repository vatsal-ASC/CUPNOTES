-- Cup Notes: "Helpful" and "Want to go" taps on reviews.
-- Run once in Supabase: Dashboard → cup-notes project → SQL Editor → New query → paste → Run.
-- The app shows the tap buttons automatically once this has run.

alter table public.reviews
  add column if not exists helpful_count integer not null default 0,
  add column if not exists want_count integer not null default 0;

create table if not exists public.review_reactions (
  review_id uuid not null references public.reviews(id) on delete cascade,
  voter uuid not null,
  kind text not null check (kind in ('helpful','want')),
  created_at timestamptz not null default now(),
  primary key (review_id, voter, kind)
);
alter table public.review_reactions enable row level security;
revoke all on public.review_reactions from anon, authenticated;

create or replace function public.toggle_reaction(review uuid, voter uuid, kind text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare existed boolean; h integer; w integer;
begin
  if kind not in ('helpful','want') then raise exception 'bad kind' using errcode = '22023'; end if;
  delete from public.review_reactions rr
   where rr.review_id = review and rr.voter = toggle_reaction.voter and rr.kind = toggle_reaction.kind;
  get diagnostics h = row_count;
  existed := h > 0;
  if not existed then
    insert into public.review_reactions(review_id, voter, kind) values (review, toggle_reaction.voter, toggle_reaction.kind);
  end if;
  update public.reviews rv set
    helpful_count = (select count(*) from public.review_reactions x where x.review_id = review and x.kind = 'helpful'),
    want_count    = (select count(*) from public.review_reactions x where x.review_id = review and x.kind = 'want')
  where rv.id = review
  returning rv.helpful_count, rv.want_count into h, w;
  return jsonb_build_object('helpful', h, 'want', w, 'on', not existed);
end $$;
revoke execute on function public.toggle_reaction(uuid, uuid, text) from public;
grant execute on function public.toggle_reaction(uuid, uuid, text) to anon, authenticated;
