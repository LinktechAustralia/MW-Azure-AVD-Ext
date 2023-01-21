<# 
.SYNOPSIS
Installs Chocolatey for application packages
.NOTES
https://chocolatey.org/install
#>


$AppName = 'Chocolatey'


Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: Installing $($appName)"
Set-ExecutionPolicy Bypass -Scope Process -Force;
 [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex