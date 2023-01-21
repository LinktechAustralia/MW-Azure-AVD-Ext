<# 
.SYNOPSIS
Install Mozilla Firefox on an image created with Azure Image Builder 
.DESCRIPTION
.NOTES
Created by Linktech Australia

Source URL from https://www.mozilla.org/en-US/firefox/all/#product-desktop-release
#>

$AppName = 'Mozilla Firefox'
$EverGreenAppName = 'MozillaFirefox'
$WingetName = 'mozilla.firefox'

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $($AppName)"
$Path = "$env:SystemDrive\Apps\$($AppName)"

md "$Path" -Force
# Unattended Install of Firefox

$SourceURL = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US"
$Installer = Join-path $Path "firefox.exe"; 
Invoke-WebRequest $SourceURL -OutFile $Installer
Start-Process -FilePath $Installer -Args "/s /TaskbarShortcut=false /DesktopShortcut=false /MaintenanceService=false /RegisterDefaultAgent=false" -NoNewWindow -Wait -PassThru -Verbose
Remove-Item $Path -Force -Verbose