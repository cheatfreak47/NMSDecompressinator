:: No Man's Sky Decompressinator Script by CheatFreak
:: See https://github.com/cheatfreak47/NMSDecompressinator for details.
:: It requires:
:: PSARC by Sony Computer Entertainment LLC from any PlayStation SDK that includes it. (Bundled copy is from PS3 SDK 4.50)
:: NMSResign 1.0.1 by stk25/emoose/CheatFreak from https://github.com/cheatfreak47/NMSResign

@echo off
setlocal enabledelayedexpansion

:: Initialize argument variables
set "noBackup=false"
set "force=false"

:: Check for arguments
for %%a in (%*) do (
    if "%%a"=="-no-backup" (
        set "noBackup=true"
    )
    if "%%a"=="-force" (
        set "force=true"
    )
)

:: Check if any .pak files exist
if not exist *.pak (
    echo Error: No .pak files found in the working directory.
	echo Please put this script, psarc.exe, and NMSResign.exe in the No Man's Sky\GAMEDATA\PCBANKS folder.
	echo Press any key to exit.
	pause > NUL
    exit /b
)

:: Check if psarc.exe and NMSResign.exe exist
if not exist psarc.exe (
    echo Error: psarc.exe not found in the working directory.
	echo Please put this script, psarc.exe, and NMSResign.exe in the No Man's Sky\GAMEDATA\PCBANKS folder.
    echo Press any key to exit.
	pause > NUL
	exit /b
)
if not exist NMSResign.exe (
    echo Error: NMSResign.exe not found in the working directory.
	echo Please put this script, psarc.exe, and NMSResign.exe in the No Man's Sky\GAMEDATA\PCBANKS folder.
    echo Press any key to exit.
	pause > NUL
	exit /b
)

:: Start Message
echo NMS Decompressinator v2.0.0 by CheatFreak
echo -----------------------------------------
echo it uses....
echo  psarc by Sony Computer Entertainment LLC
echo     (From PS3 SDK 4.50)
echo  NMSResign Fork by CheatFreak
echo     (Original NMSResign by emoose/stk25.)
echo -----------------------------------------
echo Note: 
echo  It may seem at some points like it has
echo  stopped and isn't continuing...
echo  Don't worry, it's fine. Just patiently
echo  wait for it to finish. It takes time.
echo -----------------------------------------
echo Beginning in...
timeout /t 1 > NUL
echo 5...
timeout /t 1 > NUL
echo 4...
timeout /t 1 > NUL
echo 3...
timeout /t 1 > NUL
echo 2...
timeout /t 1 > NUL
echo 1...
timeout /t 1 > NUL

:: Check if timestamp file exists and read it into a variable
if exist timestamp.txt (
    for /f "delims=" %%a in (timestamp.txt) do set "lastTimestamp=%%a"
) else (
    set "lastTimestamp=01/01/1970 00:00:00"
)

:: Check if PackedFileBackup directory exists
if "!noBackup!"=="false" (
    if not exist PackedFileBackup mkdir PackedFileBackup
)

:: Loop over the files
for %%f in (*.pak) do (
    :: Get the last write time of the current file
    for /f "delims=" %%a in ('powershell -command "(Get-Item '%%f').LastWriteTime.ToString('MM/dd/yyyy HH:mm:ss')"') do set "fileTime=%%a"

    :: Compare the file time with the last timestamp
    for /f %%a in ('powershell -command "if (([datetime]'!fileTime!') -gt ([datetime]'!lastTimestamp!')) { echo true } else { echo false }"') do set "isFileNewer=%%a"
    if "!force!"=="true" (
        set "isFileNewer=true"
    )
    if !isFileNewer! equ true (
        psarc.exe extract "%%f" --to="%%~nf"
        if "!noBackup!"=="true" (
            del /F /Q "%%~nxf"
        ) else (
            move /Y "%%~nxf" "PackedFileBackup"
        )
        psarc.exe create -i "%%~nf" -N -y -o "%%~nxf" -s ".*?%%~nf"
        rmdir /s /q %%~nf
    ) else (
		echo Skipping %%f. Seems to be already unpacked, based on timestamp.
	)
)

:: Backup BankSignitures
if exist "BankSignatures.bin" (
	if "!noBackup!"=="false" (
		echo Backing up BankSignitures.bin
		copy /Y "BankSignatures.bin" "PackedFileBackup" > NUL
	)
)

:: Make New BankSignitures
NMSResign.exe -createbin

:: Write the current timestamp to the file
powershell -command "Get-Date -Format 'MM/dd/yyyy HH:mm:ss' | Out-File -FilePath timestamp.txt -Encoding ascii -Force"

:: Exit Message
echo Process complete!
echo -----------------------------------------
echo Enjoy a slightly less laggy No Man's Sky!
echo -----------------------------------------
echo After No Man's Sky updates, it is likely you will get a "File Tamepering" warning on launch.
echo To fix this, just run the script again and it will decompress the updated files and resign.
echo See ya next time...
echo Press any key to exit.
pause > NUL
endlocal
exit
