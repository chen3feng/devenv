<#
.SYNOPSIS
    Authorize an SSH public key for the current Windows user, picking the
    correct authorized_keys location and ACL automatically.

.DESCRIPTION
    Windows OpenSSH reads keys differently depending on the account:
      - members of Administrators: C:\ProgramData\ssh\administrators_authorized_keys
        (must be readable only by Administrators and SYSTEM)
      - normal users:              %USERPROFILE%\.ssh\authorized_keys

    This is the way in when the account has no password, because Windows
    blocks blank-password logons over the network, so password auth can
    never succeed and key auth is the only option.

    The script detects the account type from group membership (not from
    whether the session is elevated) and installs the key idempotently.

.PARAMETER PublicKey
    The public key text, e.g. the contents of id_ed25519.pub.

.PARAMETER Path
    Read the public key from a file instead of passing it inline.

.EXAMPLE
    .\Authorize-SshKey.ps1 'ssh-ed25519 AAAA... user@mac'

.EXAMPLE
    .\Authorize-SshKey.ps1 -Path C:\Users\cf\mac.pub
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, ParameterSetName = 'Text', Position = 0)]
    [string] $PublicKey,

    [Parameter(Mandatory, ParameterSetName = 'File')]
    [string] $Path
)

if ($PSCmdlet.ParameterSetName -eq 'File') {
    $PublicKey = Get-Content -Path $Path -Raw
}
$PublicKey = $PublicKey.Trim()
if (-not $PublicKey) { throw 'The public key is empty.' }
if ($PublicKey -notmatch '^(ssh-(rsa|ed25519|dss)|ecdsa-sha2-)') {
    Write-Warning "This doesn't look like an OpenSSH public key; continuing anyway."
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

# Is the account a member of Administrators, independent of whether this
# session is elevated? A UAC-filtered token drops the group from
# $identity.Groups, so query the account membership directly instead.
function Test-AdminMember {
    $sid = ([Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
    try {
        return (Get-LocalGroupMember -Group Administrators -ErrorAction Stop).SID.Value -contains $sid
    } catch {
        # Fallback: the Administrators SID is listed (as deny-only) even
        # when un-elevated.
        return [bool]((whoami /groups) | Select-String -SimpleMatch 'S-1-5-32-544')
    }
}
$isAdminAccount = Test-AdminMember
# Whether THIS session is elevated (needed to write under ProgramData).
$isElevated = $principal.IsInRole($adminRole)

if ($isAdminAccount) {
    $authFile = Join-Path $env:ProgramData 'ssh\administrators_authorized_keys'
    if (-not $isElevated) {
        throw "'$($identity.Name)' is an administrator account, so the key must go in " +
              "$authFile. Please re-run this script from an elevated PowerShell " +
              "(Run as administrator)."
    }
} else {
    $authFile = Join-Path $env:USERPROFILE '.ssh\authorized_keys'
}

$dir = Split-Path $authFile -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

# Idempotent: only append if this exact key is not already authorized.
$existing = if (Test-Path $authFile) { Get-Content -Path $authFile } else { @() }
if ($existing -contains $PublicKey) {
    Write-Host "Key already authorized in $authFile"
} else {
    Add-Content -Path $authFile -Value $PublicKey -Encoding ascii
    Write-Host "Added key to $authFile"
}

# The admin key file must be readable only by Administrators and SYSTEM,
# otherwise sshd ignores it.
if ($isAdminAccount) {
    icacls $authFile /inheritance:r | Out-Null
    icacls $authFile /grant 'Administrators:F' 'SYSTEM:F' | Out-Null
    Write-Host 'ACL restricted to Administrators + SYSTEM.'
}

Write-Host "Done. Connect from the Mac with:  ssh $($env:USERNAME)@<this-host-ip>"
