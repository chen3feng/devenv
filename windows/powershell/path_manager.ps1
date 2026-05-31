# Manage ';' separated path variables such as PATH and PSModulePath.
# PowerShell counterpart of shell/path_manager.
#
#   Add-Path C:\tools                       # append to PATH, current session
#   Add-Path C:\tools -Prepend              # put it in front
#   Add-Path C:\tools -Scope User           # persist for the user
#   Add-Path D:\lib -Name LIB -Scope Machine
#   Remove-Path C:\tools
#   Get-Path                                # list PATH, one entry per line

# List the entries of a path variable, one per line. The result is an array
# of strings, so it also pipes into Where-Object / Select-String etc.
function Get-Path {
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

# Internal: does $Value already contain $Path? (case- and trailing-slash-insensitive)
function _PathContains {
    param([string] $Value, [string] $Path)
    if (-not $Value) { return $false }
    $target = $Path.TrimEnd('\', '/')
    foreach ($entry in ($Value -split ';')) {
        if ($entry -and $entry.TrimEnd('\', '/') -ieq $target) { return $true }
    }
    return $false
}

# Internal: build the new value after adding $Path (no dedup here).
function _JoinPath {
    param([string] $Current, [string] $Path, [switch] $Prepend)
    if (-not $Current) { return $Path }
    if ($Prepend) { return "$Path;$Current" }
    return "$Current;$Path"
}

function Add-Path {
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

    if (_PathContains $current $Path) {
        Write-Warning "'$Path' is already in $Name ($Scope); skipped."
        return
    }

    try {
        [Environment]::SetEnvironmentVariable($Name, (_JoinPath $current $Path -Prepend:$Prepend), $Scope)
    } catch {
        Write-Error "Failed to set $Name at $Scope scope: $($_.Exception.Message)"
        return
    }

    # A User/Machine change is invisible to the running shell; mirror it into
    # the current process so it takes effect right away too.
    if ($Scope -ne 'Process') {
        $proc = [Environment]::GetEnvironmentVariable($Name, 'Process')
        if (-not (_PathContains $proc $Path)) {
            [Environment]::SetEnvironmentVariable($Name, (_JoinPath $proc $Path -Prepend:$Prepend), 'Process')
        }
    }
}

function Remove-Path {
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
