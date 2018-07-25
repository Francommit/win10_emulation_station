# Configuring
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir

$timestamp = Get-Date -Format FileDateTime

rename-item $dir\gamelist.xml -newname ("gamelist" + $timestamp + ".xml")
"$dir\scraper.exe rom_dir ./nes -rom_path ./nes -download_videos -download_marquees"







