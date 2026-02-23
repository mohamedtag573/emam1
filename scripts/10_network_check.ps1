Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Network Check                         ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
$ip  = (Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway} | Select-Object -First 1).IPv4Address.IPAddress
$gw  = (Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway} | Select-Object -First 1).IPv4DefaultGateway.NextHop
$dns = (Get-DnsClientServerAddress -AddressFamily IPv4 | Select-Object -First 1).ServerAddresses

Write-Host "   IP      : $ip" -ForegroundColor White
Write-Host "   Gateway : $gw" -ForegroundColor White
Write-Host "   DNS     : $dns" -ForegroundColor White
Write-Host ""
Write-Host "   [~] Testing internet connection..." -ForegroundColor Yellow
$ping = Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet
if ($ping) {
    Write-Host "   [OK] Internet is working." -ForegroundColor Green
} else {
    Write-Host "   [!] No internet connection!" -ForegroundColor Red
}
Write-Host ""
Write-Host "   [~] Speed test via ping..." -ForegroundColor Yellow
$result = Test-Connection -ComputerName google.com -Count 4
$avg = ($result | Measure-Object ResponseTime -Average).Average
Write-Host "   Avg Ping : $([math]::Round($avg)) ms" -ForegroundColor White
Write-Host ""
Pause
