Emulation Station configured for Windows 10
======

An auto-installer to set up Emulation Station correctly on Windows 10.

As Retropie's increase in popularity, the setup of Emulationstation on the Windows platform hasn't recieved much love. 
I spent several nights trying to figure out how to configure everything correctly for a Windows machine to finally get it just right. Given the pain I went through and how now several of my friends have requested the same setup I decided to throw together a quick little powershell script for others to use.


Automatic Steps
------
1. Ensure chocolatey is installed https://chocolatey.org/install
2. Run prepare.ps1 in an admin session of Powershell
3. Launch Emulation Station and Enjoy


Bonus Steps
------
1. Bonus Step. Download latest version of Emulation Station compiled for Windows 
https://github.com/jrassa/EmulationStation 
(thanks to Github for making this impossible to download)


Special Thanks
------
- jrassa for his up to date compiled version of Emulation Station - https://github.com/jrassa/EmulationStation
- Nesworld for their open-source NES roms - http://www.nesworld.com/
- Liberto for their retroarch version - https://www.libretro.com/
- dtgm for maintaining the Emulation Station chocolatey package https://chocolatey.org/packages/emulationstation
- Github for making it impossible to download public release binaries without ripping your eyes out.
- boluge for his minor change to the recalbox theme https://github.com/boluge