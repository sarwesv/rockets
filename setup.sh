#!/usr/bin/env bash
# Initializes the Flutter project for Rocket Tracker.
# Run once after cloning: ./setup.sh
set -e

echo "==> Creating Flutter project skeleton..."
flutter create . \
  --project-name rocket_tracker \
  --org com.rockettracker \
  --platforms ios,macos,windows,linux \
  --description "Track nearby rocket launches"

echo "==> Installing dependencies..."
flutter pub get

echo "==> Patching platform permissions..."
python3 - <<'PYEOF'
import plistlib, os, sys

def patch_plist(path, updates):
    if not os.path.exists(path):
        print(f"  skipped {path} (not found)")
        return
    with open(path, 'rb') as f:
        data = plistlib.load(f)
    data.update(updates)
    with open(path, 'wb') as f:
        plistlib.dump(data, f, fmt=plistlib.FMT_XML)
    print(f"  patched {path}")

location_desc = "Rocket Tracker uses your location to show nearby rocket launches."

# iOS location permission
patch_plist('ios/Runner/Info.plist', {
    'NSLocationWhenInUseUsageDescription': location_desc,
})

# macOS location permission
patch_plist('macos/Runner/Info.plist', {
    'NSLocationWhenInUseUsageDescription': location_desc,
})

# macOS entitlements: network + location access
entitlement_updates = {
    'com.apple.security.network.client': True,
    'com.apple.security.personal-information.location': True,
}
for ent_file in ['macos/Runner/DebugProfile.entitlements', 'macos/Runner/Release.entitlements']:
    patch_plist(ent_file, entitlement_updates)

PYEOF

echo ""
echo "==> Done! Next steps:"
echo "    flutter run -d macos     # run on macOS"
echo "    flutter run -d ios       # run on iOS simulator"
echo "    flutter run -d windows   # run on Windows"
echo "    flutter run -d linux     # run on Linux"
echo ""
echo "    Optional: sign up at https://ll.thespacedevs.com to get an API key"
echo "    for higher rate limits (300 req/hour vs 15 req/hour unauthenticated)."
