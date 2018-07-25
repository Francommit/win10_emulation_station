# Configuring
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

$dir = $env:userprofile+"\.emulationstation\roms"

$timestamp = Get-Date -Format FileDateTime

#Backup for gamelist file
Copy-Item $dir\nes\gamelist.xml "$dir\nes\gamelist$timestamp.xml"

#NES
$Command = "$dir\scraper.exe"
$Params_list = "-rom_dir $dir\nes -rom_path $dir\nes -download_videos -download_marquees -console_src=ss"

$Params = $Params_list.Split("-")
& "$Command" $Params