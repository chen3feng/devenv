<#
.SYNOPSIS
    Install and enable the Windows OpenSSH Server (sshd).

.DESCRIPTION
    Installs the OpenSSH.Server capability, starts sshd and sets it to start
    automatically, opens the firewall on TCP 22, and optionally makes a chosen
    shell (e.g. PowerShell 7) the default. Must be run from an elevated
    PowerShell. Use Authorize-SshKey.ps1 afterwards to allow key-based login.

.PARAMETER DefaultShell
    Full path to the shell sshd should launch, e.g.
    'C:\Program Files\PowerShell\7\pwsh.exe'. If omitted, the Windows default
    (cmd.exe) is kept.

.EXAMPLE
    .\Install-SshServer.ps1

.EXAMPLE
    .\Install-SshServer.ps1 -DefaultShell 'C:\Program Files\PowerShell\7\pwsh.exe'
#>
[CmdletBinding()]
param(
    [string] $DefaultShell
)

$principal = [Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'This script must be run from an elevated PowerShell (Run as administrator).'
}

# 1) Install the OpenSSH server feature if it is not already present.
$cap = Get-WindowsCapability -Online -Name 'OpenSSH.Server*'
if ($cap.State -ne 'Installed') {
    Write-Host "Installing $($cap.Name) ..."
    Add-WindowsCapability -Online -Name $cap.Name | Out-Null
} else {
    Write-Host 'OpenSSH.Server already installed.'
}

# 2) Start sshd now and on every boot.
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd
$svc = Get-Service sshd
Write-Host "sshd is $($svc.Status), startup $($svc.StartType)."

# 3) Allow inbound TCP 22 (the installer usually adds this; make sure).
if (-not (Get-NetFirewallRule -Name 'sshd' -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
    Write-Host 'Opened inbound TCP 22.'
} else {
    Write-Host 'Firewall rule for sshd already present.'
}

# 4) Optionally set the login shell (defaults to cmd.exe otherwise).
if ($DefaultShell) {
    if (-not (Test-Path $DefaultShell)) {
        Write-Warning "DefaultShell not found: $DefaultShell"
    }
    if (-not (Test-Path 'HKLM:\SOFTWARE\OpenSSH')) {
        New-Item -Path 'HKLM:\SOFTWARE\OpenSSH' -Force | Out-Null
    }
    New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell `
        -Value $DefaultShell -PropertyType String -Force | Out-Null
    Write-Host "Default shell set to $DefaultShell"
}

# Show the addresses a client (e.g. a Mac) can connect to.
Write-Host ''
Write-Host 'sshd ready. Connect with one of:'
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.IPAddress -notlike '169.*' } |
    ForEach-Object { Write-Host "  ssh $env:USERNAME@$($_.IPAddress)" }
Write-Host ''
Write-Host 'Then authorize a key:  .\Authorize-SshKey.ps1 ''ssh-ed25519 AAAA... user@host'''
