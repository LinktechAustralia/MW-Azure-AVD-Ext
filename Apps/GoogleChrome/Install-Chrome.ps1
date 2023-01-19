<# 
.SYNOPSIS
Install Google Chrome on an image created with  Azure Image Builder 
.DESCRIPTION

#>

$AppName = 'Google Chrome'
$EverGreenAppName = 'GoogleChrome'

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host 'AIB Customization: Google_Chrome'
$Path = "$env:SystemDrive\Apps\$($AppName)"

# Evergreen Needed (https://github.com/aaronparker/evergreen)
If (!(Get-Module -Name Evergreen -ListAvailable -ErrorAction SilentlyContinue))
    {
        Install-Module -Name Evergreen -scope AllUsers -Force
    }
Import-Module Evergreen

#Download latest installer
$App = Get-EvergreenApp -Name $EverGreenAppName | Where-Object {  $_.Architecture -eq "x64" -and $_.Channel -eq "stable" } | Select-Object -First 1
Write-Host 'AIB Customization: Found version' $App.version

$OutFile = Save-EvergreenApp -InputObject $App -CustomPath "$Path" -WarningAction "SilentlyContinue"
$ArgumentList = "/i `"$($OutFile.FullName)`" ALLUSERS=1 NOGOOGLEUPDATE=1 /qn"
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
$masterPrefJson.distribution | Add-Member -MemberType NoteProperty -Name "do_not_create_any_shortcuts" -Value 'True'
$masterPrefJson.distribution | Add-Member -MemberType NoteProperty -Name "show_welcome_page" -Value 'false'
$masterPrefJson.distribution | Add-Member -MemberType NoteProperty -Name "do_not_create_taskbar_shortcut" -Value 'true'
$masterPrefJson | ConvertTo-Json -Depth 4 | Out-File $masterPref -force


Write-Host 'AIB Customization Exit code: ' $LASTEXITCODE
Write-Host 'AIB Customization Error Message: ' $error[0]

#Cleanup installers
Remove-Item "$Path" -Force -Recurse -Verbose
