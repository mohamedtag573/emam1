# ==============================================================
#   Remove / Reset Password -    
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║   Password Manager -    ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

#   User
Write-Host "  User   :" -ForegroundColor Yellow
Write-Host ""
$users = Get-LocalUser | Select-Object Name, Enabled, PasswordRequired, LastLogon
$i = 1
$userList = @()
foreach ($u in $users) {
    $status  = if ($u.Enabled) { "✅ Enabled" } else { "❌ Disabled" }
    $hasPass = if ($u.PasswordRequired) { "🔒 " } else { "🔓  " }
    Write-Host "  [$i] $($u.Name.PadRight(20)) $status  $hasPass" -ForegroundColor White
    $userList += $u.Name
    $i++
}

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   :                         ║" -ForegroundColor Cyan
Write-Host "  ║  [1]   ( )       ║" -ForegroundColor White
Write-Host "  ║  [2]                       ║" -ForegroundColor White
Write-Host "  ║  [3]   Administrator     ║" -ForegroundColor White
Write-Host "  ║  [4]   IT                ║" -ForegroundColor White
Write-Host "  ║  [5]                         ║" -ForegroundColor White
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$op = Read-Host "    "

switch ($op) {

    # ============ 1:   ============
    "1" {
        Write-Host ""
        $target = Read-Host "    User (  Enter  $env:USERNAME)"
        if ($target -eq "") { $target = $env:USERNAME }

        $userExists = Get-LocalUser -Name $target -EA SilentlyContinue
        if (-not $userExists) {
            Write-Host "  [!] User Not found: $target" -ForegroundColor Red
            pause; exit
        }

        try {
            Set-LocalUser -Name $target -Password ([System.Security.SecureString]::new()) -EA Stop
            Set-LocalUser -Name $target -PasswordNeverExpires $true -EA SilentlyContinue
            Write-Host ""
            Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "  ║  ✅    : $target" -ForegroundColor Green
            Write-Host "  ║             ║" -ForegroundColor Green
            Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
        } catch {
            Write-Host "  [!] Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ============ 2:   ============
    "2" {
        Write-Host ""
        $target = Read-Host "    User ( Enter  $env:USERNAME)"
        if ($target -eq "") { $target = $env:USERNAME }

        $userExists = Get-LocalUser -Name $target -EA SilentlyContinue
        if (-not $userExists) {
            Write-Host "  [!] User Not found: $target" -ForegroundColor Red
            pause; exit
        }

        $newPass = Read-Host "   " -AsSecureString
        try {
            Set-LocalUser -Name $target -Password $newPass -EA Stop
            Set-LocalUser -Name $target -PasswordNeverExpires $true -EA SilentlyContinue
            Write-Host ""
            Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "  ║  ✅    : $target           ║" -ForegroundColor Green
            Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
        } catch {
            Write-Host "  [!] Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ============ 3:  Administrator  ============
    "3" {
        Write-Host ""
        Write-Host "  Running   Administrator ..." -ForegroundColor Yellow
        try {
            #  
            net user Administrator /active:yes 2>&1 | Out-Null
            #  
            Set-LocalUser -Name "Administrator" -Password ([System.Security.SecureString]::new()) -EA SilentlyContinue
            Set-LocalUser -Name "Administrator" -PasswordNeverExpires $true -EA SilentlyContinue

            Write-Host ""
            Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "  ║  ✅     Administrator!       ║" -ForegroundColor Green
            Write-Host "  ║  : ( -  )         ║" -ForegroundColor Yellow
            Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
        } catch {
            Write-Host "  [!] Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ============ 4:   IT  ============
    "4" {
        Write-Host ""
        $newUser = Read-Host "   User  (: ITAdmin)"
        $newPass = Read-Host "   ( Enter  )"

        try {
            if ($newPass -eq "") {
                New-LocalUser -Name $newUser -NoPassword -PasswordNeverExpires -EA Stop | Out-Null
            } else {
                $secPass = ConvertTo-SecureString $newPass -AsPlainText -Force
                New-LocalUser -Name $newUser -Password $secPass -PasswordNeverExpires -EA Stop | Out-Null
            }

            #   Administrators
            Add-LocalGroupMember -Group "Administrators" -Member $newUser -EA SilentlyContinue

            Write-Host ""
            Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "  ║  ✅    User: $newUser        ║" -ForegroundColor Green
            Write-Host "  ║  ✅     Administrators        ║" -ForegroundColor Green
            Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
        } catch {
            Write-Host "  [!] Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ============ 5:   ============
    "5" {
        Write-Host ""
        $target = Read-Host "   User  "
        try {
            Disable-LocalUser -Name $target -EA Stop
            Write-Host "  ✅  : $target" -ForegroundColor Green
        } catch {
            Write-Host "  [!] Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    default {
        Write-Host "  [!]   " -ForegroundColor Red
    }
}

Write-Host ""

Write-Host ""
Read-Host "  Press Enter to return to menu"
