# 🌤️ Weather App — Provider & Clean Architecture

A rebuild of Task2 (Week 2's basic Weather App) using Provider for state management and a Clean Architecture structure, as part of a Flutter training program.

Consumes the free Open-Meteo API (no API key required).

## What Changed From Task2

|                     | Task2 (Week 2)                            | This Project (Week 3)                                    |
| ------------------- | ----------------------------------------- | -------------------------------------------------------- |
| State management    | `setState`                                | Provider (`ChangeNotifier`, `Consumer`, `MultiProvider`) |
| Structure           | Flat (`models/`, `services/`, `screens/`) | Layered (`core/`, `data/`, `presentation/`)              |
| Data fetching logic | Mixed inside screens                      | Isolated in a Repository layer                           |
| UI responsibility   | UI + API calls + error handling combined  | UI only — reads state from Providers                     |

The API layer, models, and business rules are unchanged from Task2. Only how state is managed and how the code is organized has changed — which is the point of this exercise.

## Features

* Splash Screen — simple branded intro screen
* City Search — search for any city with debounced input (~450ms) and geocoding via Open-Meteo
* Current Weather — temperature, condition, high/low, humidity, wind, pressure, and UV index
* Hourly Forecast — scrollable next-hours forecast strip
* 7-Day Forecast — full weekly outlook reusing the same API response (no extra calls)
* Pull to Refresh on the home screen
* Robust error handling — no internet, request timeout, server errors, and empty search results, each with a clear message and a retry action

## Tech Stack

* Flutter & Dart
* provider — state management (`ChangeNotifier`, `Consumer`, `MultiProvider`)
* dio — HTTP client with timeout & structured error handling
* Open-Meteo API — free weather & geocoding data

## Architecture

```text
lib/
├── core/
│   ├── network/            # Dio client setup + custom API exceptions
│   └── utils/              # AppColors, WeatherCodeMapper (weather code → text + icon)
├── data/
│   ├── models/             # CityModel, WeatherModel
│   ├── services/           # GeocodingApiService, WeatherApiService (talk to the API)
│   └── repositories/       # CityRepository, WeatherRepository (data access abstraction)
└── presentation/
    ├── providers/          # CityProvider, WeatherProvider (ChangeNotifier)
    └── screens/            # SplashScreen, CitySearchScreen, HomeScreen, WeeklyForecastScreen
```

## Layer Responsibilities

* **data/services** — knows how to talk to the API. Nothing else.
* **data/repositories** — decides where data comes from (API today, cache/DB possibly later). Screens and Providers never talk to services directly.
* **presentation/providers** — holds UI state (loading / success / error) and notifies listeners via `notifyListeners()`.
* **presentation/screens** — pure UI. Reads state from Providers via `Consumer/context.watch`, never calls the API directly.

## Getting Started

```bash
flutter pub get
flutter emulators --launch Pixel_7_Pro
flutter devices
flutter run
```

## Screens

| Splash          | City Search                           | Home                                                | Weekly Forecast                  |
| --------------- | ------------------------------------- | --------------------------------------------------- | -------------------------------- |
| Logo + app name | Search with debounce + retry on error | Current conditions + hourly strip + pull to refresh | 7-day outlook, no extra API call |

## Error Handling

Every screen that fetches data covers 4 states via an enum:

* Initial
* Loading
* Success
* Error

The following errors are handled:

* No internet connection
* Request timeout
* Server error (non-200 status code)
* Empty search results ("لا توجد نتائج")

Each error state includes a clear message and a retry action.

Built as part of a Flutter training program (Week 3 — Provider, MultiProvider & Clean Architecture).

A parallel version of this same project using Riverpod instead of Provider — with the identical `core/` and `data/` layers — is planned next, to compare the two state management approaches directly.
