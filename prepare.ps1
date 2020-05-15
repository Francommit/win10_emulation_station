# Configuring
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

Import-Module BitsTransfer
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" #Convince Powershell to talk to sites with different versions of TLS
[System.net.ServicePointManager]::SecurityProtocol = 3072 -bor 768 -bor 192 -bor 48

# Installing Chocolatey 
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# Reloading PATH variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

# Get script path
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath
Write-Host $scriptDir

# 
# 1. Chocolatey installs 
# 
choco install directx -y
choco install 7zip -y
choco install emulationstation.install -y --force
choco install vcredist2008 -y
choco install vcredist2010 -y
choco install vcredist2013 -y
choco install vcredist2015 -y

# 
# 2. Acquire files 
# 
$requirementsFolder = "$PSScriptRoot\requirements\"
New-Item -ItemType Directory -Force -Path $requirementsFolder

Get-Content "$scriptDir\download_list.json" | ConvertFrom-Json | Select-Object -expand downloads | ForEach-Object {

    $url = $_.url
    $file = $_.file
    $output = $requirementsFolder + $file

    if(![System.IO.File]::Exists($output)){

        Write-Host $file "does not exist...Downloading."
        Start-BitsTransfer -Source $url -Destination $output

    } else {

        Write-Host $file "Already exists...Skipping download."

    }

}


Get-Content "$scriptDir\download_list.json" | ConvertFrom-Json | Select-Object -expand releases | ForEach-Object {

    $repo = $_.repo
    $file = $_.file

    $releases = "https://api.github.com/repos/$repo/releases"
    $tag = (Invoke-WebRequest $releases -usebasicparsing| ConvertFrom-Json)[0].tag_name

    $url = "https://github.com/$repo/releases/download/$tag/$file"
    $name = $file.Split(".")[0]

    $zip = "$name-$tag.zip"
    $output = $requirementsFolder + $zip

    if(![System.IO.File]::Exists($output)) {

        Invoke-WebRequest $url -Out $output
        Write-Host $file "does not exist...Downloading."

    } else {

        Write-Host $file "Already exists...Skipping download."
    }

}


# 
# 3. Generate es_systems.cfg
# 
& 'C:\Program Files (x86)\EmulationStation\emulationstation.exe'
$configPath = $env:userprofile+"\.emulationstation\es_systems.cfg"

while (!(Test-Path $configPath)) { 
    Write-Host "Checking for config file..."
    Start-Sleep 5
}

Stop-Process -Name "emulationstation"


# 
# 4. Prepare Retroarch
# 
$retroArchPath = $env:userprofile + "\.emulationstation\systems\retroarch\"
$retroArchBinary = $requirementsFolder + "RetroArch.7z"

New-Item -ItemType Directory -Force -Path $retroArchPath

Function Expand-Archive([string]$Path, [string]$Destination) {
    $7z_Application = "C:\Program Files\7-Zip\7z.exe"
    $7z_Arguments = @(
        'x'                         ## eXtract files with full paths
        '-y'                        ## assume Yes on all queries
        "`"-o$($Destination)`""     ## set Output directory
        "`"$($Path)`""              ## <archive_name>
    )
    & $7z_Application $7z_Arguments 
}

Expand-Archive -Path $retroArchBinary -Destination $retroArchPath


# 
# 5. Prepare cores
# 
$coresPath = $retroArchPath + "cores"

# NES Setup
$nesCore = $requirementsFolder + "fceumm_libretro.dll.zip"
Expand-Archive -Path $nesCore -Destination $coresPath

# N64 Setup
$n64Core = $requirementsFolder + "parallel_n64_libretro.dll.zip"
Expand-Archive -Path $n64Core -Destination $coresPath

# FBA Setup
$fbaCore = $requirementsFolder + "fbalpha2012_libretro.dll.zip"
Expand-Archive -Path $fbaCore -Destination $coresPath

# GBA Setup
$gbaCore = $requirementsFolder + "vba_next_libretro.dll.zip"
Expand-Archive -Path $gbaCore -Destination $coresPath

# SNES Setup
$snesCore = $requirementsFolder + "snes9x_libretro.dll.zip"
Expand-Archive -Path $snesCore -Destination $coresPath

# Genesis GX Setup
$mdCore = $requirementsFolder + "genesis_plus_gx_libretro.dll.zip"
Expand-Archive -Path $mdCore -Destination $coresPath

