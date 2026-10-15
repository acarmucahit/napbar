# NapBar

A tiny macOS menu bar app that puts your Mac to sleep after a chosen number of minutes.

- Presets: 5, 10, 15, 20, 30, 45 min, 1 h, 1 h 30 min, 2 h
- Custom duration in minutes
- Live countdown in the menu bar, "Add 15 min", cancel, "Sleep now"
- No Dock icon, no dependencies, single Swift file (~150 lines)

Sleep is triggered with `pmset sleepnow`, which needs no admin rights.
Universal binary (Apple Silicon + Intel).

## Install

Download `NapBar.app.zip` from the [latest release](https://github.com/acarmucahit/napbar/releases/latest),
unzip it and move `NapBar.app` to `/Applications`.

The app is ad-hoc signed (not notarized), so macOS blocks the first launch.
Either go to System Settings → Privacy & Security and click **Open Anyway**, or run:

```bash
xattr -dr com.apple.quarantine /Applications/NapBar.app
```

## Build from source

Requires the Xcode Command Line Tools (`xcode-select --install`), macOS 13+.

```bash
./build.sh
open NapBar.app
```

To start it at login, add it under System Settings → General → Login Items.

If the icon doesn't show up on a notched MacBook, the menu bar is full and the
icon is hidden behind the notch. NapBar starts near the right edge to avoid this;
you can ⌘-drag it anywhere.

## License

MIT
