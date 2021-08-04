# Some certs have expired - temp fix
if (-not("dummy" -as [type])) {
    add-type -TypeDefinition @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

public static class Dummy {
    public static bool ReturnTrue(object sender,
        X509Certificate certificate,
        X509Chain chain,
        SslPolicyErrors sslPolicyErrors) { return true; }

    public static RemoteCertificateValidationCallback GetDelegate() {
        return new RemoteCertificateValidationCallback(Dummy.ReturnTrue);
    }
}
"@
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = [dummy]::GetDelegate()

function DownloadFiles {
    param ([String]$jsonDownloadOption)
    
    Write-Host "Starting downloading of $jsonDownloadOption"

    Get-Content "$scriptDir\download_list.json" | ConvertFrom-Json | Select-Object -expand $jsonDownloadOption | ForEach-Object {
    
        $url = $_.url
        $file = $_.file
        $output = "$requirementsFolder\$file"

        if(![System.IO.File]::Exists($output)){
    
            Write-Host "INFO: Downloading $file"
            Invoke-WebRequest $url -Out $output
            Write-Host "INFO: Finished Downloading $file successfully"
    
        } else {
    
            Write-Host $file "INFO: Already exists...Skipping download."
    
        }
    
    }

}

function GithubReleaseFiles {

    Get-Content "$scriptDir\download_list.json" | ConvertFrom-Json | Select-Object -expand releases | ForEach-Object {

        $repo = $_.repo
        $file = $_.file
        $releases = "https://api.github.com/repos/$repo/releases"
        $tag = (Invoke-WebRequest $releases -usebasicparsing| ConvertFrom-Json)[0].tag_name
    
        $url = "https://github.com/$repo/releases/download/$tag/$file"
        $output = "$requirementsFolder\$file"

        if(![System.IO.File]::Exists($output)) {
    
            Write-Host "INFO: Downloading $file"
            Invoke-WebRequest $url -Out $output
            Write-Host "INFO: Finished Downloading $file successfully"
    
        } else {
    
            Write-Host $file "INFO: Already exists...Skipping download."
        }

        Get-ChildItem $requirementsFolder
    
    }

}

function Expand-Archive([string]$Path, [string]$Destination) {
    $7z_Application = "C:\Program Files\7-Zip\7z.exe"
    $7z_Arguments = @(
        'x'                         ## eXtract files with full paths
        '-y'                        ## assume Yes on all queries
        "`"-o$($Destination)`""     ## set Output directory
        "`"$($Path)`""              ## <archive_name>
    )
    & $7z_Application $7z_Arguments | Out-Null
}

# Get script path
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath
Write-Host "INFO: Script directory is: $scriptDir"

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install git -y | Out-Null

# Install and setup scoop
if($env:path -match "scoop"){
    Write-Host "INFO: Scoop appears to be installed, skipping installation"
} else {
    Write-Host "INFO: Scoop not detected, installing scoop"
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

Write-Host "INFO: Adding scoop bucket"
scoop bucket add emulators https://github.com/borger/scoop-emulators.git
Write-Host "INFO: Installing Citra Nightly"
scoop install citra-nightly
scoop install ppsspp
scoop install yuzu

$citraInstallDir = "$env:userprofile\scoop\apps\citra-nightly\current"
$ppssppInstallDir = "$env:userprofile\scoop\apps\ppsspp\current"
$yuzuInstallDir = "$env:userprofile\scoop\apps\yuzu\current"

choco install 7zip --no-progress -y | Out-Null
choco install dolphin --pre --no-progress -y | Out-Null
choco install cemu --no-progress -y | Out-Null

# Acquire files 
$requirementsFolder = "$PSScriptRoot\requirements"
New-Item -ItemType Directory -Force -Path $requirementsFolder
DownloadFiles("downloads")
DownloadFiles("other_downloads")
GithubReleaseFiles

# Install Emulation Station
Start-Process "$requirementsFolder\emulationstation_win32_latest.exe" -ArgumentList "/S" -Wait

# Generate Emulation Station config file
& "${env:ProgramFiles(x86)}\EmulationStation\emulationstation.exe"
while (!(Test-Path "$env:userprofile\.emulationstation\es_systems.cfg")) { 
    Write-Host "INFO: Checking for config file..."
    Start-Sleep 5
}
Write-Host "INFO: Config file generated"
Stop-Process -Name "emulationstation"

# Prepare Retroarch
$retroArchPath = "$env:userprofile\.emulationstation\systems\retroarch\"
$coresPath = "$retroArchPath\cores"
$retroArchBinary = "$requirementsFolder\RetroArch.7z"
if(Test-Path $retroArchBinary){
    New-Item -ItemType Directory -Force -Path $retroArchPath | Out-Null
    Expand-Archive -Path $retroArchBinary -Destination $retroArchPath | Out-Null
} else {
    Write-Host "ERROR: $retroArchBinary not found."
    exit -1
}

# NES Setup
$nesCore = "$requirementsFolder\fceumm_libretro.dll.zip"
if(Test-Path $nesCore){
    Expand-Archive -Path $nesCore -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $nesCore not found."
    exit -1
}

# N64 Setup
$n64Core = "$requirementsFolder\parallel_n64_libretro.dll.zip"
if(Test-Path $n64Core){
    Expand-Archive -Path $n64Core -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $n64Core not found."
    exit -1
}

# FBA Setup
$fbaCore = "$requirementsFolder\fbalpha2012_libretro.dll.zip"
if(Test-Path $fbaCore){
    Expand-Archive -Path $fbaCore -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $fbaCore not found."
    exit -1
}

# GBA Setup
$gbaCore = "$requirementsFolder\vba_next_libretro.dll.zip"
if(Test-Path $gbaCore){
    Expand-Archive -Path $gbaCore -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $gbaCore not found."
    exit -1
}

# SNES Setup
$snesCore = "$requirementsFolder\snes9x_libretro.dll.zip"
if(Test-Path $snesCore){
    Expand-Archive -Path $snesCore -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $snesCore not found."
    exit -1
}

# Genesis GX Setup
$mdCore = "$requirementsFolder\genesis_plus_gx_libretro.dll.zip"
if(Test-Path $mdCore){
    Expand-Archive -Path $mdCore -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $mdCore not found."
    exit -1
}

# Game boy Colour Setup
$gbcCore = "$requirementsFolder\gambatte_libretro.dll.zip"
if(Test-Path $gbcCore){
    Expand-Archive -Path $gbcCore -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $gbcCore not found."
    exit -1
}

# Atari2600 Setup
$atari2600Core = "$requirementsFolder\stella_libretro.dll.zip"
if(Test-Path $atari2600Core){
    Expand-Archive -Path $atari2600Core -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $atari2600Core not found."
    exit -1
}

# MAME Setup
$mameCore = "$requirementsFolder\mame2010_libretro.dll.zip"
if(Test-Path $mameCore){
    Expand-Archive -Path $mameCore -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $mameCore not found."
    exit -1
}

# PSX Setup
$psxEmulator = "$requirementsFolder\ePSXe205.zip"
if(Test-Path $psxEmulator){
    $psxEmulatorPath = "$env:userprofile\.emulationstation\systems\epsxe\"
    $psxBiosPath = $psxEmulatorPath + "bios\"
    New-Item -ItemType Directory -Force -Path $psxEmulatorPath | Out-Null
    Expand-Archive -Path $psxEmulator -Destination $psxEmulatorPath | Out-Null
} else {
    Write-Host "ERROR: $psxEmulator not found."
    exit -1
}

# PS2 Setup
$ps2EmulatorMsi = "$requirementsFolder\pcsx2-1.6.0-setup.exe"
if(Test-Path $ps2EmulatorMsi){
    $ps2EmulatorPath = "$env:userprofile\.emulationstation\systems\pcsx2\"
    $ps2Binary = "$ps2EmulatorPath\`$TEMP\PCSX2 1.6.0\pcsx2.exe"
    $ps2BiosPath = "$ps2EmulatorPath\bios\"
    Expand-Archive -Path $ps2EmulatorMsi -Destination $ps2EmulatorPath | Out-Null
    New-Item -ItemType Directory -Force -Path $ps2BiosPath | Out-Null
} else {
    Write-Host "ERROR: $ps2EmulatorMsi not found."
    exit -1
}

# NeoGeo Pocket Setup
$ngpCore = "$requirementsFolder\race_libretro.dll.zip"
if(Test-Path $ngpCore){
    Expand-Archive -Path $ngpCore -Destination $coresPath | Out-Null
} else {
    Write-Host "ERROR: $ngpCore not found."
    exit -1
}

# Start Retroarch and generate a config.
$retroarchExecutable = "$retroArchPath\retroarch.exe"
$retroarchConfigPath = "$retroArchPath\retroarch.cfg"

if (Test-Path $retroarchExecutable) {
    
    Write-Host "INFO: Retroarch executable found, launching"
    Start-Process $retroarchExecutable
    
    while (!(Test-Path $retroarchConfigPath)) { 
        Write-Host "INFO: Checking for retroarch config file"
        Start-Sleep 5
    }

    $retroarchProcess = Get-Process retroarch.exe -ErrorAction SilentlyContinue
    if ($retroarchProcess) {
        $retroarchProcess.CloseMainWindow()
        Start-sleep 5
        if (!$retroarchProcess.HasExited) {
            $retroarchProcess | Stop-Process -Force
        }
    }
    Stop-Process -Name "retroarch" -ErrorAction SilentlyContinue

} else {
    Write-Host "ERROR: Could not find retroarch.exe"
    exit -1
}


# Tweak retroarch config!
Write-Host "INFO: Replacing retroarch config"
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

# Add roms
$romPath =  "$env:userprofile\.emulationstation\roms"
New-Item -ItemType Directory -Force -Path $romPath | Out-Null

# Path creation + Open-Source / Freeware Rom population
Write-Host "INFO: Setup NES"
$nesPath =  "$romPath\nes"
$nesRom = "$requirementsFolder\assimilate_full.zip" 
if(Test-Path $nesRom){
    New-Item -ItemType Directory -Force -Path $nesPath | Out-Null
    Expand-Archive -Path $nesRom -Destination $nesPath | Out-Null
} else {
    Write-Host "ERROR: $nesRom not found."
    exit -1
}

Write-Host "INFO: Setup N64"
$n64Path =  "$romPath\n64"
$n64Rom = "$requirementsFolder\pom-twin.zip"
if(Test-Path $n64Rom){
    New-Item -ItemType Directory -Force -Path $n64Path | Out-Null
    Expand-Archive -Path $n64Rom -Destination $n64Path | Out-Null
} else {
    Write-Host "ERROR: $n64Rom not found."
    exit -1
}

Write-Host "INFO: Setup psp"
$pspPath = "$romPath\psp"
$pspRom = "$requirementsFolder\cube.elf"
if (Test-Path $pspRom) {
    New-Item -ItemType Directory -Force -Path $pspPath | Out-Null
    Move-Item -Path $pspRom -Destination $pspPath | Out-Null
}
else {
    Write-Host "ERROR: $pspRom not found."
    exit -1
}

Write-Host "INFO: Setup Nintendo Switch"
$switchPath = "$romPath\switch"
$switchRom = "$requirementsFolder\tetriswitch.nro"
if (Test-Path $switchRom) {
    New-Item -ItemType Directory -Force -Path $switchPath | Out-Null
    Move-Item -Path $switchRom -Destination $switchPath | Out-Null
}
else {
    Write-Host "ERROR: $switchRom not found."
    exit -1
}

Write-Host "INFO: Setup PS Vita"
$vitaPath = "$romPath\vita"
$vitaRom = "$requirementsFolder\C4.vpk"
if (Test-Path $vitaRom) {
    New-Item -ItemType Directory -Force -Path $vitaPath | Out-Null
    Move-Item -Path $vitaRom -Destination $vitaPath | Out-Null
}
else {
    Write-Host "ERROR: $vitaRom not found."
    exit -1
}

Write-Host "INFO: Setup Vita3k"
$vita3kInstallFolder = "${env:ProgramFiles}\Vita3k"
if(-not(Test-Path $vita3kInstallFolder)){
    New-Item -ItemType Directory -Force -Path $vita3kInstallFolder | Out-Null
}

$vita3kLatestBuild = "$requirementsFolder\windows-latest.zip"
if(Test-Path $vita3kLatestBuild){
    Expand-Archive -Path $vita3kLatestBuild -Destination $vita3kInstallFolder | Out-Null
} else {
    Write-Host "ERROR: $vita3kLatestBuild not found."
    exit -1
}

Write-Host "INFO: Setup 3DS"
$3dsPath = "$romPath\3ds"
$3dsRom = "$requirementsFolder\ccleste.3dsx"
if (Test-Path $3dsRom) {
    New-Item -ItemType Directory -Force -Path $3dsPath | Out-Null
    Move-Item -Path $3dsRom -Destination $3dsPath | Out-Null
}
else {
    Write-Host "ERROR: $3dsRom not found."
    exit -1
}

Write-Host "INFO: Setup GBA"
$gbaPath =  "$romPath\gba"
$gbaRom = "$requirementsFolder\uranus0ev_fix.gba"
if(Test-Path $gbaRom){
    New-Item -ItemType Directory -Force -Path $gbaPath | Out-Null
    Copy-Item -Path $gbaRom -Destination $gbaPath | Out-Null
} else {
    Write-Host "ERROR: $gbaRom not found."
    exit -1
}

Write-Host "INFO: Setup Megadrive"
$mdPath = "$romPath\megadrive"
$mdRom = "$requirementsFolder\rickdangerous.gen"
if(Test-Path $mdRom){
    New-Item -ItemType Directory -Force -Path $mdPath | Out-Null
    Copy-Item -Path $mdRom -Destination $mdPath | Out-Null
} else {
    Write-Host "ERROR: $mdRom not found."
    exit -1
}

Write-Host "INFO: Setup SNES"
$snesPath = "$romPath\snes"
$snesRom = "$requirementsFolder\N-Warp Daisakusen V1.1.smc"
if(Test-Path $snesRom){
    New-Item -ItemType Directory -Force -Path $snesPath | Out-Null
    Copy-Item -Path $snesRom -Destination $snesPath | Out-Null
} else {
    Write-Host "ERROR: $snesRom not found."
    exit -1
}

Write-Host "INFO: Setup PSX"
$psxPath = "$romPath\psx"
$psxRom = "$requirementsFolder\Marilyn_In_the_Magic_World_(010a).7z"
if(Test-Path $psxRom){
    New-Item -ItemType Directory -Force -Path $psxPath | Out-Null
    Expand-Archive -Path $psxRom -Destination $psxPath | Out-Null
} else {
    Write-Host "ERROR: $psxRom not found."
    exit -1
}

Write-Host "INFO: Setup PS2"
$ps2Path = "$romPath\ps2"
$ps2Rom = "$requirementsFolder\hermes-v.latest-ps2.zip"
if(Test-Path $ps2Rom){
    New-Item -ItemType Directory -Force -Path $ps2Path | Out-Null
    Expand-Archive -Path $ps2Rom -Destination $ps2Path | Out-Null
} else {
    Write-Host "ERROR: $ps2Rom not found."
    exit -1
}

Write-Host "INFO: Setup Gameboy"
$gbPath = "$romPath\gb"
New-Item -ItemType Directory -Force -Path $gbPath | Out-Null

Write-Host "INFO: Setup Gameboy Colour"
$gbcPath = "$romPath\gbc"
$gbcRom = "$requirementsFolder\star_heritage.zip" 
if(Test-Path $gbcRom){
    New-Item -ItemType Directory -Force -Path $gbcPath | Out-Null
    Expand-Archive -Path $gbcRom -Destination $gbcPath | Out-Null
} else {
    Write-Host "ERROR: $gbcRom not found."
    exit -1
}

Write-Host "INFO: Setup Mastersystem"
$masterSystemPath =  "$romPath\mastersystem"
$masterSystemRom = "$requirementsFolder\WahMunchers-SMS-R2.zip" 
if(Test-Path $masterSystemRom){
    New-Item -ItemType Directory -Force -Path $masterSystemPath | Out-Null
    Expand-Archive -Path $masterSystemRom -Destination $masterSystemPath | Out-Null
} else {
    Write-Host "ERROR: $masterSystemRom not found."
    exit -1
}

Write-Host "INFO: Setup FBA"
$fbaPath =  "$romPath\fba"
New-Item -ItemType Directory -Force -Path $fbaPath | Out-Null

Write-Host "INFO: Atari2600 Setup"
$atari2600Path =  "$romPath\atari2600"
$atari2600Rom = "$requirementsFolder\ramless_pong.bin"
if(Test-Path $atari2600Rom){
    New-Item -ItemType Directory -Force -Path $atari2600Path | Out-Null
    Copy-Item -Path $atari2600Rom -Destination $atari2600Path | Out-Null
} else {
    Write-Host "ERROR: $atari2600Rom not found."
    exit -1
}

Write-Host "INFO: MAME setup"
$mamePath =  "$romPath\mame"
New-Item -ItemType Directory -Force -Path $mamePath | Out-Null

# WIP: Need to test and find freeware games for these emulators.
# Need to write a bat to boot these
Write-Host "INFO: ScummVm Setup"
$scummVmPath =  "$romPath\scummvm"
New-Item -ItemType Directory -Force -Path $scummVmPath | Out-Null

$wiiuPath =  "$romPath\wiiu"
New-Item -ItemType Directory -Force -Path $wiiuPath | Out-Null

Write-Host "INFO: NeogeoPocket Setup"
$neogeoPocketPath =  "$romPath\ngp"
$ngpRom = "$requirementsFolder\neopocket.zip"
if(Test-Path $ngpRom){
    New-Item -ItemType Directory -Force -Path $neogeoPocketPath | Out-Null
    Expand-Archive -Path $ngpRom -Destination $neogeoPocketPath | Out-Null
} else {
    Write-Host "ERROR: $ngpRom not found."
    exit -1
}

Write-Host "INFO: Neogeo Setup"
$neogeoPath =  "$romPath\neogeo"
New-Item -ItemType Directory -Force -Path $neogeoPath | Out-Null

Write-Host "INFO: MSX Setup"
$msxPath =  "$romPath\msx"
$msxCore = "$requirementsFolder\fmsx_libretro.dll.zip"
if(Test-Path $msxCore){
    Expand-Archive -Path $msxCore -Destination $coresPath | Out-Null
    New-Item -ItemType Directory -Force -Path $msxPath | Out-Null
} else {
    Write-Host "ERROR: $msxCore not found."
    exit -1
}

Write-Host "INFO: Commodore 64 Setup"
$commodore64Path =  "$romPath\c64"
$commodore64Core = "$requirementsFolder\vice_x64_libretro.dll.zip"
if(Test-Path $commodore64Core){
    Expand-Archive -Path $commodore64Core -Destination $coresPath | Out-Null
    New-Item -ItemType Directory -Force -Path $commodore64Path | Out-Null
} else {
    Write-Host "ERROR: $commodore64Core not found."
    exit -1
}

Write-Host "INFO: Amiga Setup"
$amigaPath =  "$romPath\amiga"
$amigaCore = "$requirementsFolder\puae_libretro.dll.zip"
if(Test-Path $amigaCore){
    Expand-Archive -Path $amigaCore -Destination $coresPath | Out-Null
    New-Item -ItemType Directory -Force -Path $amigaPath | Out-Null
} else {
    Write-Host "ERROR: $amigaCore not found."
    exit -1
}

Write-Host "INFO: Setup Atari7800"
$atari7800Path =  "$romPath\atari7800"
$atari7800Core = "$requirementsFolder\prosystem_libretro.dll.zip"
if(Test-Path $atari7800Core){
    Expand-Archive -Path $atari7800Core -Destination $coresPath | Out-Null
    New-Item -ItemType Directory -Force -Path $atari7800Path | Out-Null
} else {
    Write-Host "ERROR: $atari7800Core not found."
    exit -1
}

Write-Host "INFO: Setup Wii/Gaemcube"
$gcPath =  "$romPath\gc"
$wiiPath = "$romPath\wii"
$wiiRom = "$requirementsFolder\Homebrew.Channel.-.OHBC.wad"
New-Item -ItemType Directory -Force -Path $gcPath | Out-Null
New-Item -ItemType Directory -Force -Path $wiiPath | Out-Null
if(Test-Path $wiiRom){
    Copy-Item $wiiRom $wiiPath | Out-Null
} else{
    Write-Host "ERROR: $wiiRom not found."
    exit -1
}

Write-Host "INFO: Setting up Emulation Station Config"
$esConfigFile = "$env:userprofile\.emulationstation\es_systems.cfg"

# TO-DO
# Vita Launching is a BIT hacky, works in powershell
#  .\Vita3K.exe --vpk-path "%ROM% | .\Vita3K.exe

$newConfig = "<systemList>
    <system>
        <name>vita</name>
        <fullname>Vita</fullname>
        <path>$vitaPath</path>
        <extension>.vpk .VPK</extension>
        <command>C:\Program Files\Vita3k\Vita3K.exe --vpk-path %ROM%</command>
        <platform>vita</platform>
        <theme>vita</theme>
        </system>
    <system>
        <name>switch</name>
        <fullname>Switch</fullname>
        <path>$switchPath</path>
        <extension>.nsp .NSP .zip .ZIP .7z .nso .NSO .nro .NRO .nca .NCA .xci .XCI</extension>
        <command>$yuzuInstallDir\yuzu.exe %ROM%</command>
        <platform>switch</platform>
        <theme>switch</theme>
    </system>
        <system>
        <name>psp</name>
        <fullname>Playstation Portable</fullname>
        <path>$pspPath</path>
        <extension>.iso .ISO .cso .CSO .elf</extension>
        <command>$ppssppInstallDir\PPSSPPWindows.exe %ROM%</command>
        <platform>psp</platform>
        <theme>psp</theme>
    </system>
    <system>
        <name>n3ds</name>
        <fullname>Nintendo 3DS</fullname>
        <path>$3dsPath</path>
        <extension>.3ds .3DS .3dsx .3DSX</extension>
        <command>$citraInstallDir\citra.exe %ROM%</command>
        <platform>n3ds</platform>
        <theme>3ds</theme>
    </system>
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
        <command>C:\tools\Dolphin-x64\Dolphin.exe -e `"%ROM_RAW%`"</command>
        <platform>gc</platform>
        <theme>gc</theme>
    </system>
    <system>
        <name>wii</name>
        <fullname>Nintendo Wii</fullname>
        <path>$wiiPath</path>
        <extension>.iso .ISO .wad .WAD</extension>
        <command>C:\tools\Dolphin-x64\Dolphin.exe -e `"%ROM_RAW%`"</command>
        <platform>wii</platform>
        <theme>wii</theme>  
    </system>
    <system>
        <fullname>Game Boy</fullname>
        <name>gb</name>
        <path>$gbPath</path>
        <extension>.gb .zip .ZIP .7z</extension>
        <command>$retroarchExecutable -L $coresPath\gambatte_libretro.dll %ROM%</command>
        <platform>gb</platform>
        <theme>gb</theme>
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
        <command>${$ps2Binary} %ROM% --fullscreen --nogui</command>
        <platform>ps2</platform>
        <theme>ps2</theme>
    </system>
    <system>
        <fullname>MAME</fullname>
        <name>mame</name>
        <path>$mamePath</path>
        <extension>.zip .ZIP</extension>
        <command>$retroarchExecutable -L $coresPath\mame2010_libretro.dll %ROM%</command>
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
        <command>$retroarchExecutable -L $coresPath\race_libretro.dll %ROM%</command>        
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
    <system>
        <name>wiiu</name>
        <fullname>Nintendo Wii U</fullname>
        <path>$wiiuPath</path>
        <extension>.rpx .RPX</extension>
        <command>START /D C:\tools\cemu\ Cemu.exe -f -g `"%ROM_RAW%`"</command>
        <platform>wiiu</platform>
        <theme>wiiu</theme>
</system>
</systemList>
"
Set-Content $esConfigFile -Value $newConfig

Write-Host "INFO: Setting up Emulation Station theme recalbox-backport"
$themesPath = "$env:userprofile\.emulationstation\themes\recalbox-backport\"
$themesFile = "$requirementsFolder\recalbox-backport-v2.1.zip"
if(Test-Path $themesFile){
    Expand-Archive -Path $themesFile -Destination $requirementsFolder | Out-Null
    $themesFolder = "$requirementsFolder\recalbox-backport\"
    robocopy $themesFolder $themesPath /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
} else {
    Write-Host "ERROR: $themesFile not found."
    exit -1
}

Write-Host "INFO: Update EmulationStation binaries"
$emulationStationInstallFolder = "${env:ProgramFiles(x86)}\EmulationStation"
$updatedEmulationStatonBinaries = "$requirementsFolder\EmulationStation-Win32.zip"
if(Test-Path $updatedEmulationStatonBinaries){
    Expand-Archive -Path $updatedEmulationStatonBinaries -Destination $emulationStationInstallFolder | Out-Null
} else {
    Write-Host "ERROR: $updatedEmulationStatonBinaries not found."
    exit -1
}

Write-Host "INFO: Generate ES settings file with favorites enabled."
$esConfigFile = "$env:userprofile\.emulationstation\es_settings.cfg"
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
$requiredTmpFolder = "$env:userprofile\.emulationstation\tmp\"
New-Item -ItemType Directory -Force -Path $requiredTmpFolder | Out-Null

Write-Host "INFO: Genrating Dolphin Config"
$dolphinConfigFile = "$env:userprofile\.emulationstation\systems\retroarch\saves\User\Config\Dolphin.ini"
$dolphinConfigFolder = "$env:userprofile\.emulationstation\systems\retroarch\saves\User\Config\"
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
New-Item $dolphinConfigFolder -ItemType directory | Out-Null
Write-Output $dolphinConfigFileContent  > $dolphinConfigFile

# TO-DO: Review if this is still needed or not
# # https://www.ngemu.com/threads/epsxe-2-0-5-startup-crash-black-screen-fix-here.199169/
# # https://www.youtube.com/watch?v=fY89H8fLFSc
# $path = 'HKCU:\SOFTWARE\epsxe\config'
# New-Item -Path $path -Force | Out-Null
# Set-ItemProperty -Path $path -Name 'CPUOverclocking' -Value '10'

Write-Host "INFO: Adding scraper in"
$scraperZip = "$requirementsFolder\scraper_windows_amd64.zip"
if(Test-Path $scraperZip){
    Expand-Archive -Path $scraperZip -Destination $romPath | Out-Null
} else {
    Write-Host "ERROR: $scraperZip not found."
    exit -1
}

Write-Host "INFO: Adding in useful desktop shortcuts"
$userProfileVariable = Get-ChildItem Env:UserProfile
$romsShortcut = $userProfileVariable.Value + "\.emulationstation\roms"
$coresShortcut = $userProfileVariable.Value + "\.emulationstation\systems\retroarch\cores"
$windowedEmulationStation = "${env:ProgramFiles(x86)}\EmulationStation\emulationstation.exe"

$wshshell = New-Object -ComObject WScript.Shell
$desktop = [System.Environment]::GetFolderPath('Desktop')
$lnkRoms = $wshshell.CreateShortcut("$desktop\Roms Location.lnk")
$lnkRoms.TargetPath = $romsShortcut
$lnkRoms.Save() 

$lnkCores = $wshshell.CreateShortcut("$desktop\Cores Location.lnk")
$lnkCores.TargetPath = $coresShortcut
$lnkCores.Save() 

$lnkWindowed = $wshshell.CreateShortcut("$desktop\Windowed EmulationStation.lnk")
$lnkWindowed.Arguments = "--resolution 1366 768 --windowed"
$lnkWindowed.TargetPath = $windowedEmulationStation
$lnkWindowed.Save() 

Write-Host "INFO: Setup completed"
