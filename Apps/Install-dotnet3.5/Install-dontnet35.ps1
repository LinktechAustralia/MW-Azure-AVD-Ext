#region Install .Net 3.5
#Test .NET
$Installed = (Get-WindowsOptionalFeature -Online -FeatureName "netfx3").State -eq 'enabled'

if (-not ($Installed))
    {
        #Enable Windows Update
        $ServiceName = "wuauserv"
        Set-Service -StartupType Manual -Name $ServiceName -PassThru | Start-Service 
        (Get-Service $ServiceName).WaitForStatus('Running')

        Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -Verbose -ErrorAction Stop
        Stop-Service -PassThru -name wuauserv | Set-Service -StartupType Manual -PassThru

    } Else { Write-Host ".NET 3.5 is installed" }
#endRegion Install .Net 3.5