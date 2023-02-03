if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64")
{
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe")
    {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

$InfFileName = 'eSmf66.INF'
$PrinterDriverName = 'TOSHIBA e-STUDIO Fax'
Start-Transcript "$(Join-Path $env:TEMP $($PrinterDriverName + "-install.log"))"
$InfFileFullName = Join-Path $PSScriptRoot $InfFileName
"Installing from $($InfFileFullName)"
$INFPROC = Start-Process "C:\Windows\System32\pnputil.exe" -ArgumentList "/add-driver `"$InfFileFullName`" /install" -Wait -Verb runas -PassThru

Add-PrinterDriver -name "$PrinterDriverName" -Verbose