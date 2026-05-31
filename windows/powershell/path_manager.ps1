# Manage ';' separated path variables such as PATH and PSModulePath.
# PowerShell counterpart of shell/path_manager.
#
#   Add-PathVar C:\tools                       # append to PATH, current session
#   Add-PathVar C:\tools -Prepend              # put it in front
#   Add-PathVar C:\tools -Scope User           # persist for the user
#   Add-PathVar D:\lib -Name LIB -Scope Machine
#   Remove-PathVar C:\tools
#   Get-PathVar                                # list PATH, one entry per line

# List the entries of a path variable, one per line. The result is an array
# of strings, so it also pipes into Where-Object / Select-String etc.
function Get-PathVar {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string] $Name = 'PATH',

        [ValidateSet('Process', 'User', 'Machine')]
        [string] $Scope = 'Process'
    )

    $value = [Environment]::GetEnvironmentVariable($Name, $Scope)
    if ($value) {
        $value -split ';' | Where-Object { $_ -ne '' }
    }
}

# Compare two path entries (case-insensitive, ignoring a trailing slash).
function Test-PathVarContains {
    param([string] $Value, [string] $Path)
    if (-not $Value) { return $false }
    $target = $Path.TrimEnd('\', '/')
    foreach ($entry in ($Value -split ';')) {
        if ($entry -and $entry.TrimEnd('\', '/') -ieq $target) { return $true }
    }
    return $false
}

# Build the new value of a path variable after adding $Path (no dedup here).
function Join-PathVar {
    param([string] $Current, [string] $Path, [switch] $Prepend)
    if (-not $Current) { return $Path }
    if ($Prepend) { return "$Path;$Current" }
    return "$Current;$Path"
}

function Add-PathVar {
    [CmdletBinding()]
    param(
        # The path to add.
        [Parameter(Mandatory, Position = 0)]
        [string] $Path,

        # The path variable to change, PATH by default.
        [Parameter(Position = 1)]
        [string] $Name = 'PATH',

        # Put the path in front instead of appending.
        [switch] $Prepend,

        # Where the change applies. Process (current session) by default;
        # User / Machine persist it (Machine needs administrator rights).
        [ValidateSet('Process', 'User', 'Machine')]
        [string] $Scope = 'Process'
    )

    $current = [Environment]::GetEnvironmentVariable($Name, $Scope)

    if (Test-PathVarContains $current $Path) {
        Write-Warning "'$Path' is already in $Name ($Scope); skipped."
        return
    }

    try {
        [Environment]::SetEnvironmentVariable($Name, (Join-PathVar $current $Path -Prepend:$Prepend), $Scope)
    } catch {
        Write-Error "Failed to set $Name at $Scope scope: $($_.Exception.Message)"
        return
    }

    # A User/Machine change is invisible to the running shell; mirror it into
    # the current process so it takes effect right away too.
    if ($Scope -ne 'Process') {
        $proc = [Environment]::GetEnvironmentVariable($Name, 'Process')
        if (-not (Test-PathVarContains $proc $Path)) {
            [Environment]::SetEnvironmentVariable($Name, (Join-PathVar $proc $Path -Prepend:$Prepend), 'Process')
        }
    }
}

function Remove-PathVar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $Path,

        [Parameter(Position = 1)]
        [string] $Name = 'PATH',

        [ValidateSet('Process', 'User', 'Machine')]
        [string] $Scope = 'Process'
    )

    $target = $Path.TrimEnd('\', '/')
    foreach ($s in @($Scope, 'Process' | Select-Object -Unique)) {
        $current = [Environment]::GetEnvironmentVariable($Name, $s)
        if (-not $current) { continue }
        $kept = $current -split ';' | Where-Object { $_ -and $_.TrimEnd('\', '/') -ine $target }
        try {
            [Environment]::SetEnvironmentVariable($Name, ($kept -join ';'), $s)
        } catch {
            Write-Error "Failed to set $Name at $s scope: $($_.Exception.Message)"
        }
    }
}
