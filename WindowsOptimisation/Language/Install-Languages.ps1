<# 
.SYNOPSIS
Script to install the necessary language packs
.DESCRIPTION
View a list of all language packs at https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows?view=windows-11
$R
#>


Import-Module Languagepackmanagement

$RequiredLanguages = @('en-AU')
$DefaultLanguage = 'en-AU'

foreach ($ReqLang in $RequiredLanguages)
	{
		if (!(Get-Language -Language $ReqLang)) {
			Install-Language -Language $ReqLang -CopyToSettings -Verbose

		} else {
			"$($ReqLang) is installed"
		}
	}

Set-SystemPreferredUILanguage -Language $DefaultLanguage -PassThru -Verbose