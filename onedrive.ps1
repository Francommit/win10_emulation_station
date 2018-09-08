### Instructions
# This script is to use OneDrive to store your ROMs and save files
# Change the path on $onedrivePath variable or, create a folder structure as found on .emulationstation folder (for root and roms folder)
# The structure for save files are different on purpose, but you can change that as well
# Execute this script after prepare.ps1

# Get paths
$retroarchConfigPath = $env:userprofile + "\.emulationstation\systems\retroarch\retroarch.cfg"
$onedrivePath = $env:userprofile + "\OneDrive\.emulationstation\"

Write-Host "Caminho do arquivo retroarch: " + $retroarchConfigPath
Write-Host "Caminho do OneDrive" + $onedrivePath

# Console saves - retroarch.cfg
$settingToFind = 'savefile_directory = ":\saves"'
$settingToSet = 'savefile_directory = "' + $onedrivePath + 'saves"'
(Get-Content $retroarchConfigPath) -replace [regex]::escape($settingToFind), $settingToSet | Set-Content $retroarchConfigPath

# Save states - retroarch.cfg
$settingToFind = 'savestate_directory = ":\states"'
$settingToSet = 'savestate_directory = "' + $onedrivePath + 'saves\states"'
(Get-Content $retroarchConfigPath) -replace [regex]::escape($settingToFind), $settingToSet | Set-Content $retroarchConfigPath


# roms folder - es_systems.cfg
$esConfigFile = $env:userprofile + "\.emulationstation\es_systems.cfg"

Write-Host "Caminho do arquivo systems: " + $esConfigFile

$settingToFind = "<path>" + $env:userprofile + "\.emulationstation\"
$settingToSet = "<path>" + $onedrivePath
(Get-Content $esConfigFile) -replace [regex]::escape($settingToFind), $settingToSet | Set-Content $esConfigFile

Write-Host "Caminhos alterados para o OneDrive com sucesso"
