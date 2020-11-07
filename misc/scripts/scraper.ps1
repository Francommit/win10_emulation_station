# General info
Write-host "This script is prepared for using ScreenScraper API, then you'll need to create a user there"
Write-host "It relies on scraper.exe already downloaded by prepare script"
Write-host "You gamelist file will be safe on a backup file on the same folder"
Write-host "The script works for a single system each time, use name convention from Emulationstation"
Write-host "Be patient and enjoy!"
Write-host "--------------------------------------------------------------"

# Configuring by user input
$login = Read-Host -Prompt 'Input your ScreenScraper login'
$password = Read-Host -Prompt 'Input your ScreenScraper password'
$system = Read-Host -Prompt 'Which system do you want to scrap'
Write-host "Are you using OneDriver folders for storing ROMs? (Default is No)"
    $Readhost = Read-Host " ( y / n ) "
    Switch ($ReadHost)
     {
       Y {$dir = $env:userprofile + "\OneDrive\.emulationstation\roms"}
       N {$dir = $env:userprofile + "\.emulationstation\roms"}
       Default {$dir = $env:userprofile + "\.emulationstation\roms"}
     }

# Setting variables
$Command = "$dir\scraper.exe"
$timestamp = Get-Date -Format FileDateTime

# Running
$console = "$dir\$system"
Copy-Item $console\gamelist.xml "$console\gamelist$timestamp.xml"
$Params_list = "&-rom_dir=$console &-rom_path=$console &-download_videos=true&-download_marquees=true&-console_src=ss&-ss_user=$login&-ss_password=$password&-image_dir=$console\images&-video_dir=$console\videos&-marquee_dir=$console\marquees&-output_file=$console\gamelist.xml&-rom_path=./&-image_path=./images&-marquee_path=./marquees&-video_path=./videos&-extra_ext=.PBP,.CDI,.ccd"
$Params = $Params_list.Split("&")
Write-Host "$Command" $Params
& "$Command" $Params

# Waiting for input to exit
Read-Host -Prompt "Press Enter to exit!"
