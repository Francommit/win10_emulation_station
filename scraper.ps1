# Configuring
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

$dir = $env:userprofile+"\.emulationstation\roms"
$Command = "$dir\scraper.exe"

$timestamp = Get-Date -Format FileDateTime

#NES
$console = "$dir\nes"
Copy-Item $console\gamelist.xml "$console\gamelist$timestamp.xml"
$Params_list = "-rom_dir $console -rom_path $console -download_videos -download_marquees -console_src=ss"
$Params = $Params_list.Split("-")
& "$Command" $Params

#SNES
$console = "$dir\snes"
Copy-Item $console\gamelist.xml "$console\gamelist$timestamp.xml"
$Params_list = "-rom_dir $console -rom_path $console -download_videos -download_marquees -console_src=ss"
$Params = $Params_list.Split("-")
& "$Command" $Params