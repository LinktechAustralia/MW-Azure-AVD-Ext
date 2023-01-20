<# 
.SYNOPSIS
Install Mozilla Firefox on an image created with  Azure Image Builder 
.DESCRIPTION

#>

$AppName = 'Mozilla Firefox'
$EverGreenAppName = 'MozillaFirefox'

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $($AppName)"
$Path = "$env:SystemDrive\Apps\$($AppName)"

md "$Path"

winget.exe install --id mozilla.firefox --accept-package-agreements --scope machine --accept-source-agreements --silent
Write-Host "AIB Customization $($AppName) Exit code: " $LASTEXITCODE
if ($error[0]) {
	Write-Host "AIB Customization Error Message: " $error[0]
}
#Cleanup installers
Remove-Item "$Path" -Force -Recurse -Verbose