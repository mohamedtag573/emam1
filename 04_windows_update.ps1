if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$logFile = "C:\IT_Update_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
function Log($msg, $color="White") {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host "  $line" -ForegroundColor $color
    $line | Out-File $logFile -Append -Encoding UTF8
}
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║  WINDOWS AUTO UPDATE                                 ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Log ">>> Setting up PSWindowsUpdate..." "Yellow"
$usePSWU = $false
try {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -EA SilentlyContinue | Out-Null
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -EA SilentlyContinue
        Install-Module PSWindowsUpdate -Force -SkipPublisherCheck -EA SilentlyContinue | Out-Null
    }
    Import-Module PSWindowsUpdate -EA Stop
    $usePSWU = $true; Log "  [OK] Module Ready" "Green"
} catch { Log "  Using built-in API" "Yellow" }

Log ">>> Searching for updates..." "Yellow"
if ($usePSWU) {
    $upd = Get-WindowsUpdate -EA SilentlyContinue
    if ($upd -and $upd.Count -gt 0) {
        Log "  Found $($upd.Count) updates - Installing..." "Yellow"
        Install-WindowsUpdate -AcceptAll -IgnoreReboot -EA SilentlyContinue | Out-Null
        Log "  [OK] Updates installed!" "Green"
    } else { Log "  [OK] Already up to date!" "Green" }
} else {
    try {
        $ses = New-Object -ComObject Microsoft.Update.Session
        $src = $ses.CreateUpdateSearcher()
        $res = $src.Search("IsInstalled=0 and IsHidden=0 and Type='Software'")
        if ($res.Updates.Count -gt 0) {
            Log "  Found $($res.Updates.Count) updates..." "Yellow"
            $col = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($u in $res.Updates) { if (-not $u.EulaAccepted) { $u.AcceptEula() }; $col.Add($u) | Out-Null }
            $dl = $ses.CreateUpdateDownloader(); $dl.Updates=$col; $dl.Download() | Out-Null
            $inst = $ses.CreateUpdateInstaller(); $inst.Updates=$col; $inst.Install() | Out-Null
            Log "  [OK] $($res.Updates.Count) updates installed!" "Green"
        } else { Log "  [OK] Already up to date!" "Green" }
    } catch { Log "  [!] Error: $($_.Exception.Message)" "Red" }
}
Log "  Report: $logFile" "Gray"
Write-Host ""
$r = Read-Host "  Restart now? (y/n)"
if ($r -eq "y") { Restart-Computer -Force }
else { Read-Host "  Press Enter to return to menu" }
