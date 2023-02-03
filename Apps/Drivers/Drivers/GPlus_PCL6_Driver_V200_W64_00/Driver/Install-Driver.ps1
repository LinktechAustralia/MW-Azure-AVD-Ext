if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64")
{
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe")
    {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}
Start-Transcript $env:TEMP\Install-CanonGeneric.log
$INF = Join-Path $PSScriptRoot Cnp60MA64.INF
"Adding driver from $($INF)" | Write-Host -ForegroundColor Cyan -Verbose
Start-Process pnputil.exe -ArgumentList "/add-driver `"$($INF)`" /install" -Wait -NoNewWindow -PassThru -Verbose

Add-PrinterDriver -Name "Canon Generic Plus PCL6" -Verbose

# Create a tag file just so Intune knows this was installed
if (-not (Test-Path "$($env:ProgramData)\PDH"))
{
    Mkdir "$($env:ProgramData)\PDH"
}
Set-Content -Path "$($env:ProgramData)\PDH\Install-Driver-Canon-v2.0.0.tag" -Value "Installed"
Stop-Transcript