Import-Module BitsTransfer

# choco install directx -y
# choco install emulationstation.install -y

$UrlContents = Get-Content $PSScriptRoot\download_list.txt |  ForEach-Object {

    $url = $_
    $output = "$PSScriptRoot\" + ($_.split("{/}") | Select-Object -Last 1)
    $start_time = Get-Date

    Start-BitsTransfer -Source $url -Destination $output
    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

}


