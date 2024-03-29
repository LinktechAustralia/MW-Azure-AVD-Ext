<#
.SYNOPSIS
This script allows you to reset all autostart settings to the default settings for Teams.
.DESCRIPTION
If you want to use the "Prevent Microsoft Teams from starting automatically after installation"
Group Policy setting, make sure you first set the Group Policy setting to the value you want 
before you run this script.
#>

$ErrorActionPreference = "Stop"

$TeamsDesktopConfigJsonPath = "$($env:USERPROFILE)\AppData\Roaming\Microsoft\Teams\desktop-config.json"

$TeamsUpdatePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams', 'Update.exe')

Function Test-RegistryValue {
	param(
		[Alias("PSPath")]
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[String]$Path
		,
		[Parameter(Position = 1, Mandatory = $true)]
		[String]$Name
	) 

	process {
		if (Test-Path $Path) {
			$Key = Get-Item -LiteralPath $Path
			if ($null -ne $Key.GetValue($Name, $null)) {
				$true
			}
			else {
				$false
			}
		}
		else {
			$false
		}
	}
}

Function Test-Remove-RegistryValue {
	param (
		[Alias("PSPath")]
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[String]$Path
		,
		[Parameter(Position = 1, Mandatory = $true)]
		[String]$Name
	)

	process {
		if (Test-RegistryValue -Path $Path -Name $Name) {
			Write-Host "Removing registry key $Path\$Name"
			Remove-ItemProperty -Path $Path -Name $Name
		}
	}
}

Function CloseTeams {

	$teamsProc = Get-Process -name Teams -ErrorAction SilentlyContinue
	if ($null -ne $teamsProc) {
		Write-Host  "Stopping Microsoft Teams..."
		Stop-Process -Name Teams -Force
		# wait some time
		Start-Sleep 5
	}
 else {
		Write-Host  "No running Teams process found"
	}
	
	
	# 1. Check that Teams process isn't still running
	$teamsProc = Get-Process -name Teams -ErrorAction SilentlyContinue 
}

# when determining whether Teams should be auto-started we are checking three flags
Write-Host "Removing Auto-Start-related artifacts"

# 0. Close Teams, if running


# 2. remove HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\LoggedInOnce registry key
If (Test-RegistryValue -Path "HKCU:\Software\Microsoft\Office\Teams" -Name "LoggedInOnce") {
	CloseTeams
	Test-Remove-RegistryValue -Path "HKCU:\Software\Microsoft\Office\Teams" -Name "LoggedInOnce"
}
# 3. remove HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\HomeUserUpn registry key
If (Test-RegistryValue -Path "HKCU:\Software\Microsoft\Office\Teams" -Name "HomeUserUpn") {
	CloseTeams
	Test-Remove-RegistryValue -Path "HKCU:\Software\Microsoft\Office\Teams" -Name "HomeUserUpn"
}

# 4. remove HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\DeadEnd registry key
If (Test-RegistryValue -Path "HKCU:\Software\Microsoft\Office\Teams" -Name "DeadEnd") {
	CloseTeams
	Test-Remove-RegistryValue -Path "HKCU:\Software\Microsoft\Office\Teams" -Name "DeadEnd"
}
# 5. remove HKCU:\Software\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect registry key
Remove-Item -Path "HKCU:\Software\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect" -ErrorAction SilentlyContinue

# 6. restore HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run\com.squirrel.Teams.Teams
if (!(Test-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams")) {
	CloseTeams

	Write-Host "Restoring registry key HKCU\Software\Microsoft\Windows\CurrentVersion\Run\com.squirrel.Teams.Teams"
	Test-Remove-RegistryValue  -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "com.squirrel.Teams.Teams" 
}

# 7. We are checking whether there are entries 'isLoggedOut' and 'openAtLogin' in the desktop-config.json file
if (Test-Path -Path $TeamsDesktopConfigJsonPath) {
	Write-Host "Changing entries 'guestTenantId', 'isLoggedOut' and 'openAtLogin' in the desktop-config.json, if exist"
	CloseTeams
	# open desktop-config.json file
	$desktopConfigFile = Get-Content -path $TeamsDesktopConfigJsonPath -Raw | ConvertFrom-Json
	$desktopConfigFile.PSObject.Properties.Remove("guestTenantId")
	$desktopConfigFile.PSObject.Properties.Remove("isLoggedOut")
	try {
		$desktopConfigFile.appPreferenceSettings.openAtLogin = $false
		$desktopConfigFile.appPreferenceSettings.openAsHidden = $true
	}
	catch {
		Write-Host  "openAtLogin JSON element doesn't exist"
	}
	$desktopConfigFile | ConvertTo-Json -Compress | Set-Content -Path $TeamsDesktopConfigJsonPath -Force
}

