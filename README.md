# Christmas dinner sign-up

A single static page (GitHub Pages) backed by one Supabase table. Guests add, edit and
remove dishes without accounts, across five courses: Starters, Snacks, Sides for the main,
Desserts, Other.

## Setup
1. In Supabase, open the SQL editor and run `supabase/schema.sql`.
2. Copy the project URL and anon (public) key from Project Settings → API into `config.js`.
3. GitHub → Settings → Pages → Deploy from a branch → pick this branch, folder `/ (root)`.

Note: with no accounts, anyone who has the link can edit or remove any dish.