# Game boy Colour Setup
$gbcCore = $requirementsFolder + "gambatte_libretro.dll.zip"
Expand-Archive -Path $gbcCore -Destination $coresPath

# Atari2600 Setup
$atari2600Core = $requirementsFolder + "stella_libretro.dll.zip"
Expand-Archive -Path $atari2600Core -Destination $coresPath

# MAME Setup
$mameCore = $requirementsFolder + "mame_libretro.dll.zip"
Expand-Archive -Path $mameCore -Destination $coresPath

# PSX Setup
$psxEmulator = $requirementsFolder + "ePSXe205.zip"
$psxEmulatorPath = $env:userprofile + "\.emulationstation\systems\epsxe\"
$psxBiosPath = $psxEmulatorPath + "bios\"
New-Item -ItemType Directory -Force -Path $psxEmulatorPath
Expand-Archive -Path $psxEmulator -Destination $psxEmulatorPath

# PS2 Setup
$ps2EmulatorMsi = $requirementsFolder + "pcsx2-1.4.0-setup.exe"
$ps2EmulatorPath = $env:userprofile + "\.emulationstation\systems\pcsx2\"
$ps2BiosPath = $ps2EmulatorPath + "bios\"
Expand-Archive -Path $ps2EmulatorMsi -Destination $ps2EmulatorPath
New-Item -ItemType Directory -Force -Path $ps2BiosPath

# Gamecube Setup
$gcCore = $requirementsFolder + "dolphin_libretro.dll.zip"
Expand-Archive -Path $gcCore -Destination $coresPath

# 
# 6. Start Retroarch and generate a config.
# 
$retroarchExecutable = $retroArchPath + "retroarch.exe"
$retroarchConfigPath = $retroArchPath + "retroarch.cfg"

& $retroarchExecutable

while (!(Test-Path $retroarchConfigPath)) { 
    Write-Host "Checking for config file..."
    Start-Sleep 5
}

Stop-Process -Name "retroarch"


# 
# 7. Let's hack that config!
# 
$settingToFind = 'video_fullscreen = "false"'
$settingToSet = 'video_fullscreen = "true"'
(Get-Content $retroarchConfigPath) -replace $settingToFind, $settingToSet | Set-Content $retroarchConfigPath

$settingToFind = 'savestate_auto_load = "false"'
$settingToSet = 'savestate_auto_load = "true"'
(Get-Content $retroarchConfigPath) -replace $settingToFind, $settingToSet | Set-Content $retroarchConfigPath

$settingToFind = 'input_player1_analog_dpad_mode = "0"'
$settingToSet = 'input_player1_analog_dpad_mode = "1"'
(Get-Content $retroarchConfigPath) -replace $settingToFind, $settingToSet | Set-Content $retroarchConfigPath

$settingToFind = 'input_player2_analog_dpad_mode = "0"'
$settingToSet = 'input_player2_analog_dpad_mode = "1"'
(Get-Content $retroarchConfigPath) -replace $settingToFind, $settingToSet | Set-Content $retroarchConfigPath


# 
# 8. Add those roms!
# 
$romPath =  $env:userprofile+"\.emulationstation\roms"
New-Item -ItemType Directory -Force -Path $romPath

# Path creation + Open-Source / Freeware Rom population
$nesPath =  $romPath+"\nes"
$nesRom = $requirementsFolder + "assimilate_full.zip" 
New-Item -ItemType Directory -Force -Path $nesPath
Expand-Archive -Path $nesRom -Destination $nesPath

$n64Path =  $romPath+"\n64"
$n64Rom = $requirementsFolder + "pom-twin.zip"
New-Item -ItemType Directory -Force -Path $n64Path
Expand-Archive -Path $n64Rom -Destination $n64Path

$gbaPath =  $romPath+"\gba"
$gbaRom = $requirementsFolder + "uranus0ev_fix.gba"
New-Item -ItemType Directory -Force -Path $gbaPath
Copy-Item -Path $gbaRom -Destination $gbaPath

$mdPath = $romPath+"\megadrive"
$mdRom =  $requirementsFolder + "rickdangerous.gen"
New-Item -ItemType Directory -Force -Path $mdPath
Copy-Item -Path $mdRom -Destination $mdPath

$snesPath = $romPath+"\snes"
$snesRom = $requirementsFolder + "N-Warp Daisakusen V1.1.smc"
New-Item -ItemType Directory -Force -Path $snesPath
Copy-Item -Path $snesRom -Destination $snesPath

