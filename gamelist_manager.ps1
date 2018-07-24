# Configuring
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir

$doc = [xml] (Get-Content -raw gamelist.xml)

foreach ($gameEl in $doc.DocumentElement.game) {
  # Use -replace to extract the filename without extension from the path contained in the <path> element and removing some special characters.
  $gameName = $gameEl.path -replace '^.*/(.*)\..*$', '$1' -replace "'", "_" -replace "[&]", "_"
  # Append elements 'video' and 'marquee', but only if they don't already exist.
  if ($null -eq $gameEl.video) {
    $gameEl.AppendChild($doc.CreateElement('video')).InnerText = "./videos/${gameName}.mp4"
  }
  if ($null -eq $gameEl.marquee) {
    $gameEl.AppendChild($doc.CreateElement('marquee')).InnerText = "./marquees/${gameName}.png"
  }
  # Fix for already existing special characters
  $safeFileName = $gameEl.path -replace "'", "_" -replace "[&]", "_"
  $gameEl.path = $safeFileName

  $safeFileName = $gameEl.video -replace "'", "_" -replace "[&]", "_"
  $gameEl.video = $safeFileName

  $safeFileName = $gameEl.marquee -replace "'", "_" -replace "[&]", "_"
  $gameEl.marquee = $safeFileName

  $safeFileName = $gameEl.image -replace "'", "_" -replace "[&]", "_"
  $gameEl.image = $safeFileName
}

$timestamp = Get-Date -Format FileDateTime

rename-item gamelist.xml -newname ("gamelist" + $timestamp + ".xml")
$writer = [System.IO.StreamWriter] "$PSScriptRoot\gamelist.xml"
$doc.Save($writer)
$writer.Close()

