git pushparam (
	[Alias("d")]
	[string]$Delimiter = "`t", # Default delimiter is TAB
	[Alias("f")]
	[string[]]$Fields,
	[Parameter(Position = 0, ValueFromRemainingArguments = $true)]
	[string[]]$Files  # Specify the files to process as an array
)

Write-Host "Delimiter=[${Delimiter}]"
Write-Host "Fields=[${Fields}]"
Write-Host "Files=[${Files}]"

if (-not $Fields) {
	Write-Host "cut: you must specify a list of bytes, characters, or fields"
	Write-Host "Try 'cut --help' for more information."
	exit 1
}

function Process-Input() {
	Param (
		$input
	)

	while ($line = $reader.ReadLine()) {
		Write-Output $line
		$parts = $line -split $Delimiter
		Write-Host "parts=[${parts}]"

		$selectedParts = @()
		foreach ($field in $Fields) {
			if ($field -match '-') {
				$start, $end = $field -split '-'
				$selectedParts += $parts[($start - 1)..($end - 1)]
			}
			else {
				$selectedParts += $parts[($field - 1)]
			}
		}

		$outputLine = $selectedParts -join $Delimiter
		Write-Output $outputLine
	}

	$reader.Close()
}

$exitStatus = 0

if ($Files.Count -eq 0) {
	# No arguments provided, read from stdin
	# Set the console input and output encoding to UTF-8
	[Console]::InputEncoding = [System.Text.Encoding]::UTF8
	[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
	$reader = [System.Console]::In
	Process-Input $reader
}
else {
	# Input is provided as a file, create a StreamReader to read the file
	foreach ($file in $Files) {
		if (-not (Test-Path -Path $file -PathType Leaf)) {
			Write-Host "cut: ${file}: No such file or directory"
			$exitStatus = 1
			continue  # Continue to the next file
		}
		# Open the file for reading
		$reader = [System.IO.File]::OpenText($file)
		Process-Input $reader
		$reader.Close()
	}
}

exit $exitStatus
