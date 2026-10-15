# Cup Notes

A cafe review wall. People enter their name, the cafe, three palate questions, their order, an SCA-style tasting (flavour families, acidity, sweetness, body, finish, mouthfeel) and a verdict. Everyone with the link sees every review live.

## Stack

- **Front end:** one static `index.html` (plain HTML, CSS and JavaScript, no build step), hosted on GitHub Pages.
- **Back end:** Supabase project `cup-notes` (Mumbai region, free plan)
  - `reviews` table: anyone can read, nobody can write directly
  - `post_review` function: the only way to add a review; the database checks every field
  - `delete_review` function: deletes a review only with the secret code saved in the poster's browser
  - `cafe-photos` storage bucket: public photos, 5 MB limit, JPG/PNG/WebP only
  - Realtime on `reviews`, so new posts appear without reloading

The key in `index.html` is Supabase's public anon key. It is meant to be in the page; the database rules above decide what it can do.

## Engagement features

- Returning visitors skip the name step (head start), and their palate answers are remembered.
- Typing a cafe shows what friends already said about it.
- A cup passport of 10 stamps that reward variety (cafes, flavours, photos, detailed reviews). No streaks or volume badges.
- "Helpful" and "Want to go" taps on reviews. **Needs `supabase/reactions.sql` run once in the Supabase SQL Editor**; until then the buttons stay hidden and everything else works.
- A celebration screen with new stamps and a "taste twin".

## Deploy on GitHub Pages

1. Create a new public repository on GitHub, for example `cup-notes`.
2. Upload `index.html` (and this README) to the main branch.
3. In the repository, open Settings → Pages, choose "Deploy from a branch", pick `main` and `/ (root)`, and save.
4. After a minute the site is live at `https://<your-username>.github.io/cup-notes/`.
5. Optional: to use your own subdomain (like `pujo.edumate.co.in`), add it under Settings → Pages → Custom domain and create a CNAME record pointing to `<your-username>.github.io` at your DNS provider.

## Moderating

Delete any review from the Supabase dashboard: Table Editor → `reviews` → select the row → Delete.
