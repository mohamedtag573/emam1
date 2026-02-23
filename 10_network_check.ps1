# ==============================================================
#   Network Check - Network Check
#   Version 3.0 | 2026
# ==============================================================

$logFile = "C:\IT_Network_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Log($msg, $color = "White") {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host "  $line" -ForegroundColor $color
    $line | Out-File $logFile -Append -Encoding UTF8
}

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   Network Check - Network Check    ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 1.  Network
Log ">>> [1]    IP..." "Yellow"
Get-NetIPConfiguration | Where-Object { $_.IPv4Address } | ForEach-Object {
    Log "    : $($_.InterfaceAlias)" "White"
    Log "  IP      : $($_.IPv4Address.IPAddress)" "Cyan"
    Log "  Gateway : $($_.IPv4DefaultGateway.NextHop)" "White"
    Log "  DNS     : $($_.DNSServer.ServerAddresses -join ' | ')" "White"
    Log "  ─────────────────────────────────" "DarkGray"
}

# 2.  Internet
Log ">>> [2]   Internet..." "Yellow"
$targets = @(
    @{ host = "8.8.8.8";       name = "Google DNS" },
    @{ host = "1.1.1.1";       name = "Cloudflare DNS" },
    @{ host = "google.com";    name = "Google" },
    @{ host = "microsoft.com"; name = "Microsoft" },
    @{ host = "youtube.com";   name = "YouTube" }
)
foreach ($t in $targets) {
    $ping = Test-Connection $t.host -Count 2 -EA SilentlyContinue
    if ($ping) {
        $avg = [math]::Round(($ping | Measure-Object ResponseTime -Average).Average)
        Log "  [OK] $($t.name) ($($t.host)) - $avg ms ✅" "Green"
    } else {
        Log "  [!]  $($t.name) ($($t.host)) -    ❌" "Red"
    }
}

# 3.  DNS
Log ">>> [3]  DNS..." "Yellow"
@("google.com","microsoft.com","amazon.com") | ForEach-Object {
    try {
        $r = Resolve-DnsName $_ -EA Stop
        Log "  [OK] $_  →  $($r[0].IPAddress) ✅" "Green"
    } catch {
        Log "  [!]  $_ - Failed DNS ❌" "Red"
    }
}

# 4.  
Log ">>> [4]   ..." "Yellow"
$ports = @(
    @{ host="8.8.8.8";   port=53;   name="DNS" },
    @{ host="google.com"; port=80;  name="HTTP" },
    @{ host="google.com"; port=443; name="HTTPS" },
    @{ host="smtp.gmail.com"; port=587; name="SMTP" }
)
foreach ($p in $ports) {
    $test = Test-NetConnection -ComputerName $p.host -Port $p.port -WA SilentlyContinue
    if ($test.TcpTestSucceeded) {
        Log "  [OK] Port $($p.port) ($($p.name))  ✅" "Green"
    } else {
        Log "  [!]  Port $($p.port) ($($p.name))  ❌" "Red"
    }
}

# 5. Public IP
Log ">>> [5]  IP ..." "Yellow"
try {
    $pubIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5)
    Log "  [OK] IP : $pubIP ✅" "Cyan"
} catch {
    Log "  [!]     IP " "Red"
}

# 6. Speed Test 
Log ">>> [6]   ..." "Yellow"
try {
    $start = Get-Date
    Invoke-WebRequest "https://speed.cloudflare.com/__down?bytes=1000000" -OutFile "$env:TEMP\speedtest.tmp" -UseBasicParsing -TimeoutSec 15 | Out-Null
    $elapsed = ((Get-Date) - $start).TotalSeconds
    $speedMbps = [math]::Round((1 / $elapsed) * 8, 1)
    Remove-Item "$env:TEMP\speedtest.tmp" -EA SilentlyContinue
    Log "  [OK]   : $speedMbps Mbps ✅" "Cyan"
} catch {
    Log "  [--]   Not available" "Gray"
}

# 7.    Network 
Log ">>> [7]    Network ..." "Yellow"
$gw = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1).IPv4DefaultGateway.NextHop
if ($gw) {
    $subnet = $gw -replace '\.\d+$', ''
    Log "   Network: $subnet.1 - $subnet.254" "Gray"
    $active = [System.Collections.ArrayList]@()
    1..254 | ForEach-Object {
        $ip = "$subnet.$_"
        $ping = Test-Connection $ip -Count 1 -TimeoutSeconds 1 -EA SilentlyContinue
        if ($ping) {
            $hn = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { "Unknown" }
            Log "  [ON] $ip  -  $hn" "Green"
            $active.Add($ip) | Out-Null
        }
    }
    Log "    : $($active.Count)" "Cyan"
}

Log "`n  ╔══════════════════════════════════════════╗" "Cyan"
Log "  ║  ✅  Report: $logFile" "Green"
Log "  ╚══════════════════════════════════════════╝" "Cyan"

Write-Host ""
Read-Host "  Press Enter to return to menu"
