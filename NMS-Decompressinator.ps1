# No Man's Sky Decompressinator Script by CheatFreak
# See https://github.com/cheatfreak47/NMSDecompressinator for details.
# It requires:
# PSARC by Sony Computer Entertainment LLC from any PlayStation SDK that includes it. (Bundled copy is from PS3 SDK 4.50)
# NMSResign 1.0.1 by stk25/emoose/CheatFreak from https://github.com/cheatfreak47/NMSResign
# Adapted to Powershell by Silent369

# Initialize argument variables
$noBackup = $false
$force = $false

# Parse arguments
switch ($args) {
    "-no-backup" { $noBackup = $true }
    "-force"     { $force = $true }
}

# Function to draw a line
function Write-Line {
    param (
        [int]$Length = 80 # default value
    )
    if ($Length -gt 0) {
        Write-Host ('-' * $Length) -ForegroundColor DarkGray
    } else {
        Write-Host "> Length must be a positive integer."
    }
}

# Function to display the header with colorized sections
function Write-Head {
    Write-Host
    Write-Host "NMS Decompressinator v2.0.0 by CheatFreak" -ForegroundColor DarkCyan
    Write-Line
    Write-Host
    Write-Host "It requires:" -ForegroundColor DarkCyan
    Write-Host "   psarc by Sony Computer Entertainment LLC (From PS3 SDK 4.50)" -ForegroundColor Gray
    Write-Host "   NMSResign Fork by CheatFreak, (Original NMSResign by emoose/stk25.)" -ForegroundColor Gray
    Write-Host
    Write-Host "Side Note:" -ForegroundColor DarkCyan
    Write-Host "   It may seem at some points like it has stopped and isn't continuing." -ForegroundColor Gray
    Write-Host "   Don't worry, it's fine! Just patiently wait for it to finish." -ForegroundColor Gray
    Write-Host "   It takes time..." -ForegroundColor Gray
    Write-Host
    Write-Line
    Write-Host
}

# Function to get the install path of No Man's Sky from the registry
# and by searching the paths for both GOG and Steam installations...
function Get-NoMansSkyInstallPaths {
    $gogRegistryPath = "HKLM:\SOFTWARE\WOW6432Node\GOG.com\Games\1446213994"

    function Get-RegistryValue {
        param (
            [string]$path,
            [string]$name
        )
        try {
            return (Get-ItemProperty -Path $path -Name $name -ErrorAction Stop).$name
        }
        catch {
            return $null
        }
    }

    $paths = @()

    $steamPath = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue
    if ($steamPath) {
        $steamInstallPath = Join-Path -Path $steamPath.SteamPath -ChildPath "steamapps\common\No Man's Sky"
        if (Test-Path $steamInstallPath) {
            $paths += [PSCustomObject]@{ Source = "Steam:"; Path = Join-Path -Path $steamInstallPath -ChildPath "GAMEDATA\PCBANKS" }
        }
    }

    $gogPath = Get-RegistryValue -Path $gogRegistryPath -Name "path"
    if ($gogPath) {
        $paths += [PSCustomObject]@{ Source = "  GOG:"; Path = Join-Path -Path $gogPath -ChildPath "GAMEDATA\PCBANKS" }
    }

    return $paths
}

# Function to prompt the user for a choice
function Choose-InstallPath {
    param (
        [array]$paths
    )
    if ($paths.Count -eq 0) {
        Write-Host "No Man's Sky installation path(s) NOT found in the Registry or GOG or Steam!"
        return $null
    }
    while ($true) {
        Clear-Host
        Write-Head
        Write-Host "Available installation paths:" -ForegroundColor DarkCyan
        Write-Host
        # Numbering and displaying each path
        for ($i = 0; $i -lt $paths.Count; $i++) {
            Write-Host "   $($i + 1). $($paths[$i].Source) - $($paths[$i].Path)"
        }
        Write-Host
        $choice = Read-Host "Enter the number of the game path you want to use (1-$($paths.Count))"
        if ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $paths.Count) {
            return $paths[$choice - 1].Path
        } else {
            Write-Host "Invalid choice. Please enter a number between 1 and $($paths.Count)."
        }
    }
}

# Get possible installation paths
$installPaths = Get-NoMansSkyInstallPaths

# Allow user to choose the path
$selectedPath = Choose-InstallPath -paths $installPaths

if ($selectedPath) {
    $GPath = $selectedPath
} else {
    Clear-Host
    Write-Head
    Write-Host "  Error! No valid path has been found or selected."
    Write-Host
    Write-Line
    Write-Host "> Press any key to exit." -ForegroundColor DarkCyan
    Read-Host
    exit
}

Clear-Host

# Path to where the tools reside (current folder)
$TPath = Get-Location

# Save active current path for resetting to later
$SPath = $TPath

# Change to the GAMEDATA\PCBANKS directory
Set-Location -Path $GPath