$psxPath = $romPath+"\psx"
$psxRom = $requirementsFolder + "Marilyn_In_the_Magic_World_(010a).7z"
New-Item -ItemType Directory -Force -Path $psxPath
Expand-Archive -Path $psxRom -Destination $psxPath

$ps2Path = $romPath+"\ps2"
New-Item -ItemType Directory -Force -Path $ps2Path

$gbcPath = $romPath+"\gbc"
$gbcRom = $requirementsFolder + "star_heritage.zip" 
New-Item -ItemType Directory -Force -Path $gbcPath
Expand-Archive -Path $gbcRom -Destination $gbcPath

$fbaPath =  $romPath+"\fba"
New-Item -ItemType Directory -Force -Path $fbaPath

$masterSystemPath =  $romPath+"\mastersystem"
New-Item -ItemType Directory -Force -Path $masterSystemPath

$atari2600Path =  $romPath+"\atari2600"
New-Item -ItemType Directory -Force -Path $atari2600Path

$mamePath =  $romPath+"\mame"
New-Item -ItemType Directory -Force -Path $mamePath

# 
# Not working, needs different core:
# 

# WIP: Need to test and find freeware games for these emulators.
# Need to write a bat to boot these
# ScummVm Setup
$scummVmPath =  $romPath+"\scummvm"
New-Item -ItemType Directory -Force -Path $scummVmPath

# NeogeoPocket Setup
$neogeoPocketPath =  $romPath+"\ngp"
New-Item -ItemType Directory -Force -Path $neogeoPocketPath

# Neogeo Setup
$neogeoPath =  $romPath+"\neogeo"
New-Item -ItemType Directory -Force -Path $neogeoPath

# MSX Setup
$msxPath =  $romPath+"\msx"
$msxCore = $requirementsFolder + "fmsx_libretro.dll.zip"
Expand-Archive -Path $msxCore -Destination $coresPath
New-Item -ItemType Directory -Force -Path $msxPath

# Commodore 64 Setup
$commodore64Path =  $romPath+"\c64"
$commodore64Core = $requirementsFolder + "vice_x64_libretro.dll.zip"
Expand-Archive -Path $commodore64Core -Destination $coresPath
New-Item -ItemType Directory -Force -Path $commodore64Path

# Amiga Setup
$amigaPath =  $romPath+"\amiga"
$amigaCore = $requirementsFolder + "puae_libretro.dll.zip"
Expand-Archive -Path $amigaCore -Destination $coresPath
New-Item -ItemType Directory -Force -Path $amigaPath

# Atari7800 Setup
$atari7800Path =  $romPath+"\atari7800"
$atari7800Core = $requirementsFolder + "prosystem_libretro.dll.zip"
Expand-Archive -Path $atari7800Core -Destination $coresPath
New-Item -ItemType Directory -Force -Path $atari7800Path

# Gamecube Setup
$gcPath =  $romPath+"\gc"
$gcCore = $requirementsFolder + "dolphin_libretro.dll.zip"
Expand-Archive -Path $gcCore -Destination $coresPath
New-Item -ItemType Directory -Force -Path $gcPath


