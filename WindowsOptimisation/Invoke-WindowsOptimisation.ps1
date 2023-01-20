<# 
.SYNOPSIS
Script to invoke the optimisation of windows during the AIB build
.DESCRIPTION
Script uses the code created by https://github.com/The-Virtual-Desktop-Team 

Below code will first download the code zip, extract, manipulate any items as necessary then run the finale script

.NOTES
v1.0
.COMPONENT
https://github.com/The-Virtual-Desktop-Team 

.LINK 
https://github.com/LinktechAustralia/MW-Azure-AVD-Ext

#>
<# 
START VARIABLE DECLARATION
#>
$SafeAppxs = @("Microsoft.WindowsCalculator","Microsoft.Windows.Photos","Microsoft.ScreenSketch")
$DefaultUserSettingsjsonadds = @"
[{
	"HivePath": "HKLM:\\VDOT_TEMP\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced",
	"KeyName": "HideFileExt",
	"PropertyType": "DWORD",
	"PropertyValue": 0,
	"SetProperty": "True"
},
{
"HivePath": "HKLM:\\VDOT_TEMP\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced",
"KeyName": "NavPaneExpandToCurrentFolder",
"PropertyType": "DWORD",
"PropertyValue": 0,
"SetProperty": "True"
}]
"@
$FeatureRemoval = @("Printing-XPSServices-Features") #Place the features that are required to be uninstalled e.g @("Printing-XPSServices-Features","Internet-Explorer-Optional-amd64"). A list can be generated from a machine by running Get-WindowsOptionalFeature -online

$FeatureAddition = @()	#Place the features that are required to be installed e.g. @("TFTP","NetFx3")
$CapabilityRemoval = @("Print.Fax.Scan~~~~0.0.1.0")
$CapabilityAddition = @()

$StartMenuLayoutURI = "https://stavdauekrau.blob.core.windows.net/avdrepository/KEAU-StartMenu.xml?st=2023-01-20T03:30:03Z&si=avd_read_2028&spr=https&sv=2021-06-08&sr=b&sig=im%2BaWpQ0kECMSRQ4iFIw0C2EHZCr19gWdKHjgrvZNLY%3D"

$AppAssociationsURI =  "https://stavdauekrau.blob.core.windows.net/avdrepository/avdfileassociations.xml?st=2023-01-20T04:19:18Z&si=avd_read_2028&spr=https&sv=2021-06-08&sr=b&sig=vSX%2FYD5MkJANfXtZgWe0RX7UbTcJYg70KFsy1VYtHaI%3D"

<# 
END of VARIABLE DECLARATION
#>

function LogDateTime {
	"$(Get-date -Format s)`t"
}

#Download the VDOT Toolkit
write-host 'AIB Customization: OS Optimizations for AVD'
$appName = 'AVD_Optimize'
$drive = 'C:\Apps'
New-Item -Path $drive -Name $appName  -ItemType Directory -ErrorAction SilentlyContinue
$LocalPath = Join-Path $drive $appName 
set-Location $LocalPath
$osOptURL = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/master.zip'
$osOptURLexe = 'Windows_10_VDI_Optimize-master.zip'
$outputPath = Join-path $LocalPath  $osOptURLexe
Invoke-WebRequest -Uri $osOptURL -OutFile $outputPath
write-host 'AIB Customization: Starting OS Optimizations script'
$ExpandArchive = Expand-Archive -Path "$outputPath" -DestinationPath $Localpath -Force -Verbose
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -Verbose
Set-Location -Path $((dir $LocalPath -Directory).FullName)


#KEEP APPX
$AppxPackagesjsonFile = "$($LocalPath)\Virtual-Desktop-Optimization-Tool-main\2009\ConfigurationFiles\AppxPackages.json"
$AppxPackagesjson = Get-Content "$AppxPackagesjsonFile" -Raw | ConvertFrom-Json

foreach ($Appx in $AppxPackagesjson.appxpackage) {
	if ($Appx -notin $SafeAppxs	) {
		"Disabling $appx"
		($AppxPackagesjson | ? {$_.appxpackage -match "$Appx"}).vdistate = 'disabled'
	}
} 
$AppxPackagesjson | ConvertTo-Json | Out-File $AppxPackagesjsonFile -Force



#Default User Settings
$DefaultUserSettingsjsonadds = $DefaultUserSettingsjsonadds | ConvertFrom-Json
$DefUsrSettjsonFile = "$($LocalPath)\Virtual-Desktop-Optimization-Tool-main\2009\ConfigurationFiles\DefaultUserSettings.json"
$DefaultUserSettingsjson = Get-Content "$DefUsrSettjsonFile" -Raw | ConvertFrom-Json
$DefaultUserSettingsjson += $DefaultUserSettingsjsonadds
$DefaultUserSettingsjson  | ConvertTo-Json | Out-File $DefUsrSettjsonFile -Force


#Invoke the script
.\Windows_VDOT.ps1 -Optimizations All -Verbose -AcceptEula -windowsversion 2009


#Cleanup VDOT
Remove-Item $LocalPath -Force -Recurse


#Remove features
foreach ($Feature in $FeatureRemoval) {
	if ((Get-WindowsOptionalFeature -Online -FeatureName $Feature -ErrorAction SilentlyContinue).State -eq 'enabled') {

		Write-Host "AIB Customization: Removing Feature $($Feature)"
		Disable-WindowsOptionalFeature -Online -FeatureName $Feature

		} else {
			Write-Host "AIB Customization: Feature $($Feature) not enabled"
		}

}

#Remove capabilities
foreach ($Capability in $CapabilityRemoval) {
	if ((Get-WindowsCapability -Online -Name $Capability -ErrorAction SilentlyContinue).State -eq 'installed') {

		Write-Host "AIB Customization: Removing Feature $($Capability)"
		Remove-WindowsCapability -Online -FeatureName $Capability -Verbose

		} else {
			Write-Host "AIB Customization: Feature $($Capability) not installed"
		}

}

# Desktop Shortcut customisation	
$TeamsShortCut = "C:\programdata\Microsoft\Windows\Start Menu\Programs\Microsoft Teams.lnk"
	if (!(Test-Path $TeamsShortCut -ErrorAction SilentlyContinue)) {
	Copy-Item "C:\programdata\Microsoft\Windows\Start Menu\Programs\Microsoft Teams.lnk" "C:\Users\Public\Desktop" 
	}



# Start Menu 
Write-Host "$(LogDateTime)AIB Customization: Importing Start Menu"
$outputPath = Join-Path $LocalPath LayoutModification.xml
Invoke-WebRequest -Uri $StartMenuLayoutURi -OutFile "$outputPath"
Import-StartLayout -LayoutPath $OutputPath -MountPath C:\ -ErrorAction SilentlyContinue
Copy-Item "$($installFolder)Layout.xml" "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Force -ErrorAction SilentlyContinue

#File Associations
$FileAssociationsxml = Join-Path $LocalPath AppAssociations.xml
Invoke-WebRequest -Uri $AppAssociationsURI -OutFile "$FileAssociationsxml"
Start-Process dism -ArgumentList "/online /Import-DefaultAppAssociations:`"$FileAssociationsxml`"" -Wait -NoNewWindow