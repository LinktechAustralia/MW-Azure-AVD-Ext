
Start-Transcript $(Join-Path $env:TEMP Install-Chrome.log)
Write-Host 'AIB Customization: Google_Chrome'
$Path = "$env:SystemDrive\Apps\Google\Chrome"

# Evergreen Needed
Import-Module Evergreen

#Download latest installer
$Chrome = Get-EvergreenApp -Name "GoogleChrome" | Where-Object {  $_.Architecture -eq "x64" -and $_.Channel -eq "stable" } | Select-Object -First 1
$OutFile = Save-EvergreenApp -InputObject $Chrome -CustomPath $Path -WarningAction "SilentlyContinue"
$ArgumentList = "/i $($OutFile.FullName) ALLUSERS=1 NOGOOGLEUPDATE=1 /qn"
$result = Start-Process -FilePath msiexec.exe -ArgumentList  $ArgumentList -NoNewWindow  -wait -passthru
Write-Host 'AIB Customization Error Message: ' $error[0]


#Removes the ShortCut
$DesktopShtCtPath = "C:\users\Public\Desktop\google chrome.lnk"
if (Test-Path $DesktopShtCtPath -ErrorAction SilentlyContinue) 
    {
        Remove-Item -Path $DesktopShtCtPath -Force -Verbose
    }
Write-Host 'AIB Customization Exit code: ' $LASTEXITCODE
Write-Host 'AIB Customization Error Message: ' $error[0]

#Cleanup installers
Remove-Item $Path -Force