Import-Module BitsTransfer

# 
# 1. Chocolatey installs 
# 
choco install directx -y
choco install 7zip -y
choco install emulationstation.install -y
choco install vcredist2008 -y
choco install vcredist2010 -y
choco install vcredist2013 -y
choco install vcredist2015 -y

# 
# 2. Acquire files 
# 
$requirementsFolder = "$PSScriptRoot\requirements\"
New-Item -ItemType Directory -Force -Path $requirementsFolder

Get-Content download_list.json | ConvertFrom-Json | Select -expand downloads | ForEach-Object {

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

# This is a temporary hack until I make some nicer JSON files and clean it up.
# 
# Latest ES Windows binaries
$repo = "jrassa/emulationstation"
$file = "EmulationStation-Win32.zip"

$releases = "https://api.github.com/repos/$repo/releases"
$tag = (Invoke-WebRequest $releases -usebasicparsing| ConvertFrom-Json)[0].tag_name

$downloadUrl = "https://github.com/$repo/releases/download/$tag/$file"
$name = $file.Split(".")[0]
$zip = "$name-$tag.zip"
$output = $requirementsFolder + $zip

Invoke-WebRequest $downloadUrl -Out $output

# Theme that supports the latest ES binaries
$repo = "recalbox/recalbox-themes"
$file = "recalbox-multi-v2.0.0.tar.xz"

$releases = "https://api.github.com/repos/$repo/releases"
$tag = (Invoke-WebRequest $releases -usebasicparsing| ConvertFrom-Json)[0].tag_name

$downloadUrl = "https://github.com/$repo/releases/download/$tag/$file"
$name = $file.Split(".")[0]
$zip = "$name-$tag.zip"
$output = $requirementsFolder + $zip

Invoke-WebRequest $downloadUrl -Out $output


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
$retroArchBinary = $requirementsFolder + "\RetroArch.7z"

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
$newCoreZipFile = $requirementsFolder + "\Cores-v1.0.0.2-64-bit.zip"
New-Item -ItemType Directory -Force -Path $coresPath
Expand-Archive -Path $newCoreZipFile -Destination $coresPath

# NES Setup
$nesCore = $requirementsFolder + "\fceumm_libretro.dll.zip"
Expand-Archive -Path $nesCore -Destination $coresPath

# N64 Setup
$n64Core = $requirementsFolder + "\parallel_n64_libretro.dll.zip"
Expand-Archive -Path $n64Core -Destination $coresPath

# FBA Setup
$fbaCore = $requirementsFolder + "\fbalpha2012_libretro.dll.zip"
Expand-Archive -Path $fbaCore -Destination $coresPath

# GBA Setup
$gbaCore = $requirementsFolder + "\vba_next_libretro.dll.zip"
Expand-Archive -Path $gbaCore -Destination $coresPath

# SNES Setup
$snesCore = $requirementsFolder + "\snes9x_libretro.dll.zip"
Expand-Archive -Path $snesCore -Destination $coresPath

# Genesis GX Setup
$mdCore = $requirementsFolder + "\genesis_plus_gx_libretro.dll.zip"
Expand-Archive -Path $mdCore -Destination $coresPath

# PSX Setup
$psxCore = $requirementsFolder + "\mednafen_psx_libretro.dll.zip"
$psxEmulatorPath = $env:userprofile + "\.emulationstation\systems\epsxe\"
$psxEmulator = $requirementsFolder + "\ePSXe205.zip"
$psxBiosPath = $env:userprofile + "\.emulationstation\bios\"
Expand-Archive -Path $psxCore -Destination $coresPath
New-Item -ItemType Directory -Force -Path $psxEmulatorPath
Expand-Archive -Path $psxEmulatorPath -Destination $psxEmulator


# 
# 6. Start Retroarch and generate a config.
# 
$retroarchExecutable = $retroArchPath + "retroarch.exe"
$retroarchConfigPath = $retroArchPath + "\retroarch.cfg"

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


# 
# 8. Add those roms!
# 
$romPath =  $env:userprofile+"\.emulationstation\roms"
New-Item -ItemType Directory -Force -Path $romPath

# Path creation + Open-Source / Freeware Rom population
$nesPath =  $romPath+"\nes"
$nesRom = $requirementsFolder + "\assimilate_full.zip" 
New-Item -ItemType Directory -Force -Path $nesPath
Expand-Archive -Path $nesRom -Destination $nesPath

$n64Path =  $romPath+"\n64"
$n64Rom = $requirementsFolder + "\pom-twin.zip"
New-Item -ItemType Directory -Force -Path $n64Path
Expand-Archive -Path $n64Rom -Destination $n64Path

$gbaPath =  $romPath+"\gba"
$gbaRom = $requirementsFolder + "\uranus0ev_fix.gba"
New-Item -ItemType Directory -Force -Path $gbaPath
Move-Item -Path $gbaRom -Destination $gbaPath

$mdPath = $romPath+"\megadrive"
$mdRom =  $requirementsFolder + "\rickdangerous.gen"
New-Item -ItemType Directory -Force -Path $mdPath
Move-Item -Path $mdRom -Destination $mdPath

$snesPath = $romPath+"\snes"
$snesRom = $requirementsFolder + "\N-Warp Daisakusen V1.1.smc"
New-Item -ItemType Directory -Force -Path $snesPath
Move-Item -Path $snesRom -Destination $snesPath

$psxPath = $romPath+"\psx"
$psxRom = $requirementsFolder + "\Marilyn_In_the_Magic_World_(010a).7z"
New-Item -ItemType Directory -Force -Path $psxPath
Expand-Archive -Path $psxRom -Destination $psxPath

$fbaPath =  $romPath+"\fba"
New-Item -ItemType Directory -Force -Path $fbaPath




# 
# 9. Hack the es_config file
# 
$esConfigFile = $env:userprofile+"\.emulationstation\es_systems.cfg"
$newConfig = "
<systemList>
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
        <fullname>Nintendo 64</fullname>
        <name>n64</name>
        <path>$n64Path</path>
        <extension>.z64 .Z64 .n64 .N64 .v64 .V64</extension>
        <command>$retroarchExecutable -L $coresPath\parallel_n64_libretro.dll %ROM%</command>
        <platform>n64</platform>
        <theme>n64</theme>
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
        <fullname>Game Boy Advance</fullname>
        <name>gba</name>
        <path>$gbaPath</path>
        <extension>.gba .GBA</extension>
        <command>$retroarchExecutable -L $coresPath\vba_next_libretro.dll %ROM%</command>
        <platform>gba</platform>
        <theme>gba</theme>
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
        <fullname>Super Nintendo</fullname>
        <name>snes</name>
        <path>$snesPath</path>
        <extension>.smc .sfc .fig .swc .SMC .SFC .FIG .SWC</extension>
        <command>$retroarchExecutable -L $coresPath\snes9x_libretro.dll %ROM%</command>
        <platform>snes</platform>
        <theme>snes</theme>
    </system>
    <system>
        <fullname>Playstation</fullname>
        <name>psx</name>
        <path>$psxPath</path>
        <extension>.cue .iso .pbp .CUE .ISO .PBP</extension>
        <command>$psxEmulatorPath\$psxEmulator -bios .emulationstation\bios\SCPH1001.BIN -nogui -loadbin %ROM_RAW%</command>
        <platform>psx</platform>
        <theme>psx</theme>
    </system>
</systemList>
"

Set-Content $esConfigFile -Value $newConfig


# 
# 11. Setup a nice looking theme.
# 
$themesPath = $env:userprofile+"\.emulationstation\themes\"
$themesFile = $requirementsFolder + "recalbox-multi-v2-recalbox-multi-v2.0.0.zip"
$themesFiles = $requirementsFolder + "recalbox-multi-v2-recalbox-multi-v2.0.0"
New-Item -ItemType Directory -Force -Path $themesPath
Expand-Archive -Path $themesFile -Destination $requirementsFolder
Expand-Archive -Path $themesFiles -Destination $themesPath


# 
# 12. Use updated binaries.
# 
$emulationStationInstallFolder = "C:\Program Files (x86)\EmulationStation"
$updatedEmulationStatonBinaries = $requirementsFolder + "\EmulationStation-Win32-continuous.zip"
Expand-Archive -Path $updatedEmulationStatonBinaries -Destination $emulationStationInstallFolder


# 
# 13. Update the recalbox theme to use the correct folder naming conventions
# 
$incorrectFolderName = $env:userprofile+"\.emulationstation\themes\recalbox-multi\favorites"
$correctFolderName = "auto-favorites"
& Rename-Item -Path $incorrectFolderName -NewName $correctFolderName


# 
# 14. Generate settings file with favorites enabled.
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
<string name='ThemeSet' value='recalbox-multi' />
<string name='TransitionStyle' value='fade' />

"

Set-Content $esConfigFile -Value $newSettingsConfig
$requiredTmpFolder = $env:userprofile+"\.emulationstation\tmp\"
New-Item -ItemType Directory -Force -Path $requiredTmpFolder


# 14. Enjoy your retro games!
Write-Host "Enjoy!"