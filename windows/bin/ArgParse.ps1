# Command Line Arguments Parse

# Override the built-in cmdlet with a custom version
function Write-Error($message) {
    [Console]::ForegroundColor = 'red'
    [Console]::Error.WriteLine($message)
    [Console]::ResetColor()
}

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
                Write-Error "${Prog}: unrecognized option '$arg'"
                exit 1
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
                        exit 1
                    }
                }
                else {
                    # Unknown option, report an error
                    Write-Error "${Prog}: unknown option -- '$shortOption'"
                    exit 1
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
