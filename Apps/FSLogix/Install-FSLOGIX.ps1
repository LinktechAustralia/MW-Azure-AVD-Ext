<# 
.SYNOPSIS
Install FSLOGIX on an image created with  Azure Image Builder 
.DESCRIPTION
Script checks for the latest version of FSlogix online and compares to the installed version
If the installed version does not exist or the 

#>

$AppName = 'FSLogix'
$EverGreenAppName = 'MicrosoftFSLogixApps'

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $($Appname)"
$Path = "$env:SystemDrive\Apps\$($AppName)"

# Evergreen Needed (https://github.com/aaronparker/evergreen)
If (!(Get-Module -Name Evergreen -ListAvailable -ErrorAction SilentlyContinue))
    {
        Install-Module -Name Evergreen -scope AllUsers -Force
    }
Import-Module Evergreen

# Check for online version 
$App = Get-EvergreenApp -Name $EverGreenAppName |  Select-Object -First 1
[version]$Appversion = $App.version
Write-Host "AIB Customization: Found Online version $($App.version) "

#Currently installed
Write-Host "AIB Customization: Searching installed applications"
$CurrentlyInstalled = Get-CimInstance -Class Win32_Product -filter "Name LIKE '%FSLOGIX%' " | sort Version -Descending | select -First 1
[version]$CurrentlyInstalledVersion = $CurrentlyInstalled.Version

function Get-Installer {    

$Global:OutFile = Save-EvergreenApp -InputObject $App -CustomPath "$Path" -WarningAction "SilentlyContinue"

}

function Install-App {

    Expand-Archive -Path $($OutFile.FullName) -DestinationPath $Path
    $InstallerFile = Join-Path $Path "x64\Release\FSLogixAppsSetup.exe"


    $ArgumentList = " /install /quiet"
    $result = Start-Process -FilePath "$InstallerFile" -ArgumentList  "$ArgumentList" -NoNewWindow  -wait -passthru
    Write-Host 'AIB Customization Error Message: ' $error[0]


    Write-Host 'AIB Customization Exit code: ' $LASTEXITCODE
    Write-Host 'AIB Customization Error Message: ' $error[0]
}

# If online version greater than installed version, reinstall


if ($Appversion -gt $CurrentlyInstalledVersion)
    {
        Get-Installer
        Install-App
    }
Else {
    Write-Host "AIB Customization : $($AppName) already installed with version $($Appversion.ToString())"
    Exit 0
 }

#Cleanup installers
Remove-Item "$Path" -Force -Recurse -Verbose