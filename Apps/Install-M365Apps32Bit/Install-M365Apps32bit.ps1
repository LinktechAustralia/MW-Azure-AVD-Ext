<# 
.SYNOPSIS
Install Google Chrome on an image created with  Azure Image Builder 
.DESCRIPTION

#>
Function LogDate {"$(Get-date -fo s)" + "`t"}
$AppName = 'M365 Apps for Enterprise 32 Bit'
$EverGreenAppName = ''

Start-Transcript $(Join-Path $env:TEMP Install-$($AppName).log)
Write-Host 'AIB Customization: M365 Apps for Enterprise (32bit)'
$Path = "$env:SystemDrive\Apps\$($AppName)"
if (!(Test-Path $Path -ErrorAction SilentlyContinue))
    {
        MD "$Path" -Force
    }


<# 
# Evergreen Needed (https://github.com/aaronparker/evergreen)
If (!(Get-Module -Name Evergreen -ListAvailable -ErrorAction SilentlyContinue))
    {
        Install-Module -Name Evergreen -scope AllUsers -Force
    }
Import-Module Evergreen
 #>
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


"$(logdate)Extract"
$ODTExtract = saps "$Destination" -args "/quiet /Extract:`"$($Path)`"" -Wait -PassThru
$SetupFullFileName = Join-path "$Path" setup.exe




$ConfigurationXML = @'
<Configuration >
  <Add OfficeClientEdition="32" Channel="MonthlyEnterprise" MigrateArch="TRUE">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchOS" />
      <Language ID="MatchPreviousMSI" />
      <ExcludeApp ID="Groove" />
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


