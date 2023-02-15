<#

.SYNOPSIS
Installs the Teams Machine Wide installer along with the SVD requirements

.LINK
https://learn.microsoft.com/en-us/microsoftteams/teams-for-vdi

.NOTES
	Created by	: 	Linktech Australia
	Author		:	Leroy DSouza
	Version		:	2.0
	Modified	:	20230215

.DESCRIPTION
	2023-02-15: Added the removal if existing Teams install exists. Needed to upgrade Teams if using an existing image or to ensure that the image has the latest Teams installed

#>

$AppName = 'Teams'
#Invoke-WebRequest -Uri $url -OutFile 
Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $($AppName)"
$Path = "$env:SystemDrive\Apps\$($AppName)"

if (!(Test-Path $Path)) {
	mkdir $Path
}

#Check if already installed and un-install
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$TeamsInstalled =  Get-ChildItem -Path $RegPath | Get-ItemProperty | Where-Object {$_.DisplayName -match "Teams Machine" }

	if ($TeamsInstalled) {
		# Remove Teams Machine-Wide Installer
		Write-Host "AIB Customization $($AppName): Removing existing Teams Machine-wide Installer" -ForegroundColor Yellow
		$TeamsMachineWide = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "$($TeamsInstalled.DisplayName)"}
		$TeamsMachineWide.Uninstall()
	}


	# set regKey
	write-host 'AIB Customization: Set required regKey'
	if (!(Test-Path HKLM:\SOFTWARE\Microsoft -ErrorAction SilentlyContinue)){
		New-Item -Path HKLM:\SOFTWARE\Microsoft -Name "Teams" 
	}
	New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Teams -Name "IsWVDEnvironment" -Type "Dword" -Value "1"
	write-host "AIB Customization $($AppName): Finished Set required regKey"


# install vc
write-host 'AIB Customization: Install the latest Microsoft Visual C++ Redistributable'
set-Location $Path
$visCplusURL = 'https://aka.ms/vs/16/release/vc_redist.x64.exe'
$visCplusURLexe = 'vc_redist.x64.exe'
$outputPath = Join-Path $Path $visCplusURLexe
Invoke-WebRequest -Uri $visCplusURL -OutFile $outputPath
write-host 'AIB Customization: Starting Install the latest Microsoft Visual C++ Redistributable'
Start-Process -FilePath $outputPath -Args "/install /quiet /norestart /log C:\windows\logs\Install-Teams-vcdist.log" -Wait
write-host "AIB Customization $($AppName): Finished Install the latest Microsoft Visual C++ Redistributable"


# install webSoc svc
write-host 'AIB Customization: Install the Teams WebSocket Service'
$webSocketsURL = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt'
$webSocketsInstallerMsi = 'webSocketSvc.msi'
$outputPath = $Path + '\' + $webSocketsInstallerMsi
Invoke-WebRequest -Uri $webSocketsURL -OutFile $outputPath
Start-Process -FilePath msiexec.exe -Args "/I $outputPath /quiet /norestart /log C:\windows\logs\Install-Teams-webSocket.log" -Wait
write-host "AIB Customization $($AppName): Finished Install the Teams WebSocket Service"

# install Teams
write-host 'AIB Customization: Install MS Teams'
$teamsURL = 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true'
$teamsMsi = 'teams.msi'
$outputPath = $Path + '\' + $teamsMsi
Invoke-WebRequest -Uri $teamsURL -OutFile $outputPath
Start-Process -FilePath msiexec.exe -Args "/I $outputPath /quiet /norestart /log C:\windows\logs\Install-Teams_MSI.log OPTIONS=`"noAutoStart=true`" ALLUSER=1 ALLUSERS=1 " -Wait
write-host "AIB Customization $($AppName): Finished Installing Teams Machine-Wide" 

Set-Location C:\Windows\System32

Remove-item -Path $Path -Force -Recurse
Remove-item -Path C:\temp -Force -Recurse