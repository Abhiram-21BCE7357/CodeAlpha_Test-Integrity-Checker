Function Get-FileHashCustom($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Remove-BaselineIfAlreadyExists {
    $baselineExists = Test-Path -Path .\baseline.txt

    if ($baselineExists) {
        # Delete it
        Remove-Item -Path .\baseline.txt
    }
}

Write-Host ""
Write-Host "What would you like to do?"
Write-Host ""
Write-Host "    A) Collect a new Baseline?"
Write-Host "    B) Begin monitoring files with the saved Baseline?"
Write-Host ""
$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

# Get the directory where the script is located
$scriptDirectory = $PSScriptRoot

if ($response -eq "A") {
    # Delete baseline.txt if it already exists
    Remove-BaselineIfAlreadyExists

    # Calculate Hash from the target files and store in baseline.txt
    # Collect all files in the target folder
    $files = Get-ChildItem -Path "$scriptDirectory\Files"

    # For each file, calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
        $hash = Get-FileHashCustom $f.FullName
        "$($f.FullName)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }
}
elseif ($response -eq "B") {
    $fileHashDictionary = @{}

    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathsAndHashes = Get-Content -Path "$scriptDirectory\baseline.txt"

    foreach ($f in $filePathsAndHashes) {
        $path, $hash = $f -split '\|'
        $fileHashDictionary[$path] = $hash
    }

    # Begin continuously monitoring files with saved Baseline
    while ($true) {
        Start-Sleep -Seconds 1

        $files = Get-ChildItem -Path "$scriptDirectory\Files"

        $keysToRemove = @()

        # For each file, calculate the hash, and write to baseline.txt
        foreach ($f in $files) {
            $hash = Get-FileHashCustom $f.FullName

            # Notify if a new file has been created
            if (-not $fileHashDictionary.ContainsKey($f.FullName)) {
                # A new file has been created!
                Write-Host "$($f.FullName) has been created!" -ForegroundColor Green

                # Add the new file and its hash to the dictionary
                $fileHashDictionary[$f.FullName] = $hash.Hash
            }
            else {
                # Notify if a file has been changed
                if ($fileHashDictionary[$f.FullName] -ne $hash.Hash) {
                    # File has been compromised, notify the user
                    Write-Host "$($f.FullName) has changed!!!" -ForegroundColor Yellow
                }
            }

            $keysToRemove += $f.FullName
        }

        # Check if baseline files have been deleted
        foreach ($key in $fileHashDictionary.Keys) {
            if (-not $keysToRemove.Contains($key)) {
                $baselineFileStillExists = Test-Path -Path $key
                if (-not $baselineFileStillExists) {
                    # One of the baseline files must have been deleted, notify the user
                    Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
                    $keysToRemove += $key
                }
            }
        }

        # Remove keys from the dictionary
        foreach ($key in $keysToRemove) {
            $fileHashDictionary.Remove($key)
        }
    }
}