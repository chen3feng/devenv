# Show the current git branch in the PowerShell prompt, mirroring the
# Command Prompt version (see windows/git/update-prompt.cmd).
#
#   - Green branch name : clean working tree
#   - Red branch name   : uncommitted changes
#   - Two-line layout    : the typing column stays fixed no matter how long
#                          the path or branch name is.
#
# Inside a repository only the repo-relative path is shown to keep the line
# short; elsewhere the home directory is abbreviated to ~.

function prompt {
    $cwd = $ExecutionContext.SessionState.Path.CurrentLocation.Path

    # A single git call yields both the branch and the repository root.
    $info = @(git rev-parse --abbrev-ref HEAD --show-toplevel 2>$null)
    if ($info.Count -ge 2) {
        $branch = $info[0]
        $top = $info[1] -replace '/', '\'
        $repo = Split-Path $top -Leaf
        if ($cwd.Length -gt $top.Length -and $cwd.Substring(0, $top.Length).ToLower() -eq $top.ToLower()) {
            $display = "$repo$($cwd.Substring($top.Length))"
        } else {
            $display = $repo
        }

        # Lightweight dirty check: one diff, no file enumeration.
        git diff --quiet 2>$null
        $color = if ($LASTEXITCODE -eq 0) { 'Green' } else { 'Red' }

        Write-Host $display -NoNewline -ForegroundColor DarkCyan
        Write-Host "  ($branch)" -NoNewline -ForegroundColor $color
        Write-Host ''
    } else {
        $p = $cwd
        if ($p.ToLower().StartsWith($HOME.ToLower())) { $p = '~' + $p.Substring($HOME.Length) }
        Write-Host $p -ForegroundColor DarkCyan
    }
    return '> '
}
