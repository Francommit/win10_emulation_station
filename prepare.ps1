Import-Module BitsTransfer

# 1. Chocolatey installs 
choco install directx -y
choco install emulationstation.install -y

# 2. Acqurie files 
$folder = "$PSScriptRoot\requirements\"
New-Item -ItemType Directory -Force -Path $folder

Get-Content download_list.json | ConvertFrom-Json | Select -expand downloads | ForEach-Object {

    $url = $_.url
    $file = $_.file
    $output = $folder + $file

    if(![System.IO.File]::Exists($output)){

        Write-Host $file "does not exist...Downloading."
        Start-BitsTransfer -Source $url -Destination $output
        Write-Host "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    } else {

        Write-Host $file "Already exists...Skipping download."

    }

}

# 3. Generate es_systems.cfg
& 'C:\Program Files (x86)\EmulationStation\emulationstation.exe'
$configPath = $env:userprofile+"\.emulationstation\es_systems.cfg"

while (!(Test-Path $configPath)) { 
    Write-Host "Checking for config file..."
    Start-Sleep 2
}

Stop-Process -Name "emulationstation"