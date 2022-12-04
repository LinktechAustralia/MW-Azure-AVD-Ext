<# 
.SYNOPSIS
Install Mozilla Firefox on an image created with  Azure Image Builder 
.DESCRIPTION

#>

$AppName = 'Mozilla Firefox'
$EverGreenAppName = 'MozillaFirefox'

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $($AppName)"
$Path = "$env:SystemDrive\Apps\$($AppName)"

# Evergreen Needed (https://github.com/aaronparker/evergreen)
If (!(Get-Module -Name Evergreen -ListAvailable -ErrorAction SilentlyContinue))
    {
        Install-Module -Name Evergreen -scope AllUsers -Force
    }
Import-Module Evergreen

#Download latest installer
$App = Get-EvergreenApp -Name $EverGreenAppName | Where-Object {  $_.Architecture -eq "x64" -and $_.Channel -eq "LATEST_FIREFOX_VERSION" -and $_.Type -eq "msi"} | Select-Object -First 1
Write-Host 'AIB Customization: Found version' $App.version

$OutFile = Save-EvergreenApp -InputObject $App -CustomPath "$Path" -WarningAction "SilentlyContinue"
$ArgumentList = "/i `"$($OutFile.FullName)`" /qn DESKTOP_SHORTCUT=false INSTALL_MAINTENANCE_SERVICE=false TASKBAR_SHORTCUT=false REGISTER_DEFAULT_AGENT=false"
$result = Start-Process -FilePath msiexec.exe -ArgumentList  "$ArgumentList" -NoNewWindow  -wait -passthru
Write-Host 'AIB Customization Error Message: ' $error[0]


#Removes the Desktop ShortCut
$DesktopShtCtPath = "C:\users\Public\Desktop\google chrome.lnk"
if (Test-Path $DesktopShtCtPath -ErrorAction SilentlyContinue) 
    {
        Remove-Item -Path $DesktopShtCtPath -Force -Verbose
    }

$masterPref = "C:\Program Files\Google\Chrome\Application\master_preferences"
$masterPrefJson = Get-Content $masterPref -Raw | ConvertFrom-Json
$masterPrefJson.distribution | Add-Member -MemberType NoteProperty -Name "do_not_create_desktop_shortcut" -Value 'True'
$masterPrefJson | ConvertTo-Json -Depth 4 | Out-File $masterPref -force


Write-Host 'AIB Customization Exit code: ' $LASTEXITCODE
Write-Host 'AIB Customization Error Message: ' $error[0]

#Cleanup installers
Remove-Item "$Path" -Force -Recurse -Verbose