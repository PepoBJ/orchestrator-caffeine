# Orchestrator Caffeine 🎼☕

A lightweight macOS menu bar app with an animated conductor that keeps your screen awake.

## Features

- 🎭 Animated desktop conductor
- 💤 Prevents display sleep while visible
- 📊 Track active time statistics
- 🖱️ Draggable anywhere on screen
- 🎯 Menu bar controls (Hide/Show/Stats/Quit)

## Installation

1. Download `OrchestratorCaffeine.zip` from [Releases](../../releases)
2. Unzip the file
3. Open Terminal and run:
   ```bash
   xattr -cr ~/Downloads/OrchestratorCaffeine.app && open ~/Downloads/OrchestratorCaffeine.app
   ```

Done!

## Usage

- Click menu bar icon for controls
- Drag the conductor anywhere
- Hide to allow screen sleep
- Show to prevent screen sleep

## Build from Source

```bash
git clone https://github.com/PepoBJ/orchestrator-caffeine.git
cd orchestrator-caffeine
./build.sh
./create_release.sh
```

## License

MIT License
