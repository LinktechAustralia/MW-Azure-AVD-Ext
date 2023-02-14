<# 
.SYNOPSIS
Script to install the necessary language packs
.DESCRIPTION
	View a list of all language packs at https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows?view=windows-11

	To set the $Winhomelocation
	https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations

	20230211
	An Issue with Windows 10 Multisession detected where the RunOnce was not running as expected but instead runnning nearly 30 minutes later. To overcome, a Scheduled task is created to run immediately on user logon.


.NOTES
	Version		:	2.0
	Modified 	:	20230211
	Created by	:	Linktech Australia
	Author		:	Leroy DSouza

#>

$RequiredLanguages = @('en-AU', 'pt-BR')
$DefaultLanguage = 'en-AU'
$WinhomeLocation = 12
$CompanyShortCode = 'LTA'


#END OF PARAMETERS
Start-Transcript "C:\Windows\Logs\Install-LanguageOptions.log"

function LogDateTime {
	$(Get-Date -Format s) + "`t"
	
}
"$(LogDateTime)AIB Customisation: Language Installer: Importing Module"
Import-Module Languagepackmanagement -Verbose -ErrorAction SilentlyContinue
$Path = Join-Path "C:\Apps" "LanguagePacks"
mkdir $($Path)

##Disable Language Pack Cleanup##
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\AppxDeploymentClient\" -TaskName "Pre-staged app cleanup"

$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Control Panel\International"
if (!(Test-Path $RegPath -ErrorAction SilentlyContinue)) {
	New-Item $RegPath -Force
}
New-ItemProperty -Path $RegPath -Name BlockCleanupOfUnusedPreinstalledLangPacks -PropertyType DWORD -Value 1 -Force

<# 
foreach ($ReqLang in $RequiredLanguages)
	{
		"Language Installer: Checking for $($ReqLang)"
		if (!(Get-Language -Language $ReqLang)) {
			"Language Installer: $($ReqLang) is not installed. Installing.."
			Install-Language -Language $ReqLang -CopyToSettings -Verbose

		} else {
			"Language Installer: $($ReqLang) is installed"
		}
	}

Set-SystemPreferredUILanguage -Language $DefaultLanguage -PassThru -Verbose
Set-WinSystemLocale -SystemLocale $DefaultLanguage


#Cleaning Up
Write-Host "Language Installer: Cleaning up Languages"
$InstalledLanguages = get-language 
foreach ($InstalledLang in $InstalledLanguages){
	"Checking $($InstalledLang.LanguageId)"
	if ($($InstalledLang.LanguageId) -notin $RequiredLanguages) {
		"Cleaning $($InstalledLang.LanguageId)" 
		Uninstall-Language $($InstalledLang.LanguageId) -PassThru
	}
}

 #>

 $FilesLists = @{
	'en-AU' = @{
		Name            = "en-AU"
		Files           = @(
			"Microsoft-Windows-LanguageFeatures-Basic-en-gb-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-LanguageFeatures-Basic-en-au-Package~31bf3856ad364e35~amd64~~.cab"
			"Microsoft-Windows-LanguageFeatures-Handwriting-en-gb-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-LanguageFeatures-OCR-en-gb-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-LanguageFeatures-Speech-en-gb-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-LanguageFeatures-Speech-en-au-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-LanguageFeatures-TextToSpeech-en-gb-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-LanguageFeatures-TextToSpeech-en-au-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~en-gb~.cab",
			"Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~en-gb~.cab",
			"Microsoft-Windows-MSPaint-FoD-Package~31bf3856ad364e35~amd64~en-gb~.cab",
			"Microsoft-Windows-Notepad-FoD-Package~31bf3856ad364e35~amd64~en-gb~.cab",
			"Microsoft-Windows-PowerShell-ISE-FOD-Package~31bf3856ad364e35~amd64~en-gb~.cab",
			"Microsoft-Windows-Printing-WFS-FoD-Package~31bf3856ad364e35~amd64~en-gb~.cab",
			"Microsoft-Windows-StepsRecorder-Package~31bf3856ad364e35~amd64~en-gb~.cab",
			"Microsoft-Windows-WordPad-FoD-Package~31bf3856ad364e35~amd64~en-gb~.cab"
		)
		LXP             = 'LanguageExperiencePack.en-GB.Neutral.appx'
		LanguagePackCab = "Microsoft-Windows-Client-Language-Pack_x64_en-gb.cab"
	}
	'pt-BR' = @{
		Name            = "pt-BR"
		Files           = @(
			"Microsoft-Windows-LanguageFeatures-Basic-pt-br-Package~31bf3856ad364e35~amd64~~.cab", 
			"Microsoft-Windows-LanguageFeatures-Handwriting-pt-br-Package~31bf3856ad364e35~amd64~~.cab", 
			"Microsoft-Windows-LanguageFeatures-OCR-pt-br-Package~31bf3856ad364e35~amd64~~.cab", 
			"Microsoft-Windows-LanguageFeatures-Speech-pt-br-Package~31bf3856ad364e35~amd64~~.cab", 
			"Microsoft-Windows-LanguageFeatures-TextToSpeech-pt-br-Package~31bf3856ad364e35~amd64~~.cab", 
			"Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~pt-BR~.cab", 
			"Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~pt-BR~.cab", 
			"Microsoft-Windows-MSPaint-FoD-Package~31bf3856ad364e35~amd64~pt-BR~.cab", 
			"Microsoft-Windows-Notepad-FoD-Package~31bf3856ad364e35~amd64~pt-BR~.cab", 
			"Microsoft-Windows-PowerShell-ISE-FOD-Package~31bf3856ad364e35~amd64~pt-BR~.cab",
			"Microsoft-Windows-Printing-WFS-FoD-Package~31bf3856ad364e35~amd64~pt-BR~.cab",
			"Microsoft-Windows-StepsRecorder-Package~31bf3856ad364e35~amd64~pt-BR~.cab",
			"Microsoft-Windows-WordPad-FoD-Package~31bf3856ad364e35~amd64~pt-BR~.cab"
		)
		LXP             = "LanguageExperiencePack.pt-BR.Neutral.appx"		
		LanguagePackCab = "Microsoft-Windows-Client-Language-Pack_x64_pt-br.cab"
	}

}

