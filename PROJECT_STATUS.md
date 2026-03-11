# Spider Solitaire — Project Status for AI Agent Handoff

## Purpose
This file gives a new AI agent session full context to continue development. Read this first before any other file.

---

## Project Identity
- **App name**: Spider Solitaire
- **App ID**: `com.squirly_games.spider_solitaire`
- **Framework**: Flutter 3.27.4 (Dart, single codebase → Android + Windows)
- **GitHub**: https://github.com/david-william-johns/spider-solitaire
- **Source root**: `D:\ClaudeCode_Projects\spider-solitaire\`
- **Version**: 1.0.0+1

---

## Current State: COMPLETE ✅

All planned work is done. Both build targets are working and all assets are in place.

| Item | Status | Location |
|---|---|---|
| Dart source code | ✅ Complete, 0 analyzer issues | `lib/` |
| Custom app icon | ✅ Green felt + spade design | `assets/icon.png` (1024×1024) |
| Sound effects (WAV) | ✅ 4 real WAV files | `assets/sounds/*.wav` |
| Android AAB | ✅ Signed, Play Store ready | `build/app/outputs/bundle/release/app-release.aab` (19.7MB) |
| Windows exe | ✅ Built and runnable | `build/windows/x64/runner/Release/spider_solitaire.exe` |
| Desktop shortcut | ✅ On user's Desktop | `C:\Users\david\OneDrive\Desktop\Spider Solitaire.lnk` |
| Android licenses | ✅ All accepted | via sdkmanager |
| GitHub | ✅ 7 commits on master | https://github.com/david-william-johns/spider-solitaire |

---

## Build Environment

| Tool | Path / Version |
|---|---|
| Flutter SDK | `D:\flutter\` (v3.27.4 stable) |
| Android SDK | `D:\Android\sdk\` |
| Java JDK | `C:\Program Files\Java\jdk-17\` |
| VS Build Tools 2022 | `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\` |
| MSVC | `VC\Tools\MSVC\14.44.35207` |
| Keystore | `android/app/upload-keystore.jks` (storePass=squirly123, alias=upload) |
| key.properties | `android/key.properties` (gitignored — do NOT commit) |

### Build Commands
```bash
export PATH="/d/flutter/bin:$PATH"
export ANDROID_HOME="/d/Android/sdk"
cd /d/ClaudeCode_Projects/spider-solitaire

flutter build appbundle --release   # → AAB for Play Store
flutter build windows --release     # → Windows exe
flutter analyze                     # → should show 0 issues
```

---

## Architecture

```
lib/
├── main.dart                   # Entry point: landscape lock, immersive mode, ProviderScope
├── app.dart                    # MaterialApp, theme (dark #1A1A2E bg), routing
├── models/
│   ├── card_model.dart         # Suit enum, Rank enum, CardModel (suit/rank/isFaceUp/isHighlighted)
│   ├── game_state.dart         # GameState (10 columns, stock, 8 foundations, moves, score, history)
│   └── settings_model.dart     # SuitCount enum (one/two/four), SettingsModel with JSON serialization
├── logic/
│   ├── deal_manager.dart       # buildDeck() — 104 cards per suit mode; dealInitial() — cols 0-3=6 cards, 4-9=5 cards
│   ├── game_logic.dart         # isValidSequence(), canMoveTo(), executeMove(), dealFromStock(), undo(), _checkCompletedSequences()
│   └── hint_engine.dart        # Priority: K→A completion > empty column > any valid move
├── providers/
│   ├── game_provider.dart      # GameNotifier (StateNotifier) — newGame(), move(), dealFromStock(), undo(), showHint(), clearHint()
│   └── settings_provider.dart  # Loads/saves via shared_preferences, key: "settings_v1"
├── ui/
│   ├── card_widget.dart        # CustomPainter: white face (gold border=hint), red back crosshatch, EmptySlotWidget
│   ├── column_widget.dart      # DragTarget<CardMoveData> + Draggable; 18% overlap face-down, 28% face-up
│   ├── foundation_widget.dart  # 8 foundation slots showing completion count
│   ├── game_board.dart         # LayoutBuilder: header (moves/score) + 10 columns + right stock panel + toolbar
│   ├── stock_widget.dart       # Stock pile, tap to deal
│   ├── toolbar_widget.dart     # Dark bar (#1A1A2E): settings, grid_view, play_circle, lightbulb, undo
│   ├── settings_dialog.dart    # Suit selector (1|2|4), dark mode, winnable deals, sound switches
│   └── win_dialog.dart         # Confetti AnimationController + CustomPainter rectangles, score, New Game
└── utils/
    ├── responsive.dart         # Card sizing from screen width
    └── sound_manager.dart      # AudioPlayer via audioplayers; plays deal.wav, move.wav, sequence_complete.wav, win.wav
```

---

## Game Rules Implemented

- **Deck**: 1-suit=104 spades, 2-suit=52 spades+52 hearts, 4-suit=full 2 decks (104 cards)
- **Initial deal**: Columns 0–3 get 6 cards, columns 4–9 get 5 cards = 54 dealt; remaining 50 → 5 stock groups of 10
- **Face-up**: only bottom card of each column starts face-up
- **Move validation**: target top must be rank+1; sequence drag requires same-suit descending (4-suit), same-color (2-suit), any descending (1-suit)
- **Stock deal**: tap stock → 1 card to each of 10 columns; not allowed if any column empty; 5 deals max
- **Complete sequence**: K→A same suit → auto-removed to foundation, card below flipped, score +100
- **Win**: all 8 foundations filled (104 cards total)
- **Undo**: full GameStateSnapshot stored before every move/deal

---

## Key Files Reference

| File | Purpose |
|---|---|
| `pubspec.yaml` | Dependencies: flutter_riverpod ^2.5.1, shared_preferences ^2.3.2, audioplayers ^6.1.0, flutter_launcher_icons ^0.14.3 (dev) |
| `android/app/build.gradle` | minSdk=21, targetSdk=34, release signing via key.properties |
| `android/app/src/main/AndroidManifest.xml` | label="Spider Solitaire", no extra permissions |
| `assets/icon.png` | 1024×1024 RGBA PNG — generated by `tools/generate_icon.py` |
| `assets/sounds/deal.wav` | 500→250 Hz descending sweep (15,920 bytes) |
| `assets/sounds/move.wav` | 900 Hz tick + 450 Hz soft tone (5,336 bytes) |
| `assets/sounds/sequence_complete.wav` | 4-note ascending chime C5-E5-G5-C6 (77,660 bytes) |
| `assets/sounds/win.wav` | Arpeggio + held chord (119,996 bytes) |
| `tools/generate_icon.py` | Regenerates `assets/icon.png` from scratch (stdlib only) |
| `tools/generate_sounds.py` | Regenerates all 4 WAV files from scratch (stdlib only) |
| `launch_windows.bat` | Launches exe with `start ""` (no terminal window) |
| `.gitignore` | Excludes `android/key.properties`, `*.jks`, `build/`, `.dart_tool/` |

---

## Git History

```
1834424  tools: add VS C++ workload install scripts
00fc04e  Add custom icon and real sound effects
9843b3e  windows: add post-restart setup script for C++ workload + Windows build
e581bd7  android: add pubspec.lock and update signing config
517eace  platform: add Android + Windows Flutter boilerplate, fix analyzer warnings
9b50fae  models: add CardModel, GameState, SettingsModel, game logic, providers, UI widgets, sound manager
8bff684  init: Flutter project structure with pubspec and launch script
```

---

## Known Limitations / Potential Next Features

1. **No animation on card moves** — cards teleport; smooth slide/flip animations would improve feel
2. **No game statistics persistence** — settings_model has a stub for win stats but nothing is tracked yet
3. **No "winnable deals only" filter** — the setting toggle exists in UI but the logic is not implemented
4. **Stock widget visual** — shows a simple stack; could show remaining deal count (0–5)
5. **No new game confirmation dialog** — pressing new game starts immediately without confirming
6. **Windows icon** — the exe uses Flutter's default blue diamond icon; a custom .ico has not been set
7. **Play Store submission** — AAB is built and signed but not yet uploaded; needs Play Console account, store listing, screenshots, and feature graphic
8. **No dark mode theming on cards** — dark mode toggle exists in settings but card colors don't respond to it
9. **Sound on Windows** — audioplayers WAV playback on Windows desktop may need testing
10. **No tablet/landscape optimisation** — layout works but could use more space on large screens

---

## Session History Summary

- **Sessions 1–2**: Designed architecture from scratch (Mobilityware app as reference), wrote all Dart source files, set up Flutter project, configured Android signing, built first AAB
- **Session 3**: Fixed all analyzer warnings, generated custom icon (green felt + spade via `generate_icon.py`), generated real WAV sounds (`generate_sounds.py`), updated sound_manager to use .wav, applied launcher icons to Android, rebuilt AAB, pushed to GitHub
- **Session 4**: Installed VS C++ workload (user installed manually via VS Installer GUI after silent installs were blocked by `PendingFileRenameOperations` requiring admin elevation), accepted Android licenses, rebuilt AAB (19.7MB), built Windows exe, created desktop shortcut, final commit pushed
