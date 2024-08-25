Function Get-FileHashCustom($filepath) {
    try {
        $filehash = Get-FileHash -Path $filepath -Algorithm SHA512 -ErrorAction Stop
        return $filehash
    } catch {
        Write-Host "Error calculating hash for $filepath" -ForegroundColor Red
        return $null
    }
}

Function Remove-BaselineIfAlreadyExists {
    if (Test-Path -Path .\baseline.txt) {
        Remove-Item -Path .\baseline.txt -ErrorAction Stop
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

$scriptDirectory = $PSScriptRoot
$filesDirectory = "$scriptDirectory\Files"

if (-not (Test-Path -Path $filesDirectory)) {
    Write-Host "The 'Files' directory does not exist at the expected location: $filesDirectory" -ForegroundColor Red
    exit
}

if ($response -eq "A") {
    Remove-BaselineIfAlreadyExists

    $files = Get-ChildItem -Path $filesDirectory

    foreach ($f in $files) {
        $hash = Get-FileHashCustom $f.FullName
        if ($hash) {
            "$($f.FullName)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
        }
    }
}
elseif ($response -eq "B") {
    $fileHashDictionary = @{}

    if (Test-Path -Path "$scriptDirectory\baseline.txt") {
        $filePathsAndHashes = Get-Content -Path "$scriptDirectory\baseline.txt"

        foreach ($f in $filePathsAndHashes) {
            $path, $hash = $f -split '\|'
            $fileHashDictionary[$path] = $hash
        }
    } else {
        Write-Host "Baseline file not found!" -ForegroundColor Red
        exit
    }

    while ($true) {
        Start-Sleep -Seconds 1

        $files = Get-ChildItem -Path $filesDirectory
        $keysToRemove = @()

        foreach ($f in $files) {
            $hash = Get-FileHashCustom $f.FullName

            if ($hash) {
                if (-not $fileHashDictionary.ContainsKey($f.FullName)) {
                    Write-Host "$($f.FullName) has been created!" -ForegroundColor Green
                    $fileHashDictionary[$f.FullName] = $hash.Hash
                } else {
                    if ($fileHashDictionary[$f.FullName] -ne $hash.Hash) {
                        Write-Host "$($f.FullName) has changed!!!" -ForegroundColor Yellow
                    }
                }
            }

            $keysToRemove += $f.FullName
        }

        foreach ($key in $fileHashDictionary.Keys) {
            if (-not $keysToRemove.Contains($key)) {
                if (-not (Test-Path -Path $key)) {
                    Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
                    $keysToRemove += $key
                }
            }
        }

        foreach ($key in $keysToRemove) {
            $fileHashDictionary.Remove($key)
        }
    }
} else {
    Write-Host "Invalid option entered. Please restart the script and enter 'A' or 'B'." -ForegroundColor Red
}