# 
# 9. Hack the es_config file
# 
$esConfigFile = $env:userprofile+"\.emulationstation\es_systems.cfg"
$newConfig = "<systemList>
    <system>
        <name>nes</name>
        <fullname>Nintendo Entertainment System</fullname>
        <path>$nesPath</path>
        <extension>.nes .NES</extension>
        <command>$retroarchExecutable -L $coresPath\fceumm_libretro.dll %ROM%</command>
        <platform>nes</platform>
        <theme>nes</theme>
    </system>
    <system>
        <fullname>Super Nintendo</fullname>
        <name>snes</name>
        <path>$snesPath</path>
        <extension>.smc .sfc .fig .swc .SMC .SFC .FIG .SWC</extension>
        <command>$retroarchExecutable -L $coresPath\snes9x_libretro.dll %ROM%</command>
        <platform>snes</platform>
        <theme>snes</theme>
    </system>
    <system>
        <fullname>Nintendo 64</fullname>
        <name>n64</name>
        <path>$n64Path</path>
        <extension>.z64 .Z64 .n64 .N64 .v64 .V64</extension>
        <command>$retroarchExecutable -L $coresPath\parallel_n64_libretro.dll %ROM%</command>
        <platform>n64</platform>
        <theme>n64</theme>
    </system>
    <system>
        <fullname>Gamecube</fullname>
        <name>gc</name>
        <path>$gcPath</path>
        <extension>.iso .ISO</extension>
        <command>$retroarchExecutable -L $coresPath\dolphin_libretro.dll %ROM%</command>
        <platform>gc</platform>
        <theme>gc</theme>
    </system>
    <system>
        <fullname>Game Boy Color</fullname>
        <name>gbc</name>
        <path>$gbcPath</path>
        <extension>.gbc .GBC .zip .ZIP</extension>
        <command>$retroarchExecutable -L $coresPath\gambatte_libretro.dll %ROM%</command>
        <platform>gbc</platform>
        <theme>gbc</theme>
    </system>
    <system>
        <fullname>Game Boy Advance</fullname>
        <name>gba</name>
        <path>$gbaPath</path>
        <extension>.gba .GBA</extension>
        <command>$retroarchExecutable -L $coresPath\vba_next_libretro.dll %ROM%</command>
        <platform>gba</platform>
        <theme>gba</theme>
    </system>
    <system>
        <fullname>Playstation</fullname>
        <name>psx</name>
        <path>$psxPath</path>
        <extension>.cue .iso .pbp .CUE .ISO .PBP</extension>
        <command>${psxEmulatorPath}ePSXe.exe -bios ${psxBiosPath}SCPH1001.BIN -nogui -loadbin %ROM%</command>
        <platform>psx</platform>
        <theme>psx</theme>
    </system>
    <system>
        <fullname>Playstation 2</fullname>
        <name>ps2</name>
        <path>$ps2Path</path>
        <extension>.iso .img .bin .mdf .z .z2 .bz2 .dump .cso .ima .gz</extension>
        <command>${ps2EmulatorPath}pcsx2.exe %ROM% --fullscreen --nogui</command>
        <platform>ps2</platform>
        <theme>ps2</theme>
    </system>
    <system>
        <fullname>MAME</fullname>
        <name>mame</name>
        <path>$mamePath</path>
        <extension>.zip .ZIP</extension>
        <command>$retroarchExecutable -L $coresPath\mame_libretro.dll %ROM%</command>
        <platform>mame</platform>
        <theme>mame</theme>
    </system>
    <system>
        <fullname>Final Burn Alpha</fullname>
        <name>fba</name>
        <path>$fbaPath</path>
        <extension>.zip .ZIP .fba .FBA</extension>
        <command>$retroarchExecutable -L $coresPath\fbalpha2012_libretro.dll %ROM%</command>
        <platform>arcade</platform>
        <theme></theme>
    </system>
    <system>
        <fullname>Amiga</fullname>
        <name>amiga</name>
        <path>$amigaPath</path>
        <extension>.adf .ADF</extension>
        <command>$retroarchExecutable -L $coresPath\puae_libretro.dll %ROM%</command>
        <platform>amiga</platform>
        <theme>amiga</theme>
    </system>
    <system>
        <fullname>Atari 2600</fullname>
        <name>atari2600</name>
        <path>$atari2600Path</path>
        <extension>.a26 .bin .rom .A26 .BIN .ROM</extension>
        <command>$retroarchExecutable -L $coresPath\stella_libretro.dll %ROM%</command>
        <platform>atari2600</platform>
        <theme>atari2600</theme>
    </system>
    <system>
        <fullname>Atari 7800 Prosystem</fullname>
        <name>atari7800</name>
        <path>$atari7800Path</path>
        <extension>.a78 .bin .A78 .BIN</extension>
        <command>$retroarchExecutable -L $coresPath\prosystem_libretro.dll %ROM%</command>
        <platform>atari7800</platform>
        <theme>atari7800</theme>
    </system>
    <system>
        <fullname>Commodore 64</fullname>
        <name>c64</name>
        <path>$commodore64Path</path>
        <extension>.crt .d64 .g64 .t64 .tap .x64 .zip .CRT .D64 .G64 .T64 .TAP .X64 .ZIP</extension>
        <command>$retroarchExecutable -L $coresPath\vice_x64_libretro.dll %ROM%</command>
        <platform>c64</platform>
        <theme>c64</theme>
    </system>
    <system>
        <fullname>Sega Mega Drive / Genesis</fullname>
        <name>megadrive</name>
        <path>$mdPath</path>
        <extension>.smd .SMD .bin .BIN .gen .GEN .md .MD .zip .ZIP</extension>
        <command>$retroarchExecutable -L $coresPath\genesis_plus_gx_libretro.dll %ROM%</command>
        <platform>genesis,megadrive</platform>
        <theme>megadrive</theme>
    </system>
    <system>
        <fullname>Sega Master System</fullname>
        <name>mastersystem</name>
        <path>$masterSystemPath</path>
        <extension>.bin .sms .zip .BIN .SMS .ZIP</extension>
        <command>$retroarchExecutable -L $coresPath\genesis_plus_gx_libretro.dll %ROM%</command>
        <platform>mastersystem</platform>
        <theme>mastersystem</theme>
    </system>
    <system>
        <fullname>MSX</fullname>
        <name>msx</name>
        <path>$msxPath</path>
        <extension>.col .dsk .mx1 .mx2 .rom .COL .DSK .MX1 .MX2 .ROM</extension>
        <command>$retroarchExecutable -L $coresPath\fmsx_libretro.dll %ROM%</command>
        <platform>msx</platform>
        <theme>msx</theme>
    </system>
    <system>
        <name>neogeo</name>
        <fullname>Neo Geo</fullname>
        <path>$neogeoPath</path>
        <extension>.zip .ZIP</extension>
        <command>$retroarchExecutable -L $coresPath\fbalpha2012_libretro.dll %ROM%</command>        
        <platform>neogeo</platform>
        <theme>neogeo</theme>
    </system>
    <system>
        <fullname>Neo Geo Pocket</fullname>
        <name>ngp</name>
        <path>$neogeoPocketPath</path>
        <extension>.ngp .ngc .zip .ZIP</extension>
        <command>$retroarchExecutable -L $coresPath\fbalpha2012_libretro.dll %ROM%</command>        
        <platform>ngp</platform>
        <theme>ngp</theme>
    </system>
    <system>
        <fullname>ScummVM</fullname>
        <name>scummvm</name>
        <path>$scummVmPath</path>
        <extension>.bat .BAT</extension>
        <command>%ROM%</command>
        <platform>pc</platform>
        <theme>scummvm</theme>
    </system>
