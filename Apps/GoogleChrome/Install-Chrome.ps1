<# 
.SYNOPSIS
Install Google Chrome on an image created with  Azure Image Builder 
.DESCRIPTION

#>

$AppName = 'Google Chrome'
$EverGreenAppName = 'GoogleChrome'

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host 'AIB Customization: Google_Chrome'
$Path = "$env:SystemDrive\Apps\$($AppName)"

# Evergreen Needed (https://github.com/aaronparker/evergreen)
If (!(Get-Module -Name Evergreen -ListAvailable -ErrorAction SilentlyContinue)) {
	if (!(Get-Module -Name NuGet)) { Install-PackageProvider -Name NuGet -Force -Scope AllUsers }
	Install-Module -Name Evergreen -scope AllUsers -Force
}
Import-Module Evergreen


#Download latest installer
$App = Get-EvergreenApp -Name $EverGreenAppName | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "stable" } | Select-Object -First 1
Write-Host 'AIB Customization: Found version' $App.version

$OutFile = Save-EvergreenApp -InputObject $App -CustomPath "$Path" -WarningAction "SilentlyContinue"
$ArgumentList = "/i `"$($OutFile.FullName)`" ALLUSERS=1 NOGOOGLEUPDATE=1 /qn"
$result = Start-Process -FilePath msiexec.exe -ArgumentList  "$ArgumentList" -NoNewWindow  -wait -passthru
Write-Host 'AIB Customization Error Message: ' $error[0]


#Removes the Desktop ShortCut
$DesktopShtCtPath = "C:\users\Public\Desktop\google chrome.lnk"
if (Test-Path $DesktopShtCtPath -ErrorAction SilentlyContinue) {
	Remove-Item -Path $DesktopShtCtPath -Force -Verbose
}
#Configure default settings

$masterPref = "C:\Program Files\Google\Chrome\Application\initial_preferences"
if (!(Test-Path $masterPref)) { New-Item $masterPref -ItemType File -Force }
$masterPrefJson = @"
{
	"sync_promo": {
		"show_on_first_run_allowed": false
	},
	"distribution": {
		"skip_first_run_ui": true,
		"show_welcome_page": false,
		"import_search_engine": false,
		"import_history": false,
		"suppress_first_run_bubble": true,
		"do_not_create_any_shortcuts": true,
		"do_not_create_taskbar_shortcut": true,
		"do_not_create_desktop_shortcut": true,
		"do_not_create_quick_launch_shortcut": true,
		"create_all_shortcuts": false,
		"do_not_launch_chrome": true,
		"make_chrome_default": false,
		"suppress_first_run_default_browser_prompt": true,
		"system_level": true
	}
}
"@
<# $masterPrefJson = Get-Content $masterPref -Raw | ConvertFrom-Json
$masterPrefJson.distribution | Add-Member -MemberType NoteProperty -Name "do_not_create_desktop_shortcut" -Value 'True'
$masterPrefJson.distribution | Add-Member -MemberType NoteProperty -Name "do_not_create_any_shortcuts" -Value 'True'
$masterPrefJson.distribution | Add-Member -MemberType NoteProperty -Name "show_welcome_page" -Value 'false'
$masterPrefJson.distribution | Add-Member -MemberType NoteProperty -Name "do_not_create_taskbar_shortcut" -Value 'true' #>
$masterPrefJson | Out-File $masterPref -force -Encoding ascii
$masterPrefJson | Out-File "C:\Program Files\Google\Chrome\Application\master_preferences" -force -Encoding ascii

#Disable Auto Updates
$RegPath = "HKLM:\Software\Policies\Google\Update"
If (!(Test-Path $RegPath -ErrorAction SilentlyContinue)) {
	New-Item -Path $RegPath -Force
}



Write-Host 'AIB Customization Exit code: ' $LASTEXITCODE
if ($error[0]) {
	Write-Host 'AIB Customization Error Message: ' $error[0]
}
#Cleanup installers
Remove-Item "$Path" -Force -Recurse -Verbose
