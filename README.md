# Floating Thoughts

macOS aplikace pro rychlé zaznamenání myšlenek a snímků obrazovky do Firebase.

## Požadavky
- macOS 13+
- Swift 6 toolchain
- Xcode (pro `swift run` / Firebase SDK build)

## Rychlý start
```bash
swift build
open Dist/FloatingThoughts.app
```

## Struktura
- `Sources/` – zdrojáky AppKit/SwiftUI (plovoucí panel, view-modely, Firebase služby)
- `Tests/` – zatím základní unit testy
- `Dist/` – lokálně generovaný `.app` bundl (ignorován v gitu)
- `External/` – lokální clone Firebase SDK (také ignorováno)

## TODO
Viz [`TODO.md`](TODO.md).
