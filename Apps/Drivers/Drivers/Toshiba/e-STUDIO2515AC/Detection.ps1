$PrinterDriverName =  'TOSHIBA Universal Printer 2'

Start-Transcript "$(Join-Path $env:TEMP $($PrinterDriverName + "-detection.log"))"
if (Get-PrinterDriver -Name $PrinterDriverName ) 
    {
        Exit 0
    }
Else 
    {
        Exit 1
    }