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

$SafeAppxs = @("Microsoft.WindowsCalculator","Microsoft.Windows.Photos","Microsoft.ScreenSketch")


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
$DefaultUserSettingsjsonadds = $DefaultUserSettingsjsonadds | ConvertFrom-Json

$DefUsrSettjsonFile = "$($LocalPath)\Virtual-Desktop-Optimization-Tool-main\2009\ConfigurationFiles\DefaultUserSettings.json"
$DefaultUserSettingsjson = Get-Content "$DefUsrSettjsonFile" -Raw | ConvertFrom-Json

$DefaultUserSettingsjson += $DefaultUserSettingsjsonadds

$DefaultUserSettingsjson  | ConvertTo-Json | Out-File $DefUsrSettjsonFile -Force


#Invoke the script
.\Windows_VDOT.ps1 -Optimizations All -Verbose -AcceptEula -windowsversion 2009


#Cleanup
Remove-Item $LocalPath -Force