:: No Man's Sky Decompressinator Script by CheatFreak
:: See https://github.com/cheatfreak47/NMSDecompressinator for details.
:: It requires:
:: PSARC by Sony Computer Entertainment LLC from any PlayStation SDK that includes it. (Bundled copy is from PsArcTool)
:: NMSResign 1.0.2 by stk25/emoose/CheatFreak from https://github.com/cheatfreak47/NMSResign

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
	exit /b 1
)

:: Check if psarc.exe exists
if not exist psarc.exe (
	echo Error: psarc.exe not found in the working directory.
	echo Please put this script, psarc.exe, and NMSResign.exe in the No Man's Sky\GAMEDATA\PCBANKS folder.
	echo Press any key to exit.
	pause > NUL
	exit /b 1
)

:: Check if NMSResign.exe exists
if not exist NMSResign.exe (
	echo Error: NMSResign.exe not found in the working directory.
	echo Please put this script, psarc.exe, and NMSResign.exe in the No Man's Sky\GAMEDATA\PCBANKS folder.
	echo Press any key to exit.
	pause > NUL
	exit /b 1
)

:: Check if the path is too long
set "dir=%cd%"
set "len=0"
for /l %%A in (12,-1,0) do (
	set /a "len|=1<<%%A"
	for %%B in (!len!) do if "!dir:~%%B,1!"=="" set /a "len&=~1<<%%A"
)
if !len! gtr 88 if "%force%"=="false" (
	echo Error: Your No Man's Sky installation path is too long for PSARC to function properly.
	echo This is unfortunately a limitation of Windows. You will need to perform a workaround, such as
	echo moving your PCBANKS to the root of your disk, and running the script again. After the script
	echo completes, you can move the PCBANKS folder back into the No Man's Sky installation path. Or
	echo you could install No Man's Sky to a different Steam Library that is closer to the drive root.
	echo Press any key to exit.
	pause > NUL
	exit /b 1
)

:: Try to check if the there's enough free space if it's the first run
if not exist timestamp.txt if "%force%"=="false" (
	for /f %%a in ('powershell -command "Get-ChildItem -Filter *.pak | ForEach-Object { $_.Length } | Measure-Object -Sum | ForEach-Object { $_.Sum }"') do set totalSize=%%a
	for /f %%a in ('powershell -command "[math]::Round(!totalSize! * 3.25)"') do set requiredSpace=%%a
	for /f %%a in ('powershell -command "(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq (Get-Location).Path.Substring(0,3) }).Free"') do set freeSpace=%%a
	for /f %%a in ('powershell -command "[math]::Round(!freeSpace! / 1GB, 2)"') do set freeSpaceGB=%%a
	for /f %%a in ('powershell -command "[math]::Round(!requiredSpace! / 1GB, 2)"') do set requiredSpaceGB=%%a
	:: Check if there is enough free space
	if !requiredSpaceGB! gtr !freeSpaceGB! (
		echo Error: The disk No Man's Sky is installed does not seem to have enough free space.
		echo Based on your .pak files, around !requiredSpaceGB!GB will be needed to decompress. ^(aka !requiredSpace! bytes^)
		echo Your disk has only !freeSpaceGB!GB. ^(aka !freeSpace! bytes^)
		echo Please free additional space and run the script again.
		pause > NUL
		exit /b 1
	)
)

:: Start Message
echo NMS Decompressinator v2.0.2 by CheatFreak
echo -----------------------------------------
echo it uses....
echo  psarc by Sony Computer Entertainment LLC
echo     (From any PlayStation SDK)
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
	:: Get the last write time of the BankSignatures.bin file
	for /f "delims=" %%a in ('powershell -command "(Get-Item 'BankSignatures.bin').LastWriteTime.ToString('MM/dd/yyyy HH:mm:ss')"') do set "bankFileTime=%%a"

	:: Compare the BankSignatures.bin file time with the last timestamp
	for /f %%a in ('powershell -command "if (([datetime]'!bankFileTime!') -gt ([datetime]'!lastTimestamp!')) { echo true } else { echo false }"') do set "isBankFileNewer=%%a"

	if "!isBankFileNewer!"=="true" (
		if "!noBackup!"=="false" (
			echo Backing up BankSignitures.bin
			copy /Y "BankSignatures.bin" "PackedFileBackup" > NUL
		)
	) else (
		echo Skipping BankSignatures.bin. This one was generated by NMSResign from the previous run, based on timestamp.
	)
)

:: Make New BankSignitures
NMSResign.exe -createbin

:: Write the current timestamp to the file
timeout /t 2 > NUL
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
