# Make the current user's PowerShell profile load the devenv git prompt.
# Run once per PowerShell flavour (Windows PowerShell 5.1 and/or PowerShell 7),
# because each one uses a different $PROFILE path. The change is idempotent.

$promptScript = Join-Path $PSScriptRoot 'prompt.ps1'
$sourceLine = ". '$promptScript'"

$profilePath = $PROFILE.CurrentUserCurrentHost
$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$existing = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { '' }
if ($existing -match [regex]::Escape($promptScript)) {
    Write-Host "devenv prompt already installed in $profilePath"
} else {
    Add-Content -Path $profilePath -Value "`n# devenv: git-aware prompt`n$sourceLine"
    Write-Host "Added devenv prompt to $profilePath"
}
