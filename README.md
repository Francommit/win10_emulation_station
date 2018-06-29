Emulation Station configured for Windows 10
======

An auto-installer to set up Emulation Station correctly on a 64 bit version of Windows 10.

As Retropie's increase in popularity, the setup of Emulationstation on the Windows platform hasn't recieved much love. 
I spent several nights trying to figure out how to configure everything correctly for a Windows machine to finally get it just right. Given the pain I went through and how now several of my friends have requested the same setup I decided to throw together a quick little powershell script for others to use.

Features
------
- Uses an up to date version of Emulation Station from the Raspberry Pi branch
- Auto populates emulators with public domain roms
- Auto installs a popular theme with support for adding 'Favorites'
- Initial installer is less than 20KB in size, it's a script
- Adds in a quick game content scraper which lives in the rom folder (run %UserProfile%\.emulationstation\roms\scraper.exe)

Translations
------
[Portuguese](README.pt-br.md)

Steps
------
1. Ensure chocolatey is installed https://chocolatey.org/install
2. Ensure Powershell is set to "Set-executionpolicy Bypass"
3. Run prepare.ps1 in an admin session of Powershell
  (NOTE: Powershell might restart your computer as some libraries require a restart, if so, simply re-run after your PC restarts)
4. Launch Emulation Station and Enjoy
5. Access your ROMS here %UserProfile%\.emulationstation\roms

Installation GIF:
![alt text](https://github.com/Francommit/github_gif_dump/blob/master/installation-instructions.gif?raw=true)



Troubleshooting
------
- If the controller is not working in game, configure Input in Retroarch (%UserProfile%\.emulationstation\systems\retroarch\retroarch.exe)
- PSX and PS2 Homebrew Games won't load unless you acquire the bios's and add them to the bios folder (%UserProfile%\.emulationstation\systems\epsxe\bios and %UserProfile%\.emulationstation\systems\pcsx2\bios)
- PSX and PS2 also require manual configuration for controllers (%UserProfile%\.emulationstation\systems\epsxe\ePSXe.exe and %UserProfile%\.emulationstation\systems\pcsx2\pcsx2.exe)
- If the script fails for whatever reason delete the contents of %UserProfile%\.emulationstation and try again.
- Emulation Station may crash when you return to it from a external progam, ensure your graphics drivers are up to date.
- Launching a Retroarch rom may return you to ES, you're probably on a 32-bit verison of Windows and need to acquire seperate cores.
- Powershell commands may fail, ensure your Powershell session is in Admin mode.
- If Powershell complains about syntax you're probably somehow running a Powershell version lower than 5. Run 'choco install powershell -y' to update.

Special Thanks
------
- jrassa for his up to date compiled version of Emulation Station - https://github.com/jrassa/EmulationStation
- Nesworld for their open-source NES roms - http://www.nesworld.com/
- Libretro for their retroarch version - https://www.libretro.com/
- dtgm for maintaining the Emulation Station chocolatey package https://chocolatey.org/packages/emulationstation
- OpenEmu for their Open-Source rom collection work https://github.com/OpenEmu/OpenEmu-Update
- recalbox for their themes https://github.com/recalbox/recalbox-themes
- sselph for his awesome scraper https://github.com/sselph/scraper
