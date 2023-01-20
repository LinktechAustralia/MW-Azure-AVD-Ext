$AppName = 'WinGet'
#Invoke-WebRequest -Uri $url -OutFile 
Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $($AppName)"
$Path = "$env:SystemDrive\Apps\$($AppName)"

if (!(Test-Path $Path)) {
	md $Path
}

#Install Dependencies XAML
#$DownloadURL = ((Invoke-WebRequest https://www.nuget.org/packages/Microsoft.UI.Xaml/ -UseBasicParsing).links | ? {$_.outerhtml -match 'download the'} | select -First 1).href

$DownloadURL =  "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.2"

$OutPath = Join-path $Path "Microsoft.UI.Xaml.zip"
Invoke-WebRequest -Uri $DownloadURL -OutFile $OutPath 
Expand-Archive $OutPath "$($Path)" -Force
$APPXs = dir "$($Path)" -Filter *.appx -Recurse | ? {$_.FullName -match "x64" -or $_.FullName -match "x86"}
foreach ($Appx in $APPXs)
{
  Add-AppxPackage -Path $Appx.fullname -Verbose
}

#Install Winget
Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.3.2691/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile .\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

Remove-Item $Path -Force -Recurse