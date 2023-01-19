<# 
.SYNOPSIS
Install Advanced installer 
.DESCRIPTION
The script invokes a download of the latest Advanced Installer installer & installs 


#>
Function LogDate {"$(Get-date -fo s)" + "`t"}
$AppName = 'Advanced Installer'

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host "AIB Customization: $($Appname)"
$Path = "$env:SystemDrive\Apps\$($AppName)"
if (!(Test-Path $Path -ErrorAction SilentlyContinue)) #Create the folder if it does not exist
    {
        MD "$Path" -Force
    }

#Download latest ODT installer
function Download-Installer 
    {
		$DownloadLink = 'https://www.advancedinstaller.com/downloads/advinst.msi'
        $DownloadFileName = $([System.IO.Path]::GetFileName($DownloadLink.ToString()))
        $Global:Destination = Join-path "$Path" $DownloadFileName
        Invoke-WebRequest -Uri $DownloadLink -OutFile $Destination
    }

Download-Installer


	saps msiexec -Args "/i `"$Destination`" /qb" -NoNewWindow -Wait