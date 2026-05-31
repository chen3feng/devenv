# Make the current user's PowerShell profile load the devenv helpers
# (prompt, path_manager, ...). Run once per PowerShell flavour (Windows
# PowerShell 5.1 and/or PowerShell 7), because each uses a different $PROFILE
# path. Every change is idempotent.

$profilePath = $PROFILE.CurrentUserCurrentHost
$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Source every *.ps1 in this folder except the installer itself.
$scripts = Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 |
    Where-Object { $_.Name -ne 'install.ps1' } |
    Sort-Object Name

foreach ($script in $scripts) {
    $existing = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { '' }
    if ($existing -match [regex]::Escape($script.FullName)) {
        Write-Host "Already installed: $($script.Name)"
    } else {
        Add-Content -Path $profilePath -Value "`n# devenv: $($script.BaseName)`n. '$($script.FullName)'"
        Write-Host "Added $($script.Name) to $profilePath"
    }
}
