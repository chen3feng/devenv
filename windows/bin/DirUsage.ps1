param (
    [string]$Path = (Get-Location),
    [Alias("s")]
    [switch]$Summary,
    [Alias("h")] [switch]$HumanReadable,
    [switch]$Help
)

if ($Help) {
    # Display help information
    Write-Output "Usage: du [-s|--summary] [-h|--human-readable] [--inodes] [--help] [directory]"
    Write-Output "Options:"
    Write-Output "  -s, --summary         Display only the total size."
    Write-Output "  -h, --human-readable  Display sizes in human-readable format (e.g., 1K 234M 2G)."
    Write-Output "      --help            Display this help message and exit."
    exit 0
}

# Convert relative path to absolute path
$Path = Convert-Path $Path

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "Invalid directory path: $Path"
    exit 1
}

function Format-Size {
    param (
        [long]$Size
    )

    if ($HumanReadable) {
        # Format the size in human-readable format
        $Units = "B", "KB", "MB", "GB", "TB"
        $UnitIndex = 0
        while ($Size -ge 1KB -and $UnitIndex -lt 4) {
            $Size /= 1KB
            $UnitIndex++
        }
        [string]::Format("{0:F1}{1}", $Size, $Units[$UnitIndex])
    } else {
        # Format the size in bytes (default)
        [string]::Format("{0:F0}", $Size/1KB)
    }
}

Get-ChildItem -Directory -Path $Path | ForEach-Object {
    $subdir = $_
    $subdirSize = (Get-ChildItem -Recurse -File -Path $subdir.FullName | Measure-Object -Property Length -Sum).Sum
    $formattedSize = Format-Size $subdirSize
    Write-Output "$formattedSize`t$($subdir.FullName)"
}
