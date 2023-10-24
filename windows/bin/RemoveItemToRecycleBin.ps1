# This script implements the POSIX rm command, with additional recycle bin support.

function Show-Help {
    param (
        [string]$Prog,
        [array]$OptionSet,
        [string]$Desc,
        [string]$Epilog
    )

    Write-Host "Usage: $Prog [options]... [files]...`n$Desc`n"

    foreach ($option in $OptionSet) {
        if ($name -match "^-") {
            continue
        }
        $name = $option.Name
        $alias = $option.Alias
        $help = $option.Help

        $optionText = if ($alias) { "-$alias, --$name" } else { "--$name" }
        Write-Host "$optionText : $help"
    }

    if ($Epilog -ne "") {
        Write-Host "`n$Epilog"
    }
}

# Parse command line arguments with case sensitivity
function Parse-CommandLine {
    param (
        [string]$Prog,
        [array]$OptionSet,
        [string[]]$Arguments,
        [string]$Desc,
        [string]$Epilog
    )

    $options = @{}
    $parsedArguments = @()

    $i = 0
    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]
        if ($arg -match '^--(.+)') {
            # Long option with a value
            $name = $Matches[1]
            $value = $true

            if ($name -match '(.+)=(.+)') {
                $name = $Matches[1]
                $value = $Matches[2]
            }
            $matchedName = $null

            # Find the option in the OptionSet
            foreach ($option in $OptionSet) {
                if ($option.Name -eq $name -or ($option.Alias -ne $null -and $option.Alias -eq $name)) {
                    $matchedName = $name
                    break
                }
            }
            if ($matchedName -ne $null) {
                $options[$matchedName] = $value
            }
            else {
                # Unknown option, report an error
                Write-Error "Unknown option: $arg"
            }
        }
        elseif ($arg -match '^-(.+)') {
            # Short option(s)
            $shortOptions = $Matches[1] -split ''

            foreach ($shortOption in $shortOptions) {
                if ($shortOption -eq "") {
                    continue
                }
                $matchedOption = $null

                # Find the option in the OptionSet
                foreach ($option in $OptionSet) {
                    if ($option.Name -eq $shortOption -or ($option.Alias -ne $null -and $option.Alias -eq $shortOption)) {
                        $matchedOption = $option
                        break
                    }
                }

                if ($matchedOption -ne $null) {
                    if ($matchedOption.Type -eq "bool") {
                        $options[$matchedOption.Name] = $true
                    }
                    else {
                        Write-Error "Short option: $arg must be bool type"
                    }
                }
                else {
                    # Unknown option, report an error
                    Write-Error "Unknown option: $shortOption"
                }
            }
        }
        else {
            # Collect arguments
            $parsedArguments += $arg
        }

        $i++
    }

    if ($options.ContainsKey("help")) {
        Show-Help -Prog $Prog -OptionSet $OptionSet -Desc $Desc -Epilog $Epilog
        exit 1
    }

    return $options, $parsedArguments
}

$optionSet = @(
    @{
        "Name"  = "help"
        "Alias" = $null
        "Type"  = "bool"
        "Help"  = "display this help and exit"
    },
    @{
        "Name"  = "version"
        "Alias" = $null
        "Type"  = "string"
        "Help"  = "output version information and exit"
    },
    @{
        "Name"  = "force"
        "Alias" = "f"
        "Type"  = "bool"
        "Help"  = "ignore nonexistent files and arguments, never prompt"
    },
    @{
        "Name"  = "interactive"
        "Alias" = "i"
        "Type"  = "bool"
        "Help"  = "prompt before every removal"
    },
    @{
        "Name"  = "recursive"
        "Alias" = "r"
        "Type"  = "bool"
        "Help"  = "remove directories and their contents recursively"
    },
    @{
        "Name"  = "directly"
        "Alias" = "D"
        "Type"  = "bool"
        "Help"  = "remove directly, don't move to recycle bin"
    },
    @{
        "Name"  = "verbose"
        "Alias" = "v"
        "Type"  = "bool"
        "Help"  = "explain what is being done"
    }
)

$Desc = "Remove (unlink) the FILE(s)."

$Epilog = @"
By default, rm does not remove directories.  Use the --recursive (-r or -R)
option to remove each listed directory, too, along with all of its contents.

To remove a file whose name starts with a '-', for example '-foo',
use one of these commands:
  rm -- -foo

  rm ./-foo
"@

$commandLineOptions, $commandLineArgs = Parse-CommandLine -Prog "rm" -Desc $Desc -Epilog $Epilog -Arguments $args -OptionSet $optionSet

Write-Debug "commandLineOptions:"
foreach ($key in $commandLineOptions.Keys) {
    $value = $commandLineOptions[$key]
    Write-Debug "$key : $value"
}

Write-Debug "commandLineArgs:"
$commandLineArgs | ForEach-Object { Write-Debug $_ }

$Direct = $commandLineOptions["directly"]
$Force = $commandLineOptions["force"]
$Interactive = $commandLineOptions["interactive"]
$Recursive = $commandLineOptions["recursive"]
$Verbose = $commandLineOptions["verbose"]

if ($commandLineArgs.Count -eq 0) {
    if (-not $Force) {
        Write-Host "rm: missing operand"
        Write-Host "Try 'rm --help' for more information."    
    }
    exit 0
}

# Define a function to prompt for confirmation if the -i option is used
function Confirm-For-Confirmation($Path) {
    if (-not $Force -and $Interactive) {
        $confirmation = Read-Host "Delete '$Path'? [Y/N]"
        if ($confirmation -ine "Y") {
            Write-Host "Skipped: $Path"
            return $false
        }
    }
    return $true
}

# Remove items to the system recycle bin
function Remove-ToRecycleBin($Path) {
    $shell = New-Object -ComObject Shell.Application

    if (Test-Path $Path) {
        $item = Get-Item $Path
        $shell.Namespace(0).ParseName($item).InvokeVerb("delete")
        if ($Verbose) {
            Write-Host "$Path is moved to recycle bin"
        }
    }
    else {
        Write-Host "$Path does not exist."
    }
}

# Loop through the provided paths
foreach ($Path in $commandLineArgs) {
    Write-Debug "Remove $Path"

    if ($Verbose) {
        Write-Host "Deleting: $Path"
    }

    if (Test-Path $Path) {
        if (-not $Recursive -and (Test-Path -Path $path -PathType Container)) {
            Write-Host "The path '$path' is a directory."
            continue
        }
        if (Confirm-For-Confirmation $Path) {
            if ($Direct) {
                Remove-Item -Path $Path -Recurse -Force
                if ($Verbose) {
                    Write-Host "$Path is deleted"
                }
            } else {
                Remove-ToRecycleBin $Path
            }
        }
    }
    else {
        if (-not $Force) {
            Write-Host "$Path does not exist."
        }
    }
}
