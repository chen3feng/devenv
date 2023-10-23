function Show-Help {
    param (
        [array]$OptionSet
    )

    Write-Host "Usage: YourScript.ps1 [options]"

    foreach ($option in $OptionSet) {
        $name = $option.Name
        $alias = $option.Alias
        $type = $option.Type
        $help = $option.Help

        $optionText = if ($alias) { "-$alias, --$name" } else { "--$name" }
        Write-Host "$optionText : $help"
    }
}

# Parse command line arguments with case sensitivity
function Parse-CommandLine {
    param (
        [string[]]$Arguments,
        [array]$OptionSet
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
                        $i++
                        $value = $Arguments[$i]
                        $options[$matchedOption.Name] = $value
                    }
                }
                else {
                    # Unknown option, report an error
                    Write-Error "Unknown option: $arg"
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
        Show-Help $optionSet
        exit 1
    }

    return $options, $parsedArguments
}

$optionSet = @(
    @{
        "Name"  = "help"
        "Alias" = $null
        "Type"  = "bool"
        "Help"  = "Show help information."
    },
    @{
        "Name"  = "force"
        "Alias" = "f"
        "Type"  = "bool"
        "Help"  = "ignore nonexistent files and arguments, never prompt"
    },
    @{
        "Name"  = "directly"
        "Alias" = "d"
        "Type"  = "bool"
        "Help"  = "Specify 'directly'."
    }
)

$commandLineOptions, $commandLineArguments = Parse-CommandLine -Arguments $args -OptionSet $optionSet

Write-Host "commandLineOptions:"
foreach ($key in $commandLineOptions.Keys) {
    $value = $commandLineOptions[$key]
    Write-Host "$key : $value"
}

Write-Host "commandLineArguments:"
$commandLineArguments | ForEach-Object { Write-Host $_ }

exit

# Check for help and version options
if ($Help) {
    # Display help message and exit
    Write-Host "
Usage: rm [OPTION]... [FILE]...
Remove (unlink) the FILE(s).

  -f, --force           ignore nonexistent files and arguments, never prompt
  -i                    prompt before every removal
  -I                    prompt once before removing more than three files, or
                          when removing recursively; less intrusive than -i,
                          while still giving protection against most mistakes
      --interactive[=WHEN]  prompt according to WHEN: never, once (-I), or
                          always (-i); without WHEN, prompt always
      --no-preserve-root  do not treat '/' specially
      --preserve-root[=all]  do not remove '/' (default);
                              with 'all', reject any command line argument
                              on a separate device from its parent
  -r, -R, --recursive   remove directories and their contents recursively
  -d, --dir             remove empty directories
  -v, --verbose         explain what is being done
      --help     display this help and exit
      --version  output version information and exit

By default, rm does not remove directories.  Use the --recursive (-r or -R)
option to remove each listed directory, too, along with all of its contents.

To remove a file whose name starts with a '-', for example '-foo',
use one of these commands:
  rm -- -foo

  rm ./-foo
"
}

if ($Version) {
    # Display version information and exit
    Write-Host "rm version 1.0"
    exit 0
}

if ($commandLineArgs.Items.Count -eq 0) {
    Write-Host "rm: missing operand"
    Write-Host "Try 'rm --help' for more information."
    exit 0
}

# Define a function to prompt for confirmation if the -i option is used
function Prompt-For-Confirmation($Path) {
    if ($Interactive -or ($InteractiveOnce -and ($commandLineArgs.Items.Count -gt 3 -or $Recursive))) {
        $confirmation = Read-Host "Delete '$Path'? [Y/N]"
        if ($confirmation -ne "Y") {
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
        $folder = $shell.Namespace(0x0a)
        $folder.ParseName($item.FullName).InvokeVerb("delete")

        Write-Host "Deleted to system recycle bin: $Path"
    }
    else {
        Write-Host "$Path does not exist."
    }
}

# Loop through the provided paths
foreach ($Path in $commandLineArgs.Items) {
    Write-Host $Path
    if ($NoPreserveRoot -and ($Path -eq "/" -or $Path -eq "\")) {
        Write-Host "Error: '/' or '\' cannot be removed."
        continue
    }

    if ($Verbose) {
        Write-Host "Deleting: $Path"
    }

    if (Test-Path $Path) {
        if ($Force -or (Prompt-For-Confirmation $Path)) {
            if ($Recursive) {
                Remove-Item -Path $Path -Recurse -Force
            }
            else {
                Remove-ToRecycleBin $Path
            }
            Write-Host "Deleted to system recycle bin: $Path"
        }
    }
    else {
        Write-Host "$Path does not exist."
    }
}
