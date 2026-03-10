# Spider Solitaire

A faithful Spider Solitaire card game built with Flutter, targeting Android (Google Play Store) and Windows desktop.

## Features

- 1, 2, or 4 suit modes (Easy → Hard)
- Full undo history
- Hint system
- Win detection with confetti celebration
- Persistent settings (dark mode, sound, suit count)
- Responsive layout for phone, tablet, and desktop

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.27+
- Android Studio (for Android builds)
- Visual Studio 2022 with Desktop workload (for Windows builds)

### Run in development
```bash
flutter pub get
flutter run
```

### Build for Android (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build for Windows
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/spider_solitaire.exe
```

### Windows Shortcut
After building, double-click `launch_windows.bat` or create a shortcut to:
`build\windows\x64\runner\Release\spider_solitaire.exe`

## Android Signing Setup

1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload -storepass YOUR_PASSWORD -keypass YOUR_PASSWORD
   ```
2. Create `android/key.properties`:
   ```
   storePassword=YOUR_PASSWORD
   keyPassword=YOUR_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
3. Build: `flutter build appbundle --release`

## Project Structure

```
lib/
├── main.dart           # Entry point
├── app.dart            # MaterialApp + theme
├── models/             # CardModel, GameState, SettingsModel
├── logic/              # Game rules, deal, hints
├── providers/          # Riverpod state management
├── ui/                 # Widgets (board, cards, dialogs)
└── utils/              # Responsive sizing, sound manager
```

## License

MIT
