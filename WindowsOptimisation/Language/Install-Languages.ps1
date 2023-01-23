<# 
.SYNOPSIS
Script to install the necessary language packs
.DESCRIPTION
View a list of all language packs at https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows?view=windows-11
$R
#>

Start-Transcript "C:\Windows\Logs\Install-LangugeManagement.log"

"Language Installer: Importing Module"
Import-Module Languagepackmanagement -Verbose

$RequiredLanguages = @('en-AU','pt-BR')
$DefaultLanguage = 'en-AU'

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

