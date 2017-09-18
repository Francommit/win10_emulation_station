Emulation Station configured for Windows 10
======

An auto-installer to set up Emulation Station correctly on a 64 bit version of Windows 10.

As Retropie's increase in popularity, the setup of Emulationstation on the Windows platform hasn't recieved much love. 
I spent several nights trying to figure out how to configure everything correctly for a Windows machine to finally get it just right. Given the pain I went through and how now several of my friends have requested the same setup I decided to throw together a quick little powershell script for others to use.

Features
------
- Uses an up to date version of Emulation Station from the Raspberry Pi branch
- Auto populates emulators with public domain roms
- Auto installs a popular theme with support for 'Favorites'
- Initial installer is less than 20KB in size, it's a script
- Adds in a quick game content scraper which lives in the rom folder (run C:\Users\name\.emulationstation\roms\scraper.exe)

Steps
------
1. Ensure chocolatey is installed https://chocolatey.org/install
2. Ensure Powershell is set to "Set-executionpolicy Bypass"
3. Run prepare.ps1 in an admin session of Powershell
4. Launch Emulation Station and Enjoy


TO-DO
------
1. Add string wildcard matching to github release files
2. Add some pretty pictures to this page


Troubleshooting
------
- PSX Homebrew Games won't load unless you acquire the bios's and add them to the bios folder.
- If the script fails for whatever reason delete the contents of C:\Users\\{user}\\.emulationstation and try again.
- Emulation Station may crash when you return to it from a external progam, ensure your graphics drivers are up to date.
- Launching a Retroarch rom may return you to ES, you're probably on a 32-bit verison of Windows and need to acquire seperate cores.
- Powershell commands may fail, ensure your Powershell session is in Admin mode.
- If Powershell complains about syntax you're probably somehow running a Powershell version lower than 5. Run 'choco install powershell -y' to update.

Special Thanks
------
- jrassa for his up to date compiled version of Emulation Station - https://github.com/jrassa/EmulationStation
- Nesworld for their open-source NES roms - http://www.nesworld.com/
- Liberto for their retroarch version - https://www.libretro.com/
- dtgm for maintaining the Emulation Station chocolatey package https://chocolatey.org/packages/emulationstation
- OpenEmu for their Open-Source rom collection work https://github.com/OpenEmu/OpenEmu-Update
- recalbox for their themes https://github.com/recalbox/recalbox-themes
- sselph for his awesome scraper https://github.com/sselph/scraper