</systemList>
"
Set-Content $esConfigFile -Value $newConfig


# 
# 10. Setup a nice looking theme.
# 
$themesPath = $env:userprofile+"\.emulationstation\themes\"
$themesFile = $requirementsFolder + "master.zip"
Expand-Archive -Path $themesFile -Destination $requirementsFolder
$themesFolder = $requirementsFolder + "\recalbox-backport-master\"
robocopy $themesFolder $themesPath /E


# 
# 11. Use updated binaries.
# 
$emulationStationInstallFolder = "C:\Program Files (x86)\EmulationStation"
$updatedEmulationStatonBinaries = $requirementsFolder + "EmulationStation-Win32-continuous-master.zip"
Expand-Archive -Path $updatedEmulationStatonBinaries -Destination $emulationStationInstallFolder


# 
# 12. Generate settings file with favorites enabled.
# 
$esConfigFile = $env:userprofile+"\.emulationstation\es_settings.cfg"
$newSettingsConfig = "<?xml version='1.0'?>
<bool name='BackgroundJoystickInput' value='false' />
<bool name='CaptionsCompatibility' value='true' />
<bool name='DrawFramerate' value='false' />
<bool name='EnableSounds' value='true' />
<bool name='MoveCarousel' value='true' />
<bool name='ParseGamelistOnly' value='false' />
<bool name='QuickSystemSelect' value='true' />
<bool name='SaveGamelistsOnExit' value='true' />
<bool name='ScrapeRatings' value='true' />
<bool name='ScreenSaverControls' value='true' />
<bool name='ScreenSaverOmxPlayer' value='false' />
<bool name='ShowHelpPrompts' value='true' />
<bool name='ShowHiddenFiles' value='false' />
<bool name='SlideshowScreenSaverCustomImageSource' value='false' />
<bool name='SlideshowScreenSaverRecurse' value='false' />
<bool name='SlideshowScreenSaverStretch' value='false' />
<bool name='SortAllSystems' value='false' />
<bool name='StretchVideoOnScreenSaver' value='false' />
<bool name='UseCustomCollectionsSystem' value='true' />
<bool name='VideoAudio' value='true' />
<bool name='VideoOmxPlayer' value='false' />
<int name='MaxVRAM' value='100' />
<int name='ScraperResizeHeight' value='0' />
<int name='ScraperResizeWidth' value='400' />
<int name='ScreenSaverSwapImageTimeout' value='10000' />
<int name='ScreenSaverSwapVideoTimeout' value='30000' />
<int name='ScreenSaverTime' value='300000' />
<string name='AudioDevice' value='Master' />
<string name='CollectionSystemsAuto' value='favorites' />
<string name='CollectionSystemsCustom' value='' />
<string name='GamelistViewStyle' value='automatic' />
<string name='OMXAudioDev' value='both' />
<string name='PowerSaverMode' value='disabled' />
<string name='Scraper' value='TheGamesDB' />
<string name='ScreenSaverBehavior' value='dim' />
<string name='ScreenSaverGameInfo' value='never' />
<string name='SlideshowScreenSaverBackgroundAudioFile' value='$env:userprofile/.emulationstation/slideshow/audio/slideshow_bg.wav' />
<string name='SlideshowScreenSaverImageDir' value='$env:userprofile/.emulationstation/slideshow/image' />
<string name='SlideshowScreenSaverImageFilter' value='.png,.jpg' />
<string name='ThemeSet' value='recalbox-backport' />
<string name='TransitionStyle' value='fade' />

