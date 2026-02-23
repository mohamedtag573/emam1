if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$logFile = "C:\IT_Activation_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
function Log($msg, $color="White") {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host "  $line" -ForegroundColor $color
    $line | Out-File $logFile -Append -Encoding UTF8
}
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║  ACTIVATE WINDOWS + OFFICE (KMS)                     ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Log ">>> Checking Windows License..." "Yellow"
$winLic = Get-WmiObject SoftwareLicensingProduct -EA SilentlyContinue | Where-Object { $_.Name -like "Windows*" -and $_.LicenseStatus -eq 1 }
if ($winLic) { Log "  [OK] Windows Already Activated!" "Green" }
else {
    Log "  Activating Windows..." "Red"
    $ed = (Get-WmiObject Win32_OperatingSystem).Caption
    $key = switch -Wildcard ($ed) {
        "*Pro*"        { "W269N-WFGWX-YVC9B-4J6C9-T83GX" }
        "*Home*"       { "TX9XD-98N7V-6WMQ6-BX7FG-H8Q99" }
        "*Enterprise*" { "NPPR9-FWDCX-D2C8J-H872K-2YT43" }
        default        { "W269N-WFGWX-YVC9B-4J6C9-T83GX" }
    }
    $kms = @("kms8.msguides.com","kms.digiboy.ir","kms.loli.beer")
    $done = $false
    foreach ($k in $kms) {
        Log "  Trying: $k" "Gray"
        & slmgr.vbs /ipk $key 2>&1 | Out-Null; Start-Sleep 1
        & slmgr.vbs /skms $k   2>&1 | Out-Null; Start-Sleep 1
        & slmgr.vbs /ato       2>&1 | Out-Null; Start-Sleep 3
        $chk = Get-WmiObject SoftwareLicensingProduct -EA SilentlyContinue | Where-Object { $_.Name -like "Windows*" -and $_.LicenseStatus -eq 1 }
        if ($chk) { Log "  [OK] Windows Activated!" "Green"; $done=$true; break }
    }
    if (-not $done) { Log "  [!] Failed - Check Internet" "Red" }
}

Write-Host ""
Log ">>> Checking Office License..." "Yellow"
$paths = @("${env:ProgramFiles}\Microsoft Office\Office16\OSPP.VBS","${env:ProgramFiles(x86)}\Microsoft Office\Office16\OSPP.VBS","${env:ProgramFiles}\Microsoft Office\root\Office16\OSPP.VBS")
$ospp = $null; foreach ($p in $paths) { if (Test-Path $p) { $ospp=$p; break } }
if (-not $ospp) { Log "  [--] Office not installed" "Yellow" }
else {
    $st = & cscript.exe //nologo "$ospp" /dstatus 2>&1 | Out-String
    if ($st -match "Licensed") { Log "  [OK] Office Already Activated!" "Green" }
    else {
        $keys = @("XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99","FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH")
        $kms  = @("kms8.msguides.com","kms.digiboy.ir")
        $done = $false
        foreach ($key in $keys) {
            foreach ($k in $kms) {
                & cscript.exe //nologo "$ospp" /inpkey:$key 2>&1 | Out-Null
                & cscript.exe //nologo "$ospp" /sethst:$k   2>&1 | Out-Null
                & cscript.exe //nologo "$ospp" /setprt:1688 2>&1 | Out-Null
                & cscript.exe //nologo "$ospp" /act         2>&1 | Out-Null; Start-Sleep 3
                $r = & cscript.exe //nologo "$ospp" /dstatus 2>&1 | Out-String
                if ($r -match "Licensed") { Log "  [OK] Office Activated!" "Green"; $done=$true; break }
            }
            if ($done) { break }
        }
        if (-not $done) { Log "  [!] Office activation failed" "Red" }
    }
}
Log "  Report: $logFile" "Gray"

Write-Host ""
Read-Host "  Press Enter to return to menu"
