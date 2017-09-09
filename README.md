# Emulation Station configured for Windows 10
An up to date auto-installer to set up Emulation Station correctly.

STEPS:

1. choco install directx -y

2. choco install emulationstation.install -y

3. Run emulation station and kill the process

3. Download latest version of Retroarch
https://buildbot.libretro.com/stable/1.6.7/windows/x86_64/RetroArch.7z

4. Download collection of old cores
http://buildbot.libretro.com/stable/archive/stable/win-x86_64/Cores-v1.0.0.2-64-bit.zip

5. Download latest version of Emulation Station compiled for Windows (Credits to jrassa)
https://github.com/jrassa/EmulationStation/releases/download/continuous/EmulationStation-Win32.zip

6. Create empty roms folders

7. Acquire open-source homebrew roms collection

8. Configure emulationstation.cfg

9. Launch RetroArch and configure to fullscreen / configure in config

10. Enjoy an update to date EmulationStation on Windows


TO-DO:
- Automate Steps in Powershell
- Create DSC to validate installation is correct