# Check if any .pak files exist
if (-not (Test-Path *.pak)) {
    Clear-Host
    Write-Head
    Write-Host "  Error: No .pak files found in the working directory." -ForegroundColor Red
    Write-Host "  Please correct the working directory: No Man's Sky\GAMEDATA\PCBANKS."
    Write-Host
    Write-Line
    Write-Host "> Press any key to exit." -ForegroundColor DarkCyan
    Read-Host
    exit
}

# Check if psarc.exe and NMSResign.exe exist
$requiredTools = @("psarc.exe", "NMSResign.exe")
$missingTools = $requiredTools | Where-Object { -not (Test-Path "$TPath\$_") }

if ($missingTools) {
    Clear-Host
    Write-Head
    foreach ($tool in $missingTools) {
        Write-Host "   Error: $tool not found in $TPath." -ForegroundColor Red
        Write-Host "   Please place $tool in the directory specified above."
        Write-Host
    }
    Write-Line
    Write-Host "> Press any key to exit." -ForegroundColor DarkCyan
    Read-Host
    exit
}

# Start Message
Clear-Host
Write-Head
Write-Host -NoNewline "> Begin processing in: "

# Countdown on one line
for ($i = 5; $i -ge 1; $i--) {
    if ($i -eq 1) {
        Write-Host -NoNewline "$i" -ForegroundColor DarkCyan
    } else {
        Write-Host -NoNewline "$i..." -ForegroundColor DarkCyan
    }
    Start-Sleep -Seconds 1
    Write-Host -NoNewline ""  # Clear the previous countdown
}
Write-Host
Write-Host
Write-Line

# Check if timestamp file exists and read it into a variable
$timestampFile = "timestamp.txt"
$lastTimestamp = if (Test-Path $timestampFile) { Get-Content $timestampFile } else { "01/01/1970 00:00:00" }

# Check if PackedFileBackup directory exists
if (-not $noBackup -and -not (Test-Path "PackedFileBackup")) {
    New-Item -ItemType Directory -Path "PackedFileBackup"
}

# Define maximum length for filename output
$maxLength = 38

# Get all files in a collection
$files = Get-ChildItem -Filter *.pak

# Get the total count of files
$totalFiles = $files.Count

# Loop over the files with index
for ($index = 0; $index -lt $totalFiles; $index++) {
    $file = $files[$index]

    # Get the last write time of the current file
    $fileTime = $file.LastWriteTime.ToString('MM/dd/yyyy HH:mm:ss')

    # Compare the file time with the last timestamp
    $isFileNewer = [datetime]$fileTime -gt [datetime]$lastTimestamp

    if ($force) { $isFileNewer = $true }

    if ($isFileNewer) {
        Write-Host "Extracting $($file.Name)" -ForegroundColor DarkCyan
        & "$TPath\psarc.exe" extract "$($file.Name)" --to="$($file.BaseName)" | Out-Null
        if ($noBackup) {
            Write-Host "Deleting $($file.Name)" -ForegroundColor DarkCyan
            Remove-Item "$($file.FullName)" -Force
        } else {
            Write-Host "Moving $($file.Name) to PackedFileBackup" -ForegroundColor DarkCyan
            Move-Item "$($file.FullName)" "PackedFileBackup"
        }
        Write-Host "Repacking $($file.BaseName)" -ForegroundColor DarkCyan
        & "$TPath\psarc.exe" create -i "$($file.BaseName)" -N -q -y -o "$($file.Name)" -s ".*?$($file.BaseName)" | Out-Null
        Write-Host "Removing directory $($file.BaseName)" -ForegroundColor DarkCyan

        # Only write the line if it's not the last file
        if ($index -lt ($totalFiles - 1)) {
            Write-Line
        }
        Remove-Item -Path "$($file.BaseName)" -Recurse -Force
    } else {
        $paddedFilename = "{0,-$maxLength}" -f $file.Name
        Write-Host "Skipping: $paddedFilename. UNPACKED based on Timestamp!" -ForegroundColor DarkCyan
    }
}

# Backup BankSignatures
if (Test-Path "BankSignatures.bin") {
    if (-not $noBackup) {
        Write-Line
        Write-Host "Backing up BankSignatures.bin" -ForegroundColor DarkCyan
        Write-Line
        Copy-Item "BankSignatures.bin" "PackedFileBackup" -Force
    }
}

# Make New BankSignatures
Write-Host "Creating new BankSignatures"
& "$TPath\NMSResign.exe" -createbin

# Write the current timestamp to the file
(Get-Date).ToString('MM/dd/yyyy HH:mm:ss') | Out-File -FilePath $timestampFile -Encoding ascii -Force

# Reset the script path in case user started
# the tool manually within Powershell/Terminal
Set-Location -Path $SPath

# Exit Message
Write-Host "Process complete!"
Write-Line
Write-Host "Enjoy a slightly less laggy No Man's Sky!" -ForegroundColor DarkCyan
Write-Line
Write-Host "After No Man's Sky updates, it is likely you will get a 'File Tampering'"
Write-Host "warning on launch. To fix this, just run the script again and it will"
Write-Host "decompress the updated files and resign. See ya next time..."
Write-Line
Write-Host "> Press any key to exit." -ForegroundColor DarkCyan
Read-Host