<# 
.SYNOPSIS
Install Adobe Acrobat Pro on an image created with Azure Image Builder 
.DESCRIPTION
	- The script invokes a download of the latest installer by parsing the Adobe website.
	- Extracts the zip
	- Performs the install as per standard deplyment

	The argument list can be customised as required ref $ArgumentList

	Further policies / customisations can be done by updating the customisation region 
	Check https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Windows/Originals.html for more policies
.NOTES
	Created by Linktech Australia
	Author: Leroy D'Souza
.LINK

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

# Extract the installer
	Write-host "AIB Customization: Extracting $DownloadFileName"
	Expand-Archive $Destination "$Path" -Force 

# Begin Install
	$InstallerPath = Join-path $path "Adobe Acrobat"
	$InstallerFullFilePath = Join-Path  $InstallerPath setup.EXE
	$ArgumentList = '/sAll /rs /msi  EULA_ACCEPT=YES LANG_LIST=en_US UPDATE_MODE=0 DISABLE_ARM_SERVICE_INSTALL=1 ADD_THUMBNAILPREVIEW=YES'
	Start-Process $InstallerFullFilePath -ArgumentList $ArgumentList -NoNewWindow -PassThru -Wait

#region Customisation
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown' -Value 1 -Name bIsSCReducedModeEnforcedEx -PropertyType DWORD -Force
	New-Item -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown\cServices' -Force -ErrorAction SilentlyContinue
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown\cServices' -Value 1 -Name bUpdater -PropertyType DWORD -Force
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown\cServices' -Value 0 -Name bToggleAdobeSign -PropertyType DWORD -Force
	New-Item -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown\cIPM' -Force -ErrorAction SilentlyContinue
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown\cIPM' -Value 0 -Name bDontShowMsgWhenViewingDoc -PropertyType DWORD -Force
	#endregion Customisation 