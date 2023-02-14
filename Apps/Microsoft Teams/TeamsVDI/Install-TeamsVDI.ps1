$AppName = 'Teams'
#Invoke-WebRequest -Uri $url -OutFile 
Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $($AppName)"
$Path = "$env:SystemDrive\Apps\$($AppName)"

if (!(Test-Path $Path)) {
	mkdir $Path
}



# set regKey
write-host 'AIB Customization: Set required regKey'
if (!(Test-Path HKLM:\SOFTWARE\Microsoft -ErrorAction SilentlyContinue)){
New-Item -Path HKLM:\SOFTWARE\Microsoft -Name "Teams" }
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Teams -Name "IsWVDEnvironment" -Type "Dword" -Value "1"
write-host "AIB Customization $($AppName): Finished Set required regKey"


# install vc
write-host 'AIB Customization: Install the latest Microsoft Visual C++ Redistributable'
set-Location $Path
$visCplusURL = 'https://aka.ms/vs/16/release/vc_redist.x64.exe'
$visCplusURLexe = 'vc_redist.x64.exe'
$outputPath = $Path + '\' + $visCplusURLexe
Invoke-WebRequest -Uri $visCplusURL -OutFile $outputPath
write-host 'AIB Customization: Starting Install the latest Microsoft Visual C++ Redistributable'
Start-Process -FilePath $outputPath -Args "/install /quiet /norestart /log C:\windows\logs\vcdist.log" -Wait
write-host 'AIB Customization: Finished Install the latest Microsoft Visual C++ Redistributable'


# install webSoc svc
write-host 'AIB Customization: Install the Teams WebSocket Service'
$webSocketsURL = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt'
$webSocketsInstallerMsi = 'webSocketSvc.msi'
$outputPath = $Path + '\' + $webSocketsInstallerMsi
Invoke-WebRequest -Uri $webSocketsURL -OutFile $outputPath
Start-Process -FilePath msiexec.exe -Args "/I $outputPath /quiet /norestart /log C:\windows\logs\webSocket.log" -Wait
write-host 'AIB Customization: Finished Install the Teams WebSocket Service'

# install Teams
write-host 'AIB Customization: Install MS Teams'
$teamsURL = 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true'
$teamsMsi = 'teams.msi'
$outputPath = $Path + '\' + $teamsMsi
Invoke-WebRequest -Uri $teamsURL -OutFile $outputPath
Start-Process -FilePath msiexec.exe -Args "/I $outputPath /quiet /norestart /log C:\windows\logs\teams.log OPTIONS=`"noAutoStart=true`" ALLUSER=1 ALLUSERS=1 " -Wait
write-host 'AIB Customization: Finished Install MS Teams' 

Set-Location C:\Windows\System32

Remove-item -Path $Path -Force -Recurse