"

Set-Content $esConfigFile -Value $newSettingsConfig
$requiredTmpFolder = $env:userprofile+"\.emulationstation\tmp\"
New-Item -ItemType Directory -Force -Path $requiredTmpFolder


# 
# 13. Generate ini file for Dolphin.
# 
$dolphinConfigFile = $env:userprofile+"\.emulationstation\systems\retroarch\saves\User\Config\Dolphin.ini"
$dolphinConfigFolder = $env:userprofile+"\.emulationstation\systems\retroarch\saves\User\Config\"
$dolphinConfigFileContent = "[General]
LastFilename = 
ShowLag = False
ShowFrameCount = False
ISOPaths = 0
RecursiveISOPaths = False
NANDRootPath = 
DumpPath = 
WirelessMac = 
WiiSDCardPath = $env:userprofile\.emulationstation\systems\retroarch\saves\User\Wii\sd.raw
[Interface]
ConfirmStop = True
UsePanicHandlers = True
OnScreenDisplayMessages = True
HideCursor = False
AutoHideCursor = False
MainWindowPosX = -2147483648
MainWindowPosY = -2147483648
MainWindowWidth = -1
MainWindowHeight = -1
LanguageCode = 
ShowToolbar = True
ShowStatusbar = True
ShowLogWindow = False
ShowLogConfigWindow = False
ExtendedFPSInfo = False
ThemeName = Clean
PauseOnFocusLost = False
DisableTooltips = False
[Display]
FullscreenResolution = Auto
Fullscreen = False
RenderToMain = True
RenderWindowXPos = -1
RenderWindowYPos = -1
RenderWindowWidth = 640
RenderWindowHeight = 480
RenderWindowAutoSize = False
KeepWindowOnTop = False
ProgressiveScan = False
PAL60 = False
DisableScreenSaver = False
ForceNTSCJ = False
[GameList]
ListDrives = False
ListWad = True
ListElfDol = True
ListWii = True
ListGC = True
ListJap = True
ListPal = True
ListUsa = True
ListAustralia = True
ListFrance = True
ListGermany = True
ListItaly = True
ListKorea = True
ListNetherlands = True
ListRussia = True
ListSpain = True
ListTaiwan = True
ListWorld = True
ListUnknown = True
ListSort = 3
ListSortSecondary = 0
ColumnPlatform = True
ColumnBanner = True
ColumnNotes = True
ColumnFileName = False
ColumnID = False
ColumnRegion = True
ColumnSize = True
ColumnState = True
[Core]
HLE_BS2 = True
TimingVariance = 40
CPUCore = 1
Fastmem = True
CPUThread = True
DSPHLE = True
SyncOnSkipIdle = True
SyncGPU = True
SyncGpuMaxDistance = 200000
SyncGpuMinDistance = -200000
SyncGpuOverclock = 1.00000000
FPRF = False
AccurateNaNs = False
DefaultISO = 
DVDRoot = 
Apploader = 
EnableCheats = False
SelectedLanguage = 0
OverrideGCLang = False
DPL2Decoder = False
Latency = 2
AudioStretch = False
AudioStretchMaxLatency = 80
MemcardAPath = $env:userprofile\.emulationstation\systems\retroarch\saves\User\GC\MemoryCardA.USA.raw
MemcardBPath = $env:userprofile\.emulationstation\systems\retroarch\saves\User\GC\MemoryCardB.USA.raw
AgpCartAPath = 
AgpCartBPath = 
SlotA = 1
SlotB = 255
SerialPort1 = 255
BBA_MAC = 
SIDevice0 = 6
AdapterRumble0 = True
SimulateKonga0 = False
SIDevice1 = 0
AdapterRumble1 = True
SimulateKonga1 = False
SIDevice2 = 0
AdapterRumble2 = True
SimulateKonga2 = False
SIDevice3 = 0
AdapterRumble3 = True
SimulateKonga3 = False
WiiSDCard = False
WiiKeyboard = False
WiimoteContinuousScanning = False
WiimoteEnableSpeaker = False
RunCompareServer = False
RunCompareClient = False
EmulationSpeed = 1.00000000
FrameSkip = 0x00000000
Overclock = 1.00000000
OverclockEnable = False
GFXBackend = OGL
GPUDeterminismMode = auto
PerfMapDir = 
EnableCustomRTC = False
CustomRTCValue = 0x386d4380
[Movie]
PauseMovie = False
Author = 
DumpFrames = False
DumpFramesSilent = False
ShowInputDisplay = False
ShowRTC = False
[DSP]
EnableJIT = False
DumpAudio = False
DumpAudioSilent = False
DumpUCode = False
Backend = Libretro
Volume = 100
CaptureLog = False
[Input]
BackgroundInput = False
[FifoPlayer]
LoopReplay = False
[Analytics]
ID = 
Enabled = False
PermissionAsked = False
[Network]
SSLDumpRead = False
SSLDumpWrite = False
SSLVerifyCertificates = True
SSLDumpRootCA = False
SSLDumpPeerCert = False
[BluetoothPassthrough]
Enabled = False
VID = -1
PID = -1
LinkKeys = 
[USBPassthrough]
Devices = 
[Sysconf]
SensorBarPosition = 1
SensorBarSensitivity = 50331648
SpeakerVolume = 88
WiimoteMotor = True
WiiLanguage = 1
AspectRatio = 1
Screensaver = 0

