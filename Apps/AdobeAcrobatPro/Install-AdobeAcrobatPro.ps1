<# 
.SYNOPSIS
Install Adobe Acrobat Pro on an image created with  Azure Image Builder 
.DESCRIPTION
The script invokes a download of the latest Office Deplyment Toolkit.
Extracts the toolkit

#>
Function LogDate {"$(Get-date -fo s)" + "`t"}
$AppName = 'Adobe Acrobat Pro'
Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $AppName"
$Path = "$env:SystemDrive\Apps\$($AppName)"
if (!(Test-Path $Path -ErrorAction SilentlyContinue)) #Create the folder if it does not exist
    {
        MD "$Path" -Force
    }

#Download the Installer

$URI = 'https://helpx.adobe.com/au/acrobat/kb/acrobat-dc-downloads.html'

$URIRef = Invoke-WebRequest -Uri $URI -UseBasicParsing 
$DownloadLink = $URIRef.Links | ? { $_.outerHTML -like '*trials*'-and $_.outerHTML -like '*x64*'} | select -First 1
$DownloadLink = $DownloadLink.href
$DownloadFileName = $([System.IO.Path]::GetFileName($DownloadLink.ToString()))
$Global:Destination = Join-path "$Path" $DownloadFileName
Start-BitsTransfer -Source $DownloadLink -Destination $Destination

Write-host "AIB Customization: Extracting $DownloadFileName"
Expand-Archive $Destination "$Path" -Force 

$InstallerPath = Join-path $path "Adobe Acrobat"
$InstallerFullFilePath = Join-Path  $InstallerPath setup.EXE
$ArgumentList = '/sAll /rs /msi  EULA_ACCEPT=YES LANG_LIST=en_US UPDATE_MODE=0 DISABLE_ARM_SERVICE_INSTALL=1 ADD_THUMBNAILPREVIEW=YES'
Start-Process $InstallerFullFilePath -ArgumentList $ArgumentList -NoNewWindow -PassThru -Wait

#Customisation
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown' -Value 1 -Name bIsSCReducedModeEnforcedEx -PropertyType DWORD -Force
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown\cServices' -Value 1 -Name bUpdater -PropertyType DWORD -Force
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown\cServices' -Value 0 -Name bToggleAdobeSign -PropertyType DWORD -Force
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown\cIPM' -Value 0 -Name bDontShowMsgWhenViewingDoc -PropertyType DWORD -Force