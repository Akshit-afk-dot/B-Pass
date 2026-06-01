# ✈️ B-Pass — Flight Price Comparison App

A Flutter-based mobile app that lets you compare flight ticket prices across multiple Indian travel booking platforms in one place. Enter your route, dates, and passenger count — B-Pass opens each selected website with your search pre-filled and scrapes prices in the background, showing you the cheapest fares side by side.

---

## What It Does

Finding the cheapest flight in India means checking Cleartrip, EaseMyTrip, Ixigo, MakeMyTrip, Yatra, Goibibo, Paytm, and more — one by one. B-Pass automates that.

- Enter origin, destination, travel date, and passenger count
- Select which booking sites to compare
- Hit **Submit** — the app opens each site in a WebView tab with your search pre-filled
- A background scraper extracts fares and stores them in Firestore
- The **Cheapest Prices** section ranks all results so you can book on the cheapest platform instantly

---

## Features

- **One-way & round-trip** support
- **Multi-passenger** — adults, children, and infants
- **7 booking platforms** — Cleartrip, EaseMyTrip, Ixigo, AdaniOne, Yatra, Goibibo, Paytm
- **Parallel web scraping** — all selected sites scraped concurrently for speed
- **Firestore caching** — prices cached with timestamps; stale data flagged automatically
- **Smart refresh** — re-scrapes only if route/passengers/sites changed, otherwise pulls from cache
- **Airport search** — full searchable dropdown from a bundled airports database (IATA codes)
- **Light & dark mode** support

---

## Tech Stack

| Layer | Tech |
|---|---|
| Framework | Flutter (Dart) |
| WebView | `flutter_inappwebview`, `webview_flutter` |
| Backend / Storage | Firebase Firestore |
| Scraping | `ScrapeManager` — custom parallel JS-injection scraper |
| URL launching | `url_launcher` |
| Date formatting | `intl` |

---

## Supported Booking Sites

| Site | Domain |
|---|---|
| Cleartrip | cleartrip.com |
| EaseMyTrip | easemytrip.com |
| Ixigo | ixigo.com |
| AdaniOne | adanione.com |
| Yatra | yatra.com |
| Goibibo | goibibo.com |
| Paytm Travel | paytm.com |

---

## How It Works

1. **Search** — User fills in origin, destination, date, passengers, and selects websites
2. **WebView tabs** — App builds site-specific search URLs and opens each in a hidden WebView
3. **Scraping** — `ScrapeManager` injects JavaScript into each WebView to extract price elements using CSS selectors and polling heuristics
4. **Storage** — Scraped prices are saved to Firestore under a route key (`ORIGIN-DEST-DATE`)
5. **Display** — Prices are fetched from Firestore, filtered to selected sites, and ranked cheapest-first

---

## Project Structure

```
B-Pass/
└── main.dart              # Full app — home screen, search form, scrape triggers, price display
    ├── site_config.dart   # Per-site CSS selectors and JS extraction config
    ├── scrape_manager.dart # Parallel scraping engine with caching
    ├── scraper_webview.dart# Hidden WebView used for scraping
    ├── firestore_service.dart # Firestore read/write helpers
    ├── flight_offer.dart  # Data model for a flight offer
    └── offers_screen.dart # Offers tab UI
assets/
    ├── airports.json      # IATA airport database
    └── logos/             # Booking site logos (cleartrip, ixigo, etc.)
```

---

## Getting Started

### Prerequisites

- Flutter SDK (3.x+)
- A Firebase project with Firestore enabled
- Android/iOS device or emulator

### Setup

```bash
git clone https://github.com/Akshit-afk-dot/B-Pass.git
cd B-Pass
flutter pub get
```

Add your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) from your Firebase project to the appropriate platform folder.

```bash
flutter run
```

---

## Roadmap

- [ ] Price history graphs per route
- [ ] Flight alerts — notify when price drops below a threshold
- [ ] MakeMyTrip support
- [ ] APK release / Play Store listing
- [ ] Round-trip price comparison (currently one-way only in the price summary)

---

