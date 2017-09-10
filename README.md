Emulation Station configured for Windows 10
======

An auto-installer to set up Emulation Station correctly on a 64 bit version of Windows 10.

As Retropie's increase in popularity, the setup of Emulationstation on the Windows platform hasn't recieved much love. 
I spent several nights trying to figure out how to configure everything correctly for a Windows machine to finally get it just right. Given the pain I went through and how now several of my friends have requested the same setup I decided to throw together a quick little powershell script for others to use.


Automatic Steps
------
1. Ensure chocolatey is installed https://chocolatey.org/install
2. Ensure Powershell is set to "Set-executionpolicy Bypass" 
3. Run prepare.ps1 in an admin session of Powershell
4. Launch Emulation Station and Enjoy


Bonus Steps
------
1. Bonus Step. Download latest version of Emulation Station compiled for Windows 
https://github.com/jrassa/EmulationStation/releases/download/continuous/EmulationStation-Win32.zip
(thanks to Github for making this impossible to download via Powershell)


Troubleshooting
------
- Emulation Station may crash when you return to it from a external progam, ensure your graphics drivers are up to date.
- Launching a Retroarch rom may return you to ES, you're probably on a 32-bit verison of Windows and need to acquire seperate cores.
- Powershell commands may fail, ensure your Powershell session is in Admin mode.
- If the script fails for whatever reason delete the contents of C:\Users\\{user}\\.emulationstation and try again

Special Thanks
------
- jrassa for his up to date compiled version of Emulation Station - https://github.com/jrassa/EmulationStation
- Nesworld for their open-source NES roms - http://www.nesworld.com/
- Liberto for their retroarch version - https://www.libretro.com/
- dtgm for maintaining the Emulation Station chocolatey package https://chocolatey.org/packages/emulationstation
- Github for making it impossible to download public release binaries without ripping your eyes out.
- boluge for his minor change to the recalbox theme https://github.com/boluge
- OpenEmu for their Open-Source rom collection work https://github.com/OpenEmu/OpenEmu-Update
