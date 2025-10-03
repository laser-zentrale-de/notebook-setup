# Notebook Setup

This repository contains the Laserzentrale notebook setup.

## Overview

For a high-available setup we use 2 notebooks for our lasershows.

| Name            | Function | IP-Address |
| --------------- | -------- | ---------- |
| laserzentrale-1 | Active   | 10.0.0.1   |
| laserzentrale-2 | Backup   | 10.0.0.2   |

## Tools

- LGRemote
- LGPreview
- LGServer
- LGTimecode
- LGControl
- LGStatus
- LPVCreator
- LPVPlayer
- Reaper
- Brave Browser
- Tascam UH7000 Mixer Panel
- Neovim
- Git
- RustDesk
- LoopMidi

## Installation

1. Create Windows ISO with [Rufus](https://rufus.ie/en/). Disable annoying Windows stuff and create local user account **laserzentrale**.
1. Install Windows the normal way.
1. Install [AtlasOS](https://atlasos.net/) as described here: [https://docs.atlasos.net/getting-started/installation/](https://docs.atlasos.net/getting-started/installation/)
1. Download the source code zip file and extract it.
1. Run the [playbook.cmd](./playbook.cmd) script as an administrator.
1. Follow the [manual-doings](./manual-doings.md).

## Credits

- Thanks to [yahikii](https://github.com/yahikii) for the background wallpaper.
