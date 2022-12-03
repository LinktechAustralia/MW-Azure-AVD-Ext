#Get AZCOPY
$azcopytemp = join-path -path $env:TEMP -childpath  "azcopy_" 
$azcopyzip = join-path -path $env:TEMP -childpath  "azcopy.zip"
$URL = "https://aka.ms/downloadazcopy-v10-windows"


if ( -not (test-path -path $azcopyzip  )) {
	Write-Host "Downloading Azcopy " $azcopyzip -ForegroundColor Green
	Invoke-WebRequest -Uri $URL -OutFile $azcopyzip -erroraction 'silentlycontinue'
	Write-Host "Azcopy downloaded in "  $ImageUSB.azcopypath -ForegroundColor Green
}

Expand-Archive $azcopyzip $azcopytemp  -Force -Verbose
$azcopyexe = Get-ChildItem $azcopytemp -Include *.exe -Recurse
saps "C:\Windows\System32\Robocopy.exe" -args "$($azcopyexe.DirectoryName) $env:windir\system32 $($azcopyexe.Name)" -NoNewWindow -PassThru