#Download & Mount the Language ISOs

$URI = "https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_CLIENTLANGPACKDVD_OEM_MULTI.iso"
$OutFileLang = Join-Path $Path Language.iso
Write-Host "$(LogDateTime)Commence Download of $($OutFileLang)"

Start-BitsTransfer -Source $URI -Destination $OutFileLang -Verbose


##Set Language Pack Content Stores##

$Drive = (Mount-DiskImage -ImagePath "$($OutFileLang)" -PassThru -StorageType ISO | Get-Volume).driveletter
[string]$LIPContent = "$($Drive):"

$URI = "https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso"
$OutFileFOD = Join-Path $Path FODDISK1.iso
Write-Host "$(LogDateTime)Commence Download of $($OutFileFOD)"
Start-BitsTransfer -Source $URI -Destination $OutFileFOD

"$(LogDateTime)Mounting $($OutFileFOD)" | Write-Host
$Drive = (Mount-DiskImage -ImagePath "$($OutFileFOD)" -PassThru -StorageType ISO | Get-Volume).driveletter
[string]$FODContent = "$($Drive):"


foreach ($RequiredLanguage in $RequiredLanguages) {
	"$(LogDateTime)Commencing install of $($RequiredLanguage) components"
	#Install the LXPs
	"$(LogDateTime)Installing LXPs"
	$LXPFiles = $FilesLists."$($RequiredLanguage)".LXP
	foreach ($LXPFile in $LXPFiles) {
			
		$LXPFullFileName = (dir $LIPContent -Filter $($LXPFile) -Recurse).fullname

		if ($LXPFullFileName) {
			"$(LogDateTime)Found $($LXPFullFileName). Installing.."
			Add-AppProvisionedPackage -Online -PackagePath $LXPFullFileName -LicensePath $(Join-Path $(Split-path $LXPFullFileName) License.xml)
		} 
		Else {
			"$(LogDateTime)Couldn't find $($LXPFile)"
		}
	}
	
	#Install the Language Pack Cab
	$LanguagePackCabFiles = $FilesLists."$($RequiredLanguage)".LanguagePackCab
	foreach ($LanguagePackCabFile in $LanguagePackCabFiles) {
		$LanguagePackCabFullFileName = (dir $LIPContent -Filter $($LanguagePackCabFile) -Recurse).fullname

		if ($LanguagePackCabFullFileName) {
			Add-WindowsPackage -Online -PackagePath $LanguagePackCabFullFileName -Verbose
		}
		Else {
			"$(LogDateTime)Couldn't find $($LanguagePackCabFullFileName)"
		}

	}

	# Install the FODs
	$FODFiles = $FilesLists."$($RequiredLanguage)".Files
	foreach ($FODFile in $FODFiles) {
		$FODFullFileName = (dir $FODContent -Filter $($FODFile) -Recurse).fullname

		if ($FODFullFileName) {
			Add-WindowsPackage -Online -PackagePath "$($FODFullFileName)" -Verbose

		}
		else {
			"$(LogDateTime)Couldn't find $($FODFullFileName)"
		}

	}


}
#>


