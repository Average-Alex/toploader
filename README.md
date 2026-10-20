# Toploader

A trading card marketplace for friends: list cards for sale or trade with photos, browse and search everyone's listings, and snap a photo of a card to get an estimate of what it's worth.

Works for Pokémon, sports (baseball, basketball, football, hockey), Magic: The Gathering, Yu-Gi-Oh!, One Piece, and more.

## Features

- **Browse** listings shown as graded-card "slabs": name, set, number, condition or grade, photo, and price or trade.
- **Search** with suggestions as you type (card names, sets, versions, grades), plus filters for card type and sale/trade, and sorting by price.
- **List a card** with up to 4 photos (opens the phone camera), condition or grade, version/parallel, price or what you want in trade, and how to reach you.
- **My cards**: mark a card sold or delete it.
- **Price check**: take a photo, say which version it is (foil, parallel, numbered, variation, autograph), and get a low / typical / high value plus a link to eBay sold listings.

## How it runs

`index.html` is a single page with no build step. It's made to run as a [Claude](https://claude.ai) artifact, which supplies:

- a shared database for listings,
- photo storage,
- sign-in (who posted what),
- Claude for reading card photos and estimating prices.

Opened anywhere else (for example straight from GitHub Pages), the page loads and shows the design, but listings, photo uploads, and price check are switched off, since those services aren't there.

## How accurate are the prices?

In a test on 24 random cards with real market prices:

| | Pokémon (10) | Sports, Magic, Yu-Gi-Oh! (14) |
|---|---|---|
| Identified the card | 10/10 | 14/14 |
| Price within 2x of the real price | 6/10 | 4/14 |

Estimates were most often too low for older cards, rookies, and special versions (foils, parallels, numbered cards), so the app asks which version a card is and warns on those. Always check sold listings before buying or selling.
