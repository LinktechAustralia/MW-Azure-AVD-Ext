<# 
.SYNOPSIS
Install Adobe Reader on an image created with  Azure Image Builder 
.DESCRIPTION
To be used for 

#>

$AppName = 'Adobe Acrobat Reader DC'
$EverGreenAppName = 'AdobeAcrobatReaderDC'
$Language = 'English' # Change this to customise the installed language version of adobe reader 

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
$App = Get-EvergreenApp $EverGreenAppName | ? {$_.Architecture -eq 'x86' -and $_.Language -eq 'English'} 
Write-Host 'AIB Customization: Found version' $App.version

$OutFile = Save-EvergreenApp -InputObject $App -CustomPath "$Path" -WarningAction "SilentlyContinue"
$ArgumentList = "/sAll /rs /msi  EULA_ACCEPT=YES LANG_LIST=en_US UPDATE_MODE=0 DISABLE_ARM_SERVICE_INSTALL=1 ADD_THUMBNAILPREVIEW=YES"
$result = Start-Process -FilePath msiexec.exe -ArgumentList  "$ArgumentList" -NoNewWindow  -wait -passthru
Write-Host 'AIB Customization Error Message: ' $error[0]




Write-Host 'AIB Customization Exit code: ' $LASTEXITCODE
Write-Host 'AIB Customization Error Message: ' $error[0]

#Cleanup installers
Remove-Item "$Path" -Force -Recurse -Verbose