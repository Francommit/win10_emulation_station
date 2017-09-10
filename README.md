Emulation Station configured for Windows 10
======

An auto-installer to set up Emulation Station correctly on Windows 10.

As Retropie's increase in popularity, the setup of Emulationstation on the Windows platform hasn't recieved much love. 
I spent several nights trying to figure out how to configure everything correctly for a Windows machine to finally get it just right. Given the pain I went through and how now several of my friends have requested the same setup I decided to throw together a quick little powershell script for others to use.


Automatic Steps
------
1. Ensure chocolatey is installed https://chocolatey.org/install
2. Run prepare.ps1 in an admin session of Powershell
3. Enjoy

4. Bonus Step. Download latest version of Emulation Station compiled for Windows (thanks to Github for making this impossible to download)
	https://github.com/jrassa/EmulationStation 

Manual Steps
------
1. choco install directx -y
2. choco install emulationstation.install -y
3. Run emulation station and kill the process
3. Download latest version of Retroarch
4. Download collection of old cores
5. Download latest version of Emulation Station compiled for Windows (Credits to jrassa)
6. Create empty roms folders
7. Acquire open-source homebrew roms collection
8. Configure emulationstation.cfg
9. Launch RetroArch and configure to fullscreen / configure in config
10. Enjoy an update to date EmulationStation on Windows


Special Thanks
------
- jrassa for his up to date compiled version of Emulation Station - https://github.com/jrassa/EmulationStation
- Nesworld for their open-source NES roms - http://www.nesworld.com/
- Liberto for their retroarch version - https://www.libretro.com/
- dtgm for maintaining the Emulation Station chocolatey package https://chocolatey.org/packages/emulationstation
- Github for making it impossible to download public release binaries without ripping your eyes out.
- boluge for his minor change to the recalbox theme https://github.com/boluge