<# 
.SYNOPSIS
Install Mozilla Firefox on an image created with  Azure Image Builder 
.DESCRIPTION

#>

$AppName = 'Mozilla Firefox'
$EverGreenAppName = 'MozillaFirefox'
$WingetName = 'mozilla.firefox'

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $($AppName)"
$Path = "$env:SystemDrive\Apps\$($AppName)"

md "$Path"

#Find Winget
$WingetExe = (dir "C:\program files\windowsapps"  -Filter winget.exe -Recurse | select -first 1).fullname

#Perform Install
saps "$($WingetExe)" -args "install --id mozilla.firefox --accept-package-agreements --scope machine --accept-source-agreements --silent" -NoNewWindow -PassThru -Wait


Write-Host "AIB Customization $($AppName) Exit code: " $LASTEXITCODE
if ($error[0]) {
	Write-Host "AIB Customization Error Message: " $error[0]
}
#Cleanup installers
Remove-Item "$Path" -Force -Recurse -Verbose