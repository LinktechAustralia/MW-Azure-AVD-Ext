<# 
.SYNOPSIS
Install M365 Apps for Enterprise (64 bit) on an image created with  Azure Image Builder 
.DESCRIPTION
The script invokes a download of the latest Office Deplyment Toolkit.
Extracts the toolkit


#>
Function LogDate {"$(Get-date -fo s)" + "`t"}
$AppName = 'M365 Apps for Enterprise 64 Bit'

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host 'AIB Customization: M365 Apps for Enterprise (64bit)'
$Path = "$env:SystemDrive\Apps\$($AppName)"
if (!(Test-Path $Path -ErrorAction SilentlyContinue)) #Create the folder if it does not exist
    {
        MD "$Path" -Force
    }

#Download latest ODT installer
function Download-ODT 
    {
        $URI = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117'
        #$Global:ConfigFile = Join-path $PSScriptRoot Configuration.xml
        $rep = Invoke-WebRequest -Uri $URI  -MaximumRedirection 0 -UseBasicParsing
        $DownloadLink = $rep.links | ? {$_.outerHTML -like "*click here to download*"} |select -First 1 | select href
        $DownloadLink = $DownloadLink.href
        $DownloadFileName = $([System.IO.Path]::GetFileName($DownloadLink.ToString()))
        $Global:Destination = Join-path "$Path" $DownloadFileName
        Invoke-WebRequest -Uri $DownloadLink -OutFile $Destination
    }
Download-ODT


"$(logdate)Extract the ODT Installer"
write-host "AIB Customization: Extract the ODT Installer"  
$ODTExtract = saps "$Destination" -args "/quiet /Extract:`"$($Path)`"" -Wait -PassThru
$SetupFullFileName = Join-path "$Path" setup.exe

# This section contains the configuration xml that will be used in the install
"$(LogDate)Processing the configuration.xml" 
Write-Host "AIB Customization: Processing the configuration.xml"
$ConfigurationXML = @'
<Configuration >
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise" MigrateArch="TRUE">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchOS" />
      <Language ID="MatchPreviousMSI" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="OneDrive"/>
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="Teams" />
      <ExcludeApp ID="Bing" />
      <ExcludeApp ID="Bing" />
      <ExcludeApp ID="Bing" />
    </Product>
    <Product ID="VisioProRetail">
      <Language ID="MatchOS" />
      <Language ID="MatchPreviousMSI" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="OneDrive"/>
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="Teams" />
      <ExcludeApp ID="Bing" />
      <ExcludeApp ID="Bing" />
      <ExcludeApp ID="Bing" />
    </Product>
    <Product ID="ProjectProRetail">
      <Language ID="MatchOS" />
      <Language ID="MatchPreviousMSI" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="OneDrive"/>
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="Teams" />
      <ExcludeApp ID="Bing" />
      <ExcludeApp ID="Bing" />
      <ExcludeApp ID="Bing" />
    </Product>
    <Product ID="LanguagePack">
      <Language ID="MatchOS" />
      <Language ID="MatchPreviousMSI" />
      <ExcludeApp ID="Bing" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="1" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Updates Enabled="FALSE" />
  <RemoveMSI />
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
'@

$ConfigurationXMLFile = $(Join-path "$Path" configuration.xml)
$ConfigurationXML | out-file $ConfigurationXMLFile

$M365Installer = saps "$SetupFullFileName" -args "/configure `"$($ConfigurationXMLFile)`" " -NoNewWindow -PassThru -Wait
Write-Host 'AIB Customization Exit code: ' $LASTEXITCODE
Write-Host 'AIB Customization Error Message: ' $error[0]

#Cleanup installers
Remove-Item "$Path" -Force -Recurse -Verbose


