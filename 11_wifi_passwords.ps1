# ==============================================================
#   WiFi Passwords - Extract WiFi Passwords
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$outputFile = "C:\IT_WiFi_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   WiFi Passwords -    ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$header = "WiFi Passwords Report - $(Get-Date)`n" + ("=" * 50)
$header | Out-File $outputFile -Encoding UTF8

#  
$profiles = netsh wlan show profiles 2>&1 |
    Select-String "All User Profile" |
    ForEach-Object { $_.ToString().Split(":")[1].Trim() }

if ($profiles.Count -eq 0) {
    Write-Host "  [!]    WiFi " -ForegroundColor Red
    pause; exit
}

Write-Host "     $($profiles.Count)  WiFi" -ForegroundColor Cyan
Write-Host ""

$results = @()
foreach ($profile in $profiles) {
    try {
        $details  = netsh wlan show profile name="$profile" key=clear 2>&1 | Out-String
        $password = ""
        $auth     = ""
        $cipher   = ""

        if ($details -match "Key Content\s*:\s*(.+)")         { $password = $Matches[1].Trim() }
        if ($details -match "Authentication\s*:\s*(.+)")       { $auth     = $Matches[1].Trim() }
        if ($details -match "Cipher\s*:\s*(.+)")               { $cipher   = $Matches[1].Trim() }

        $results += [PSCustomObject]@{
            SSID     = $profile
            Password = if ($password) { $password } else { "(  / Enterprise)" }
            Auth     = $auth
            Cipher   = $cipher
        }

        if ($password) {
            Write-Host "  ✅ $profile" -ForegroundColor Green
            Write-Host "     Pass   : $password" -ForegroundColor Yellow
            Write-Host "     Auth   : $auth  |  Cipher: $cipher" -ForegroundColor Gray
        } else {
            Write-Host "  -- $profile (   / Enterprise)" -ForegroundColor DarkGray
        }
        Write-Host ""

    } catch {
        Write-Host "  [!]  : $profile" -ForegroundColor Red
    }
}

#  
$results | ForEach-Object {
    "SSID: $($_.SSID) | Password: $($_.Password) | Auth: $($_.Auth) | Cipher: $($_.Cipher)"
} | Out-File $outputFile -Append -Encoding UTF8

Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║  ✅    $($results.Count)             ║" -ForegroundColor Green
Write-Host "  ║  Report: $outputFile" -ForegroundColor Gray
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Read-Host "  Press Enter to return to menu"