"
New-Item $dolphinConfigFolder -ItemType directory
Write-Output $dolphinConfigFileContent  > $dolphinConfigFile

# 
# 14. Fixing epsxe bug setting the registry
# https://www.ngemu.com/threads/epsxe-2-0-5-startup-crash-black-screen-fix-here.199169/
# https://www.youtube.com/watch?v=fY89H8fLFSc
# 
$path = 'HKCU:\SOFTWARE\epsxe\config'

New-Item -Path $path -Force | Out-Null

Set-ItemProperty -Path $path -Name 'CPUOverclocking' -Value '10'

# 
# 15. Add in a game art scraper
# 
$scraperZip = $requirementsFolder + "scraper_windows_amd64*.zip"
Expand-Archive -Path $scraperZip -Destination $romPath


# 
# 16. Create some useful desktop shortcuts
# 
$userProfileVariable = Get-ChildItem Env:UserProfile
$romsShortcut = $userProfileVariable.Value + "\.emulationstation\roms"
$coresShortcut = $userProfileVariable.Value + "\.emulationstation\systems\retroarch\cores"
#$windowedEmulationStation = "C:\Program Files (x86)\EmulationStation\emulationstation.exe --windowed --resolution 1366 768"

$wshshell = New-Object -ComObject WScript.Shell
$desktop = [System.Environment]::GetFolderPath('Desktop')
$lnk = $wshshell.CreateShortcut($desktop+"\Roms Location.lnk")
$lnk.TargetPath = $romsShortcut
$lnk.Save() 

$lnk = $wshshell.CreateShortcut($desktop+"\Cores Location.lnk")
$lnk.TargetPath = $coresShortcut
$lnk.Save() 

#$lnk = $wshshell.CreateShortcut($desktop+"\Windowed EmulationStation.lnk")
#$lnk.TargetPath = $windowedEmulationStation
#$lnk.Save() 

# 
# 17. Enjoy your retro games!
# 
Write-Host "Enjoy!"

Read-Host -Prompt "Press Enter to exit"