$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("en-au")
Set-WinUserLanguageList $LanguageList -force

#Clear US Language
$LanguageList = Get-WinUserLanguageList
$LanguageList.Remove("en-US")
Set-WinUserLanguageList $LanguageList -force


<#  
 $URI = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66750/LanguageExperiencePack.2206C.iso"

 $URI = "https://software-download.microsoft.com/download/sg/19041.928.210407-2138.vb_release_svc_prod1_amd64fre_InboxApps.iso"
 $OutFile = Join-Path $Path InboxApps.iso

 $Drive = (Mount-DiskImage -ImagePath "C:\Apps\LanguagePacks\Language.iso" -PassThru -StorageType ISO | Get-Volume).driveletter

 [string]$LIPContent = "$($Drive):" #>


Set-SystemPreferredUILanguage -Language $DefaultLanguage -PassThru -Verbose
Set-WinSystemLocale -SystemLocale $DefaultLanguage
Set-WinHomeLocation -GeoId $WinhomeLocation -Verbose
Set-WinUserLanguageList en-AU -Force

$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\MUI\Settings"
New-item -Path $RegPath -Force
New-ItemProperty -Path $RegPath -Name PreferredUILanguages -PropertyType string -Value $DefaultLanguage

$ReqLangtoString = "@(" + $(($RequiredLanguages | % { "`"$_`"" } ) -join ',') + ")"
$SCRIPT = "Start-transcript `$env:temp\Set-Langs-AVD.log  ; Write-host `"Configuring the AVD language settings for `$env:username`" ; `$RegPath = `"HKCU:\SOFTWARE\KEG\LangSettings`" ; if (Test-Path `$RegPath -ErrorAction SilentlyContinue) {`"Script has run`"} Else {Set-Winuserlanguagelist $($ReqLangtoString) -force -verbose ; Set-WinHomeLocation -GeoId $($WinhomeLocation) ; Set-WinSystemLocale -SystemLocale $($DefaultLanguage) ; Set-Culture $($DefaultLanguage) ; New-Item `$RegPath -Force ; Set-ItemProperty -Path `$RegPath -Name LastRun -Value `$(Get-date -fo s) ;}"
$OutScriptFile = Join-Path $env:ProgramFiles Set-Langs.ps1

"$(LogDateTime)Generating Script to $($OutScriptFile) " | Write-Host
$SCRIPT | Out-File $OutScriptFile -Force

Write-Host "$(LogDateTime)`tSetting the default user profile"
reg.exe load HKLM\TempUser "C:\Users\Default\NTUSER.DAT" | Out-Host
reg.exe add "HKLM\TempUser\Control Panel\International\User Profile" /v Languages /t REG_MULTI_SZ /d "$($RequiredLanguages -join ' ')" /f | Out-Host

$RegPath = "HKLM\TempUser\Software\Microsoft\Windows\CurrentVersion\RunOnce"
#reg.exe add "$($RegPath)" /v SetLang01 /t reg_SZ /d 'powershell.exe -ex bypass -WindowStyle hidden -File \"C:\Program Files\Set-Langs.ps1\"' /f
reg.exe unload HKLM\TempUser | Out-Host

     
	
#Create the scheduled task action
$STTaskname = "Set-Language"
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument " -ExecutionPolicy bypass -WindowStyle Hidden -File `"$OutScriptFile`""

# Create the scheduled task trigger
$timespan = New-Timespan -minutes 5
$triggers = @()
$triggers += New-ScheduledTaskTrigger -Once -At (Get-Date).AddYears(-2)
$triggers += New-ScheduledTaskTrigger -AtLogOn
$STPrin = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Limited 
# Register the scheduled task
Register-ScheduledTask -Action $action -Trigger $triggers -TaskName "$STTaskname" -Description "Sets the default language for the user" -Principal $STPrin -Force
$STSettings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
Set-ScheduledTask -TaskName $STTaskname -Settings $STSettings

Write-Host "$(LogDateTime)Scheduled task created."

#Cleaning Folder
Dismount-DiskImage -ImagePath $OutFileLang -Verbose
Dismount-DiskImage -ImagePath $OutFileFOD -Verbose

Set-Location $env:windir
Remove-Item	  $Path -Force -Recurse -ErrorAction SilentlyContinue
