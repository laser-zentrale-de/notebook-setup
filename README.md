# Notebook Setup

This repository contains the Laserzentrale notebook setup.

## Overview

For a high-available setup we use 2 notebooks for our lasershows.

| Name             | Function | IP-Address |
| ---------------- | -------- | ---------- |
| laserzentrale-01 | Active   | 10.0.0.1   |
| laserzentrale-02 | Backup   | 10.0.0.2   |

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

## Installation

1. Create Windows ISO with [Rufus](https://rufus.ie/en/). Disable annoying Windows stuff and create local user account **laserzentrale**.
1. Install Windows the normal way.
1. Install [AtlasOS](https://atlasos.net/) as described here: [https://docs.atlasos.net/getting-started/installation/](https://docs.atlasos.net/getting-started/installation/)
1. Run the [playbook](./playbook.ps1) powershell script.
1. tbd.
