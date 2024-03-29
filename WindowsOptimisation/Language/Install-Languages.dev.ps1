<# 
.SYNOPSIS
Script to install the necessary language packs
.DESCRIPTION
View a list of all language packs at https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows?view=windows-11

To set the $Winhomelocation
https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations

#>

$RequiredLanguages = @('en-AU','pt-BR','en-GB')
$DefaultLanguage = 'en-AU'
$WinhomeLocation = 12


#END OF PARAMETERS
Start-Transcript "C:\Windows\Logs\Install-LanguageOptions.log"

function LogDateTime {
	$(Get-Date -Format s) + "`t"
	
}
"Language Installer: Importing Module"
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


foreach ($ReqLang in $RequiredLanguages)
	{
		"Language Installer: Checking for $($ReqLang)"
		if (!(Get-Language -Language $ReqLang)) {
			"Language Installer: $($ReqLang) is not installed. Installing.."

				if ($ReqLand -eq $DefaultLanguage) {
				Install-Language -Language $ReqLang -CopyToSettings -Verbose
			} Else {
				Install-Language -Language $ReqLang -Verbose
			}
		} else {
			"Language Installer: $($ReqLang) is installed"
		}
	}

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
			"Microsoft-Windows-LanguageFeatures-Handwriting-en-gb-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-LanguageFeatures-OCR-en-gb-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-LanguageFeatures-Speech-en-gb-Package~31bf3856ad364e35~amd64~~.cab",
			"Microsoft-Windows-LanguageFeatures-TextToSpeech-en-gb-Package~31bf3856ad364e35~amd64~~.cab",
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
<# 
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

"Mounting $($OutFileFOD)" | Write-Host
$Drive = (Mount-DiskImage -ImagePath "$($OutFileFOD)" -PassThru -StorageType ISO | Get-Volume).driveletter
[string]$FODContent = "$($Drive):"


foreach ($RequiredLanguage in $RequiredLanguages) {
	"Commencing install of $($RequiredLanguage) components"
	#Install the LXPs
	"Installing LXPs"
	$LXPFiles = $FilesLists."$($RequiredLanguage)".LXP
	foreach ($LXPFile in $LXPFiles) {
			
		$LXPFullFileName = (dir $LIPContent -Filter $($LXPFile) -Recurse).fullname

		if ($LXPFullFileName) {
			"Found $($LXPFullFileName). Installing.."
			Add-AppProvisionedPackage -Online -PackagePath $LXPFullFileName -LicensePath $(Join-Path $(Split-path $LXPFullFileName) License.xml)
		} 
		Else {
			"Couldn't find $($LXPFile)"
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
			"Couldn't find $($LanguagePackCabFullFileName)"
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
			"Couldn't find $($FODFullFileName)"
		}

	}


}
#>
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

$SCRIPT = " `$RequiredLanguages = $($RequiredLanguages)
Set-Winuserlanguagelist $($DefaultLanguage) -force ;
Set-WinHomeLocation -GeoId $($WinhomeLocation) 
Set-WinSystemLocale -SystemLocale $($DefaultLanguage)
Set-Culture $($DefaultLanguage)"
$OutScriptFile = Join-Path $env:ProgramFiles Set-Langs.ps1

"Generating Script " | Write-Host
$SCRIPT | Out-File $OutScriptFile -Force


$RegenAU = @"
Windows Registry Editor Version 5.00


[HKEY_LOCAL_MACHINE\tempuser\Control Panel\International]
"Locale"="00000C09"
"LocaleName"="en-AU"
"s1159"="AM"
"s2359"="PM"
"sCurrency"="$"
"sDate"="/"
"sDecimal"="."
"sGrouping"="3;0"
"sLanguage"="ENA"
"sList"=","
"sLongDate"="dddd, d MMMM yyyy"
"sMonDecimalSep"="."
"sMonGrouping"="3;0"
"sMonThousandSep"=","
"sNativeDigits"="0123456789"
"sNegativeSign"="-"
"sPositiveSign"=""
"sShortDate"="d/MM/yyyy"
"sThousand"=","
"sTime"=":"
"sTimeFormat"="h:mm:ss tt"
"sShortTime"="h:mm tt"
"sYearMonth"="MMMM yyyy"
"iCalendarType"="1"
"iCountry"="61"
"iCurrDigits"="2"
"iCurrency"="0"
"iDate"="1"
"iDigits"="2"
"NumShape"="1"
"iFirstDayOfWeek"="0"
"iFirstWeekOfYear"="0"
"iLZero"="1"
"iMeasure"="0"
"iNegCurr"="1"
"iNegNumber"="1"
"iPaperSize"="9"
"iTime"="0"
"iTimePrefix"="0"
"iTLZero"="0"

[HKEY_LOCAL_MACHINE\tempuser\Control Panel\International\Geo]
"Nation"="12"
"Name"="AU"
"@



Write-Host "$(LogDateTime)`tSetting the default user profile"
reg.exe load HKLM\TempUser "C:\Users\Default\NTUSER.DAT" | Out-Host
reg.exe add "HKLM\TempUser\Control Panel\International\User Profile" /v Languages /t REG_MULTI_SZ /d "$($DefaultLanguage)" /f | Out-Host

$RegPath = "HKLM\TempUser\Software\Microsoft\Windows\CurrentVersion\RunOnce"
reg.exe add "$($RegPath)" /v SetLang01 /t reg_SZ /d 'powershell.exe -ex bypass -WindowStyle hidden -File \"C:\Program Files\Set-Langs.ps1\"' /f
reg.exe unload HKLM\TempUser | Out-Host

#Cleaning Folder
Dismount-DiskImage -ImagePath $OutFileLang -Verbose
Dismount-DiskImage -ImagePath $OutFileFOD -Verbose

Remove-Item	  $Path -Force -Recurse -ErrorAction SilentlyContinue