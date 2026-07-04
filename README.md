# Rocket Tracker

A cross-platform Flutter app for tracking nearby rocket launches.

## Features

- **Map view** — launch sites plotted on an interactive map (OpenStreetMap)
- **Launch list** — browse upcoming launches, filter by distance radius, sort by date or distance
- **Detail view** — rocket name, mission, status, countdown timer, pad location
- **Directions** — one tap opens Google Maps with driving directions to the launch site
- **Live data** — powered by [Launch Library 2 API](https://ll.thespacedevs.com)

## Platforms

macOS · iOS · Windows · Linux

## Getting Started

```bash
flutter pub get
flutter run -d macos     # or: ios, windows, linux
```

> **Note:** Location permission is requested at runtime to show your distance to each launch site and center the map on your position.
