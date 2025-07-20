# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Windows 10/11 EmulationStation auto-installer that sets up a complete retro gaming environment. The main script (`prepare.ps1`) automates the download and configuration of EmulationStation Desktop Edition (ES-DE), RetroArch cores, multiple emulators, and public domain ROMs.

**Recent Updates (2025):**
- Updated to ES-DE 3.3.0 (modern EmulationStation)
- Replaced Yuzu with Suyu (Nintendo shut down Yuzu in 2024)
- Added DuckStation for superior PlayStation 1 emulation
- Updated RetroArch to 1.21.0 and PCSX2 to 2.5.68
- Improved error handling and download validation
- Added progress indicators and better logging

## Core Commands

### Main Installation
- `.\prepare.ps1` - Main installation script (requires PowerShell admin session)
- `Set-ExecutionPolicy Bypass -Scope Process -Force; .\prepare.ps1` - Run with execution policy bypass

### Development/Testing Commands
- No specific build or test commands - this is a PowerShell deployment script
- Script can be re-run safely to recover from interrupted installations
- Use `Get-ExecutionPolicy` to check current PowerShell execution policy

### Utility Scripts
- `.\misc\scripts\scraper.ps1` - ROM metadata scraping tool (requires ScreenScraper account)
- `.\misc\scripts\onedrive.ps1` - Configure OneDrive storage for ROMs and saves

## Architecture

### Core Components
1. **prepare.ps1** - Main orchestration script that:
   - Installs Chocolatey and Scoop package managers
   - Downloads and configures EmulationStation
   - Sets up RetroArch with multiple libretro cores
   - Installs standalone emulators (Citra, PPSSPP, Yuzu, RPCS3, Dolphin, Cemu, Vita3K)
   - Configures ROM directories and downloads public domain games
   - Generates EmulationStation system configuration

2. **download_list.json** - Centralized configuration for all downloads:
   - `downloads`: Direct URL downloads (emulators, cores, ROMs)
   - `releases`: GitHub release downloads (scrapers, themes)
   - `other_downloads`: Additional homebrew content
   - `extra_nes_games`: Extended NES homebrew collection

### Installation Structure
- Main installation: `%UserProfile%\.emulationstation\`
- ROMs: `%UserProfile%\.emulationstation\roms\`
- RetroArch: `%UserProfile%\.emulationstation\systems\retroarch\`
- Emulators: Various paths (`%UserProfile%\scoop\apps\`, `C:\Program Files\`, etc.)

### Emulator Configuration
The script configures 20+ gaming systems including:
- Retro consoles (NES, SNES, Genesis, N64, etc.) via RetroArch cores
- Modern systems (3DS via Citra, Switch via Suyu, PS3 via RPCS3)
- PlayStation systems (PS1 via DuckStation, PS2 via PCSX2 2.5.68)
- Handheld systems (PSP via PPSSPP, Vita via Vita3K, Game Boy family)
- Nintendo consoles (GameCube/Wii via Dolphin, Wii U via Cemu)
- Computer platforms (Amiga, C64, MSX)

### Key Functions in prepare.ps1
- `DownloadFiles()` - Downloads from JSON configuration with progress tracking
- `GithubReleaseFiles()` - Fetches latest GitHub releases
- `Test-DownloadedFiles()` - Validates successful downloads
- `Expand-Archive()` - Custom 7-Zip extraction wrapper
- System setup blocks for each emulator/console
- Improved error handling and TLS 1.2 support

## File Locations
- Installation script: `prepare.ps1`
- Download configuration: `download_list.json`
- Registry tweaks: `misc/registry_tweaks/`
- Utility scripts: `misc/scripts/`
- Documentation: `README.md`, `misc/translations/`

## Development Notes
- Script requires Windows PowerShell 5+ and admin privileges
- Downloads are cached in `requirements/` folder to enable resumable installs
- All configurations use absolute paths with PowerShell variable expansion
- ES-DE config is generated dynamically with proper paths
- Enhanced error handling, download validation, and progress tracking
- TLS 1.2 support for secure downloads
- Fallback emulators provided where modern alternatives exist

## Important Changes from Original
- **Yuzu Replacement**: Nintendo shut down Yuzu in March 2024. Script now uses Suyu as Switch emulator
- **Modern EmulationStation**: Updated to ES-DE 3.3.0 for better compatibility and features
- **Better PS1 Emulation**: DuckStation provides superior accuracy compared to ePSXe
- **Latest Versions**: All emulators and cores updated to current stable releases
- **Improved Reliability**: Better error handling and download validation