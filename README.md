# Toploader

A trading card marketplace for friends: list cards for sale or trade with photos, browse and search everyone's listings, and look up what a card really sells for.

Works for Pokémon, sports (baseball, basketball, football, hockey), Magic: The Gathering, Yu-Gi-Oh!, One Piece, and more.

**Live site:** https://average-alex.github.io/toploader/

## Features

- **Accounts:** sign up with an email and password; your display name shows on your listings.
- **Browse** listings shown as graded-card "slabs": name, set, number, version, condition or grade, photo, and price or trade.
- **Search** with suggestions as you type (card names, sets, versions, grades), filters for card type and sale/trade, and sorting by price.
- **List a card** with up to 4 photos (opens the phone camera), condition or grade, version, price or what you want in trade, and how to reach you.
- **My cards:** mark a card sold or delete it.
- **Messages:** private chats, like Facebook Messenger. Press **Message** on any listing to ask the seller about it, or start a **New message** with anyone by their display name. New messages show up live, with an unread count on the tab.
- **Value lookup:** type a card and jump straight to its sold prices on eBay, PriceCharting, and TCGplayer.

## Files

| File | What it is |
|---|---|
| `index.html` | The website |
| `config.js` | Your Supabase project's URL and public key |
| `setup.sql` | Creates the database tables (listings, profiles, messages), photo storage, and security rules |
| `claude-version.html` | The original version that runs inside Claude, with AI price check |

## Setting it up

The site runs on GitHub Pages (free) and stores listings, photos, and accounts in [Supabase](https://supabase.com) (free plan).

1. Make a free Supabase account and a new project.
2. In the project, open **SQL Editor**, paste in all of `setup.sql`, and press **Run**.
3. Open **Authentication > Sign In / Providers > Email** and turn off **Confirm email**, so people can post right after signing up. (The free plan only sends a few emails an hour.)
4. Open **Authentication > URL Configuration** and set **Site URL** to the live site's address.
5. Open **Project Settings > API**, copy the **Project URL** and the **anon public** key into `config.js`, and push.

**Already set up before Messages was added?** Run all of `setup.sql` again in the SQL Editor. It's safe to re-run: it only adds what's missing.

The anon key is meant to be public. The security rules in `setup.sql` let anyone read listings, but only signed-in people can post, and only the person who posted a listing can change or delete it. Messages can only be read by the two people in the conversation.

## Removing a listing

To take down someone else's listing, open the Supabase project, go to **Table Editor > listings**, and delete the row.

## About prices

A test of AI price estimates on 24 random cards found they identified every card but were often too low for older cards, rookies, and special versions (foils, parallels, numbered cards). That's why this version links to real sold prices instead of guessing.
