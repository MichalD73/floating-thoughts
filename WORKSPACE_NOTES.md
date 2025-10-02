# Floating Thoughts – Workspace workflow

## Jak otevřít VS Code okno
1. V "File → Open Workspace from File" vyber `~/Workspaces/macos-floating-notes.code-workspace`.
2. Každý projekt drž v samostatném `.code-workspace` – VS Code pak automaticky pojmenuje okno podle souboru.
3. Pokud se okna po pádu VS Code obnoví všechna najednou, tlačítkem `⌘` + `` ` `` (backtick) mezi nimi rychle přepínej.

## Fixní panely a záložky
- Panel "Chat" (dislkuze s Codexem) si připni přes pravé tlačítko → `Pin`. Zůstane tak vždy na levé straně.
- Ostatní soubory připínej (`⌘` + K, potom `Enter`), aby zůstaly v horní liště a bylo jasné, co ke kterému projektu patří.

## Přednastavené úkoly
- `⌘` + `Shift` + `B` spustí build (`swift: build`).
- `Terminal → Run Task…` nabízí i `swift: test` a `swift: run app`. Každý běží ve vyhrazeném panelu, který lze zavřít bez ovlivnění ostatních.

## Tipy při obnově po pádu
- Nejprve otevři jen `macos-floating-notes.code-workspace`, zkontroluj `git status` a poslední změny.
- Až potom spouštěj další workspace, ať je kontext jasný.
- Poznámky/rozdělanou práci zapisuj sem (nebo do `Projects-Overview.md`), abys po restartu viděl, kde pokračovat.

